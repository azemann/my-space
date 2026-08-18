extends SceneTree

const TILESET_PATH := "res://game/world/tileset/world_tileset.tres"


func _initialize() -> void:
	assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "Largeur interne différente de 640 px")
	assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 360, "Hauteur interne différente de 360 px")
	assert(ProjectSettings.get_setting("display/window/size/window_width_override") == 1280, "Largeur de fenêtre différente de 1280 px")
	assert(ProjectSettings.get_setting("display/window/size/window_height_override") == 720, "Hauteur de fenêtre différente de 720 px")
	assert(ProjectSettings.get_setting("display/window/size/mode") == 3, "Le démarrage doit être en plein écran")
	assert(ProjectSettings.get_setting("display/window/stretch/mode") == "viewport", "Mode d'étirement incorrect")
	assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "expand", "Gestion du ratio incorrecte")
	assert(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "Agrandissement non entier")
	assert(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "Filtrage pixel art incorrect")
	var tile_set := load(TILESET_PATH) as TileSet
	assert(tile_set != null, "TileSet d'édition absent")
	assert(tile_set.tile_size == Vector2i(32, 32), "Grille différente de 32 px")
	assert(tile_set.get_source_count() == 21, "19 familles de terrain et 2 familles d'objets attendues")
	var terrain_tiles := 0
	for source_id in range(11):
		var source := tile_set.get_source(source_id) as TileSetAtlasSource
		assert(source != null and source.get_tiles_count() == 11, "Famille terrain incomplète : %d" % source_id)
		assert(not source.resource_name.is_empty(), "Famille terrain sans nom : %d" % source_id)
		for tile_index in range(source.get_tiles_count()):
			_assert_psychokinesis_profile(source.get_tile_data(source.get_tile_id(tile_index), 0))
		terrain_tiles += source.get_tiles_count()
	for source_id in range(11, 19):
		var source := tile_set.get_source(source_id) as TileSetAtlasSource
		assert(source != null and source.get_tiles_count() == 10, "Famille de plage incomplète : %d" % source_id)
		for tile_index in range(source.get_tiles_count()):
			_assert_psychokinesis_profile(source.get_tile_data(source.get_tile_id(tile_index), 0))
		terrain_tiles += source.get_tiles_count()
	for blocked_source_id in [13, 14, 15, 18]:
		var blocked_source := tile_set.get_source(blocked_source_id) as TileSetAtlasSource
		for tile_index in range(blocked_source.get_tiles_count()):
			var data := blocked_source.get_tile_data(blocked_source.get_tile_id(tile_index), 0)
			assert(data.get_collision_polygons_count(0) == 1, "Terrain bloqué sans collision par tuile : %d" % blocked_source_id)
	var objects := tile_set.get_source(20) as TileSetAtlasSource
	assert(objects != null and objects.get_tiles_count() == 71, "71 objets nommés attendus")
	var beach_objects := tile_set.get_source(21) as TileSetAtlasSource
	assert(beach_objects != null and beach_objects.get_tiles_count() == 30, "30 objets de plage nommés attendus")
	var bridge_has_rails := false
	for index in range(objects.get_tiles_count()):
		var atlas_coords := objects.get_tile_id(index)
		var data := objects.get_tile_data(atlas_coords, 0)
		_assert_psychokinesis_profile(data)
		if str(data.get_custom_data("asset_id")) == "traversal.bridge_wood_stone_long":
			bridge_has_rails = data.get_collision_polygons_count(0) == 2
			break
	assert(bridge_has_rails, "Le pont doit posséder deux garde-corps physiques")
	var practice_stone_found := false
	var precise_rock_collision_found := false
	for index in range(beach_objects.get_tiles_count()):
		var atlas_coords := beach_objects.get_tile_id(index)
		var data := beach_objects.get_tile_data(atlas_coords, 0)
		_assert_psychokinesis_profile(data)
		if str(data.get_custom_data("asset_id")) == "telekinesis.practice_stone":
			practice_stone_found = true
			assert(data.get_custom_data("psychokinesis_response") == "movable")
			assert(data.get_custom_data("psychokinesis_mass") == "light")
			assert(data.get_custom_data("psychokinesis_required_power") == 0)
		if str(data.get_custom_data("asset_id")) == "beach.boulder_heavy":
			precise_rock_collision_found = data.get_collision_polygon_points(0, 0).size() == 8
	assert(practice_stone_found, "La pierre d'apprentissage psychokinétique doit exister")
	assert(precise_rock_collision_found, "Le rocher lourd doit employer une empreinte octogonale précise")
	assert(terrain_tiles == 201, "201 terrains attendus")
	var custom_names: Array[String] = []
	for index in range(tile_set.get_custom_data_layers_count()):
		custom_names.append(tile_set.get_custom_data_layer_name(index))
	assert("description" in custom_names, "Descriptions de placement absentes")
	assert("recommended_layer" in custom_names, "Conseils de calque absents")
	print("TileSet éditeur vérifié : 201 terrains classés + 101 objets, grille 32 px.")
	quit()


func _assert_psychokinesis_profile(data: TileData) -> void:
	assert(str(data.get_custom_data("psychokinesis_response")) in ["anchored", "reactive", "movable"])
	assert(str(data.get_custom_data("psychokinesis_mass")) in ["light", "medium", "heavy", "immense"])
	assert(not str(data.get_custom_data("psychokinesis_material")).is_empty())
	assert(int(data.get_custom_data("psychokinesis_required_power")) >= 0)
