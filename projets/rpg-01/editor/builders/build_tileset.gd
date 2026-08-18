extends SceneTree

const MANIFEST_PATH := "res://game/world/tileset/terrain/terrain_catalog.json"
const BEACH_MANIFEST_PATH := "res://game/world/tileset/beach/terrain/beach_terrain_catalog.json"
const OBJECT_TEXTURE_PATH := "res://game/world/tileset/objects/objects_atlas.png"
const OBJECT_METADATA_PATH := "res://game/world/tileset/objects/objects_catalog.json"
const BEACH_OBJECT_TEXTURE_PATH := "res://game/world/tileset/beach/objects/beach_objects_atlas.png"
const BEACH_OBJECT_METADATA_PATH := "res://game/world/tileset/beach/objects/beach_objects_catalog.json"
const OUTPUT_PATH := "res://game/world/tileset/world_tileset.tres"
const TILE_SIZE := Vector2i(32, 32)
const OBJECT_SOURCE_ID := 20
const BEACH_OBJECT_SOURCE_ID := 21


func _initialize() -> void:
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	var beach_manifest = JSON.parse_string(FileAccess.get_file_as_string(BEACH_MANIFEST_PATH))
	var object_metadata = JSON.parse_string(FileAccess.get_file_as_string(OBJECT_METADATA_PATH))
	var beach_object_metadata = JSON.parse_string(FileAccess.get_file_as_string(BEACH_OBJECT_METADATA_PATH))
	var object_texture := load(OBJECT_TEXTURE_PATH) as Texture2D
	var beach_object_texture := load(BEACH_OBJECT_TEXTURE_PATH) as Texture2D
	if not manifest is Dictionary or not beach_manifest is Dictionary or not object_metadata is Dictionary \
		or not beach_object_metadata is Dictionary or object_texture == null or beach_object_texture == null:
		push_error("Entrées du TileSet d'édition introuvables.")
		quit(1)
		return
	var tile_set := _new_tile_set()
	for row in range(manifest["families"].size()):
		_add_terrain_family(tile_set, row, manifest["families"][row])
	for family in beach_manifest["families"]:
		_add_terrain_family(tile_set, int(family["source_id"]), family)
	_add_object_source(tile_set, object_texture, object_metadata, OBJECT_SOURCE_ID, "20 · Objets du monde")
	_add_object_source(tile_set, beach_object_texture, beach_object_metadata, BEACH_OBJECT_SOURCE_ID, "21 · Objets de plage")
	tile_set.set_meta("purpose", "TileSet canonique pour peindre manuellement dans l'éditeur Godot")
	tile_set.set_meta("terrain_manifest", MANIFEST_PATH)
	tile_set.set_meta("beach_terrain_manifest", BEACH_MANIFEST_PATH)
	tile_set.set_meta("object_manifest", OBJECT_METADATA_PATH)
	tile_set.set_meta("beach_object_manifest", BEACH_OBJECT_METADATA_PATH)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var error := ResourceSaver.save(tile_set, OUTPUT_PATH)
	if error != OK:
		push_error("Échec d'enregistrement : %s" % error_string(error))
		quit(1)
		return
	print("TileSet éditeur : 201 terrains en 19 familles + 101 objets nommés.")
	quit()


func _new_tile_set() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	tile_set.resource_name = "Monde RPG — édition manuelle"
	tile_set.add_physics_layer(0)
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)
	for definition in [
		["asset_id", TYPE_STRING],
		["asset_group", TYPE_STRING],
		["terrain_kind", TYPE_STRING],
		["height_level", TYPE_INT],
		["traversal", TYPE_STRING],
		["movement_cost", TYPE_FLOAT],
		["footstep_kind", TYPE_STRING],
		["interaction_kind", TYPE_STRING],
		["blocks_vision", TYPE_BOOL],
		["description", TYPE_STRING],
		["recommended_layer", TYPE_STRING],
		["psychokinesis_response", TYPE_STRING],
		["psychokinesis_mass", TYPE_STRING],
		["psychokinesis_material", TYPE_STRING],
		["psychokinesis_breakable", TYPE_BOOL],
		["psychokinesis_required_power", TYPE_INT],
	]:
		var index := tile_set.get_custom_data_layers_count()
		tile_set.add_custom_data_layer(index)
		tile_set.set_custom_data_layer_name(index, definition[0])
		tile_set.set_custom_data_layer_type(index, definition[1])
	return tile_set


func _add_terrain_family(tile_set: TileSet, source_id: int, family: Dictionary) -> void:
	var texture := load("res://%s" % str(family["texture"])) as Texture2D
	assert(texture != null, "Texture absente : %s" % str(family["texture"]))
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = TILE_SIZE
	atlas.resource_name = "%02d · %s" % [source_id + 1, str(family["description"])]
	var tile_count := int(family.get("tile_count", 11))
	for column in range(tile_count):
		atlas.create_tile(Vector2i(column, 0))
	var animation: Dictionary = family.get("tile_animation", {})
	if not animation.is_empty():
		var frame_count := int(animation.get("frames", 1))
		var frame_duration := float(animation.get("duration_ms", 160)) / 1000.0
		for tile_value in animation.get("tiles", []):
			var coordinates := Vector2i(int(tile_value), 0)
			atlas.set_tile_animation_columns(coordinates, 1)
			atlas.set_tile_animation_frames_count(coordinates, frame_count)
			for frame in range(frame_count):
				atlas.set_tile_animation_frame_duration(coordinates, frame, frame_duration)
			if str(animation.get("mode", "default")) == "random_start":
				atlas.set_tile_animation_mode(coordinates, TileSetAtlasSource.TILE_ANIMATION_MODE_RANDOM_START_TIMES)
	tile_set.add_source(atlas, source_id)
	var kind := str(family.get("terrain_kind", _terrain_kind(source_id)))
	var traversal := str(family.get("traversal", "transition" if source_id == 8 else ("blocked" if source_id in [3, 4, 5, 6, 7, 9, 10] else "walk")))
	for column in range(tile_count):
		var data := atlas.get_tile_data(Vector2i(column, 0), 0)
		data.set_custom_data("asset_id", "%s.variant_%02d" % [str(family["id"]), column])
		data.set_custom_data("asset_group", "terrain/%s" % str(family["id"]))
		data.set_custom_data("terrain_kind", kind)
		data.set_custom_data("height_level", 0)
		data.set_custom_data("traversal", traversal)
		data.set_custom_data("movement_cost", 1.0)
		data.set_custom_data("footstep_kind", _footstep(kind))
		data.set_custom_data("interaction_kind", "none")
		data.set_custom_data("blocks_vision", source_id in [5, 6, 7, 18])
		data.set_custom_data("description", "%s — variante %02d" % [str(family["description"]), column + 1])
		data.set_custom_data("recommended_layer", str(family.get("recommended_layer", _recommended_layer(source_id))))
		_set_psychokinesis_data(data, {
			"response": "anchored", "mass": "immense", "material": kind,
			"breakable": false, "required_power": 0,
		})
		if traversal == "blocked":
			_add_full_tile_collision(data)


func _add_object_source(tile_set: TileSet, texture: Texture2D, metadata: Dictionary, source_id: int, source_name: String) -> void:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = TILE_SIZE
	atlas.resource_name = source_name
	for sprite in metadata["sprites"]:
		atlas.create_tile(_v2i(sprite["atlas_coordinates"]), _v2i(sprite["size_in_cells"]))
	tile_set.add_source(atlas, source_id)
	for sprite in metadata["sprites"]:
		var data := atlas.get_tile_data(_v2i(sprite["atlas_coordinates"]), 0)
		_set_common_data(data, str(sprite["id"]), str(sprite["group"]))
		_set_psychokinesis_data(data, sprite.get("psychokinesis", {}))
		if str(sprite.get("anchor_kind", "foot")) == "foot":
			var region_size := _v2i(sprite["region_size_px"])
			var foot_anchor := _v2i(sprite["foot_anchor_px"])
			data.texture_origin = Vector2i(region_size.x / 2, region_size.y / 2) - foot_anchor
		var role := str(sprite["default_role"])
		data.set_custom_data("traversal", _traversal_for_role(role))
		data.set_custom_data("interaction_kind", _interaction_for_role(role))
		data.set_custom_data("footstep_kind", "")
		data.set_custom_data("blocks_vision", role in ["building_with_entrance", "solid_footprint"] and str(sprite["group"]).begins_with("architecture/"))
		data.set_custom_data("description", "Objet — %s" % str(sprite["id"]))
		data.set_custom_data("recommended_layer", str(sprite["recommended_layer"]))
		if role == "building_with_entrance":
			_add_building_entrance_collision(data, _v2i(sprite["region_size_px"]))
		elif role == "bridge_deck_with_blocked_sides":
			_add_bridge_side_collisions(data, _v2i(sprite["region_size_px"]))
		elif role in ["solid_footprint", "solid_interactable", "small_obstacle", "tree_trunk_obstacle"]:
			var material := str(sprite.get("psychokinesis", {}).get("material", "mixed"))
			_add_foot_collision(data, _v2i(sprite["region_size_px"]), _v2i(sprite["content_size_px"]), role, material)


func _set_common_data(data: TileData, asset_id: String, group: String) -> void:
	data.set_custom_data("asset_id", asset_id)
	data.set_custom_data("asset_group", group)
	data.set_custom_data("terrain_kind", "")
	data.set_custom_data("height_level", 0)
	data.set_custom_data("traversal", "walk")
	data.set_custom_data("movement_cost", 1.0)
	data.set_custom_data("footstep_kind", "")
	data.set_custom_data("interaction_kind", "none")
	data.set_custom_data("blocks_vision", false)


func _set_psychokinesis_data(data: TileData, profile: Dictionary) -> void:
	data.set_custom_data("psychokinesis_response", str(profile.get("response", "anchored")))
	data.set_custom_data("psychokinesis_mass", str(profile.get("mass", "immense")))
	data.set_custom_data("psychokinesis_material", str(profile.get("material", "unknown")))
	data.set_custom_data("psychokinesis_breakable", bool(profile.get("breakable", false)))
	data.set_custom_data("psychokinesis_required_power", int(profile.get("required_power", 0)))


func _traversal_for_role(role: String) -> String:
	if role in ["solid_footprint", "solid_interactable", "small_obstacle", "tree_trunk_obstacle", "building_with_entrance"]:
		return "blocked"
	if role in ["elevation_transition", "bridge_deck_with_blocked_sides", "entrance"]:
		return "transition"
	return "walk"


func _interaction_for_role(role: String) -> String:
	match role:
		"entrance", "building_with_entrance": return "door"
		"harvestable": return "harvest"
		"interactable", "solid_interactable": return "inspect"
		"openable_gate": return "gate"
		_: return "none"


func _add_building_entrance_collision(data: TileData, region_size: Vector2i) -> void:
	var half_width := float(region_size.x) * 0.5 - 8.0
	var gap_half_width := 18.0
	var bottom := 10.0
	var top := bottom - 24.0
	data.set_collision_polygons_count(0, 2)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-half_width, top), Vector2(-gap_half_width, top),
		Vector2(-gap_half_width, bottom), Vector2(-half_width, bottom),
	]))
	data.set_collision_polygon_points(0, 1, PackedVector2Array([
		Vector2(gap_half_width, top), Vector2(half_width, top),
		Vector2(half_width, bottom), Vector2(gap_half_width, bottom),
	]))


func _add_bridge_side_collisions(data: TileData, region_size: Vector2i) -> void:
	var half_width := float(region_size.x) * 0.5 - 8.0
	# Le pont traverse horizontalement. Les garde-corps nord et sud sont solides,
	# les deux extrémités restent ouvertes pour imposer le vrai passage.
	data.set_collision_polygons_count(0, 2)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-half_width, -88.0), Vector2(half_width, -88.0),
		Vector2(half_width, -72.0), Vector2(-half_width, -72.0),
	]))
	data.set_collision_polygon_points(0, 1, PackedVector2Array([
		Vector2(-half_width, -8.0), Vector2(half_width, -8.0),
		Vector2(half_width, 10.0), Vector2(-half_width, 10.0),
	]))


func _add_full_tile_collision(data: TileData) -> void:
	data.set_collision_polygons_count(0, 1)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16),
	]))


func _add_foot_collision(data: TileData, region_size: Vector2i, content_size: Vector2i, role: String, material: String) -> void:
	var width_factor := 0.22 if role == "tree_trunk_obstacle" else 0.48 if role == "small_obstacle" else 0.72 if role == "solid_footprint" else 0.58
	var half_width := minf(float(content_size.x) * width_factor * 0.5, float(region_size.x) * 0.4)
	half_width = maxf(half_width, 7.0)
	var bottom := 9.0
	var collision_height := 16.0 if role == "tree_trunk_obstacle" else 13.0 if role == "small_obstacle" else 22.0 if material == "stone" else 19.0
	var top := bottom - collision_height
	var bevel := minf(half_width * 0.34, collision_height * 0.28)
	data.set_collision_polygons_count(0, 1)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-half_width + bevel, top), Vector2(half_width - bevel, top),
		Vector2(half_width, top + bevel), Vector2(half_width, bottom - bevel),
		Vector2(half_width - bevel, bottom), Vector2(-half_width + bevel, bottom),
		Vector2(-half_width, bottom - bevel), Vector2(-half_width, top + bevel),
	]))


func _v2i(values: Array) -> Vector2i:
	return Vector2i(int(values[0]), int(values[1]))


func _terrain_kind(row: int) -> String:
	if row <= 1: return "grass_path"
	if row == 2: return "stone"
	if row in [3, 4, 9, 10]: return "water"
	if row in [5, 6, 7]: return "cliff"
	return "stairs"


func _footstep(kind: String) -> String:
	if kind == "stone" or kind == "stairs": return "stone"
	if kind in ["sand", "wet_sand", "dune", "shoreline"]: return "sand"
	if kind == "grass_path": return "grass_or_earth"
	return ""


func _recommended_layer(row: int) -> String:
	if row <= 1: return "Terrain/Paths"
	if row == 2: return "Terrain/StoneFloors"
	if row == 3: return "Water/WaterBase"
	if row == 4: return "Water/WaterBanks"
	if row in [5, 6, 7]: return "Relief/Cliffs"
	if row == 8: return "Relief/Stairs"
	return "Water/WaterEffects"
