extends SceneTree

const Converter = preload("res://editor/tiled/tiled_converter.gd")
const Profile = preload("res://editor/tiled/rpg_tiled_profile.gd")
const TEMPLATE := "res://maps/templates/rpg-map-template.tmx"


func _initialize() -> void:
	var parsed := Converter._parse_tmx(TEMPLATE)
	assert(not parsed.is_empty(), "Le gabarit Tiled est illisible")
	assert(parsed.layers.size() == 25, "25 calques visuels attendus dans le gabarit RPG détaillé")
	assert(parsed.object_groups.size() == 17, "6 calques d'objets et 11 calques gameplay attendus")
	assert(parsed.tilesets.size() >= 12, "Le gabarit doit exposer les familles communes de terrain et d'objets")
	var tile_set := load(Profile.TILESET_PATH) as TileSet
	assert(tile_set != null, "TileSet Godot canonique absent")
	assert(Converter._bind_canonical_tile_set(TEMPLATE, parsed, tile_set) == OK)
	assert(parsed.runtime_tilesets.size() == parsed.tilesets.size())
	for index in range(parsed.runtime_tilesets.size()):
		var definition: Dictionary = parsed.runtime_tilesets[index]
		var gid := int(definition.first_gid)
		parsed.layers[0].data[index] = gid
		var resolved := Converter._resolve_gid(gid, parsed.runtime_tilesets)
		assert(int(resolved.source_id) == int(definition.source_id), "Mauvaise source Godot pour le TSX %d" % index)
	assert(int(parsed.properties.traversal_contract_version) == 1)
	assert(int(parsed.properties.camera_contract_version) == 1)
	var playable := Converter._parse_tmx("res://maps/source/vallee-des-sources.tmx")
	assert(Converter._bind_canonical_tile_set("res://maps/source/vallee-des-sources.tmx", playable, tile_set) == OK)
	assert(Converter._validate_map("res://maps/source/vallee-des-sources.tmx", playable, tile_set) == OK)
	var object_gid := _first_gid_for_tileset(parsed, "world_objects.tsx")
	assert(object_gid > 0, "La bibliothèque d'objets du monde est absente")
	var object_resolved := Converter._resolve_gid(object_gid, parsed.runtime_tilesets)
	assert(int(object_resolved.source_id) == 20)
	assert(object_resolved.atlas_coords == Vector2i(0, 7))
	assert(str(object_resolved.metadata.object_id) == "boundary.fence_wood_long")
	var boundary_objects: Dictionary = _object_group(parsed, "BoundaryObjects")
	var height_zones: Dictionary = _object_group(parsed, "HeightZones")
	var collision_overrides: Dictionary = _object_group(parsed, "CollisionOverrides")
	var spawn_points: Dictionary = _object_group(parsed, "SpawnPoints")
	assert(not boundary_objects.is_empty())
	assert(not height_zones.is_empty())
	assert(not collision_overrides.is_empty())
	assert(not spawn_points.is_empty())
	boundary_objects.objects.append({
		"id": 4, "name": "FenceLong", "class": "", "shape": "rectangle", "gid": object_gid,
		"x": 224.0, "y": 192.0, "width": 192.0, "height": 91.0, "visible": true,
		"properties": {},
	})
	height_zones.objects.append({
		"id": 1, "name": "HeightPolygon", "class": "height_zone", "shape": "polygon",
		"x": 64.0, "y": 64.0, "width": 0.0, "height": 0.0, "visible": true,
		"points": PackedVector2Array([Vector2.ZERO, Vector2(96, 0), Vector2(96, 64), Vector2(0, 64)]),
		"properties": {"height_level": 1},
	})
	collision_overrides.objects.append({
		"id": 2, "name": "CliffPolyline", "class": "solid", "shape": "polyline",
		"x": 128.0, "y": 128.0, "width": 0.0, "height": 0.0, "visible": true,
		"points": PackedVector2Array([Vector2.ZERO, Vector2(64, 0), Vector2(64, 64)]),
		"properties": {},
	})
	spawn_points.objects.append({
		"id": 3, "name": "PlayerSpawn", "class": "player_spawn", "shape": "point",
		"x": 32.0, "y": 32.0, "width": 0.0, "height": 0.0, "visible": true,
		"properties": {},
	})
	var generated_path := "res://game/world/maps/generated/__verification.tscn"
	Converter._ensure_directory(Profile.GENERATED_SCENES_DIRECTORY)
	assert(Converter._build_scene(TEMPLATE, parsed, tile_set, Profile, generated_path) == OK)
	var packed := load(generated_path) as PackedScene
	assert(packed != null, "La scène Tiled générée est illisible")
	var level := packed.instantiate()
	for tile_layer in level.find_children("*", "TileMapLayer", true, false):
		if tile_layer.has_meta("source_tiled_group"):
			assert(not tile_layer.collision_enabled, "Un calque peint ne doit jamais décider de la traversabilité : %s" % tile_layer.name)
			assert(tile_layer.get_meta("collision_policy") == "visual_layer_collision_disabled")
	var fence := level.get_node_or_null("PlacedObjects/BoundaryObjects/FenceLong") as TileMapLayer
	assert(fence != null)
	assert(fence.get_cell_source_id(Vector2i.ZERO) == 20)
	assert(fence.get_cell_atlas_coords(Vector2i.ZERO) == Vector2i(0, 7))
	assert(str(fence.get_meta("object_id")) == "boundary.fence_wood_long")
	assert(level.get_node_or_null("Gameplay/HeightZones/HeightPolygon/CollisionPolygon2D") != null)
	assert(level.get_node_or_null("Gameplay/CollisionOverrides/CliffPolyline/Segment01") != null)
	assert(level.get_node_or_null("Gameplay/SpawnPoints/PlayerSpawn") is Marker2D)
	level.free()
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(generated_path)) == OK)
	print("Convertisseur Tiled vérifié : 25 calques, 17 groupes d'objets, %d TSX et géométries RPG fidèles." % parsed.tilesets.size())
	quit()


func _object_group(parsed: Dictionary, group_name: String) -> Dictionary:
	for candidate: Dictionary in parsed.object_groups:
		if str(candidate.get("name", "")) == group_name:
			return candidate
	return {}


func _first_gid_for_tileset(parsed: Dictionary, file_name: String) -> int:
	for definition: Dictionary in parsed.runtime_tilesets:
		if str(definition.get("tsx_path", "")).ends_with(file_name):
			return int(definition.get("first_gid", 0))
	return 0
