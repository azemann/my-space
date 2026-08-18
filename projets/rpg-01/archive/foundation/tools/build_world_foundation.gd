extends SceneTree

const TERRAIN_TEXTURE := "res://assets/tilesets/terrain-foundation-v001.png"
const TECHNICAL_TERRAIN_TEXTURE := "res://assets/tilesets/candidates/world-terrain-v004.png"
const OBJECT_TEXTURE := "res://assets/tilesets/world-objects-v005.png"
const OBJECT_METADATA := "res://assets/tilesets/world-objects-v005.json"
const OUTPUT_TILESET := "res://resources/tilesets/world-foundation-v001.tres"
const TILE_SIZE := Vector2i(32, 32)
const TERRAIN_GRID := Vector2i(8, 8)


func _initialize() -> void:
	var terrain_texture := load(TERRAIN_TEXTURE) as Texture2D
	var technical_terrain_texture := load(TECHNICAL_TERRAIN_TEXTURE) as Texture2D
	var object_texture := load(OBJECT_TEXTURE) as Texture2D
	var metadata = JSON.parse_string(FileAccess.get_file_as_string(OBJECT_METADATA))
	if terrain_texture == null or technical_terrain_texture == null or object_texture == null or not metadata is Dictionary:
		push_error("Impossible de charger les entrées du TileSet de fondation.")
		quit(1)
		return
	var tile_set := _new_tile_set()
	_build_terrain_source(tile_set, terrain_texture)
	var collision_count := _build_object_source(tile_set, object_texture, metadata)
	_build_technical_terrain_source(tile_set, technical_terrain_texture)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_TILESET.get_base_dir()))
	var error := ResourceSaver.save(tile_set, OUTPUT_TILESET)
	if error != OK:
		push_error("Impossible d'enregistrer %s : %s" % [OUTPUT_TILESET, error_string(error)])
		quit(1)
		return
	print("TileSet fondation : 64 terrains détaillés, 256 terrains techniques, %d objets nommés, %d empreintes physiques." % [
		int(metadata["sprite_count"]), collision_count,
	])
	quit()


func _new_tile_set() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
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
	]:
		var index := tile_set.get_custom_data_layers_count()
		tile_set.add_custom_data_layer(index)
		tile_set.set_custom_data_layer_name(index, definition[0])
		tile_set.set_custom_data_layer_type(index, definition[1])
	return tile_set


func _build_terrain_source(tile_set: TileSet, texture: Texture2D) -> void:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = TILE_SIZE
	for y in range(TERRAIN_GRID.y):
		for x in range(TERRAIN_GRID.x):
			atlas.create_tile(Vector2i(x, y))
	tile_set.add_source(atlas, 0)
	for y in range(TERRAIN_GRID.y):
		for x in range(TERRAIN_GRID.x):
			var coordinates := Vector2i(x, y)
			var data := atlas.get_tile_data(coordinates, 0)
			var kind := _terrain_kind(coordinates)
			_set_common_data(data, "terrain.%s.%02d_%02d" % [kind, x, y], "terrain/%s" % kind)
			data.set_custom_data("terrain_kind", kind)
			data.set_custom_data("footstep_kind", _terrain_footstep(kind))


func _build_object_source(tile_set: TileSet, texture: Texture2D, metadata: Dictionary) -> int:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = TILE_SIZE
	for sprite in metadata["sprites"]:
		atlas.create_tile(_v2i(sprite["atlas_coordinates"]), _v2i(sprite["size_in_cells"]))
	tile_set.add_source(atlas, 1)
	var collision_count := 0
	for sprite in metadata["sprites"]:
		var data := atlas.get_tile_data(_v2i(sprite["atlas_coordinates"]), 0)
		_set_common_data(data, str(sprite["id"]), str(sprite["group"]))
		if str(sprite.get("anchor_kind", "foot")) == "foot":
			var region_size := _v2i(sprite["region_size_px"])
			var foot_anchor := _v2i(sprite["foot_anchor_px"])
			data.texture_origin = Vector2i(region_size.x / 2, region_size.y / 2) - foot_anchor
		var role := str(sprite["default_role"])
		data.set_custom_data("traversal", _traversal_for_role(role))
		data.set_custom_data("interaction_kind", _interaction_for_role(role))
		data.set_custom_data("footstep_kind", "")
		data.set_custom_data("blocks_vision", role in ["building_with_entrance", "solid_footprint"] and str(sprite["group"]).begins_with("architecture/"))
		if role == "building_with_entrance":
			_add_building_entrance_collision(data, _v2i(sprite["region_size_px"]))
			collision_count += 1
		elif role in ["solid_footprint", "solid_interactable", "small_obstacle", "tree_trunk_obstacle"]:
			_add_foot_collision(data, _v2i(sprite["region_size_px"]), _v2i(sprite["content_size_px"]), role)
			collision_count += 1
	return collision_count


func _build_technical_terrain_source(tile_set: TileSet, texture: Texture2D) -> void:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = TILE_SIZE
	for y in range(16):
		for x in range(16):
			atlas.create_tile(Vector2i(x, y))
	tile_set.add_source(atlas, 2)
	for y in range(16):
		for x in range(16):
			var data := atlas.get_tile_data(Vector2i(x, y), 0)
			var kind := _technical_terrain_kind(x, y)
			_set_common_data(data, "technical.%s.%02d_%02d" % [kind, x, y], "technical/%s" % kind)
			data.set_custom_data("terrain_kind", kind)
			data.set_custom_data("footstep_kind", _terrain_footstep(kind))
			if kind in ["water", "cliff", "wall", "fence", "roof"]:
				data.set_custom_data("traversal", "blocked")


func _technical_terrain_kind(x: int, y: int) -> String:
	if y == 0:
		return ["grass", "dirt_path", "stone", "water"][x / 4]
	return [
		"base", "dirt_path", "stone", "water", "cultivated_soil", "cliff",
		"bridge", "fence", "wall", "roof", "vegetation", "decor", "prop",
		"wood_floor", "water_effect", "utility",
	][y]


func _set_common_data(data: TileData, asset_id: String, group: String) -> void:
	data.set_custom_data("asset_id", asset_id)
	data.set_custom_data("asset_group", group)
	data.set_custom_data("height_level", 0)
	data.set_custom_data("traversal", "walk")
	data.set_custom_data("movement_cost", 1.0)
	data.set_custom_data("footstep_kind", "grass")
	data.set_custom_data("interaction_kind", "none")
	data.set_custom_data("blocks_vision", false)


func _terrain_kind(coordinates: Vector2i) -> String:
	if coordinates.y <= 1:
		return "grass" if coordinates == Vector2i.ZERO else "dirt_path"
	if coordinates.y <= 3:
		return "cultivated_soil"
	return "stone"


func _terrain_footstep(kind: String) -> String:
	match kind:
		"dirt_path", "cultivated_soil": return "earth"
		"stone": return "stone"
		_: return "grass"


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


func _add_foot_collision(data: TileData, region_size: Vector2i, content_size: Vector2i, role: String) -> void:
	var width_factor := 0.22 if role == "tree_trunk_obstacle" else 0.62
	var half_width := minf(float(content_size.x) * width_factor * 0.5, float(region_size.x) * 0.4)
	half_width = maxf(half_width, 7.0)
	var bottom := 10.0
	var collision_height := 16.0 if role in ["tree_trunk_obstacle", "small_obstacle"] else 24.0
	var top := bottom - collision_height
	data.set_collision_polygons_count(0, 1)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-half_width, top), Vector2(half_width, top),
		Vector2(half_width, bottom), Vector2(-half_width, bottom),
	]))


func _v2i(values: Array) -> Vector2i:
	return Vector2i(int(values[0]), int(values[1]))
