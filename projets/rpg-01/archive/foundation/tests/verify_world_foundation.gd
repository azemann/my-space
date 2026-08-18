extends SceneTree

const TILESET_PATH := "res://resources/tilesets/world-foundation-v001.tres"
const WORLD_LAB_PATH := "res://game/world/scenes/scene_001_world_lab/scene_001_world_lab.tscn"
const EXPECTED_CUSTOM_DATA := [
	"asset_id", "asset_group", "terrain_kind", "height_level", "traversal",
	"movement_cost", "footstep_kind", "interaction_kind", "blocks_vision",
]


func _initialize() -> void:
	assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "Largeur logique différente de 640 px")
	assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 360, "Hauteur logique différente de 360 px")
	assert(ProjectSettings.get_setting("display/window/stretch/mode") == "viewport", "Mode d'étirement incorrect")
	assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "expand", "Gestion du ratio incorrecte")
	assert(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "Agrandissement non entier")
	assert(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "Filtrage pixel art incorrect")
	var tile_set := load(TILESET_PATH) as TileSet
	assert(tile_set != null, "TileSet absent")
	assert(tile_set.tile_size == Vector2i(32, 32), "Grille différente de 32 px")
	assert(tile_set.get_source_count() == 3, "Trois sources attendues : terrain détaillé, objets et terrain technique")
	var names: Array[String] = []
	for index in range(tile_set.get_custom_data_layers_count()):
		names.append(tile_set.get_custom_data_layer_name(index))
	assert(names == EXPECTED_CUSTOM_DATA, "Contrat de données personnalisées incorrect")
	var terrain := tile_set.get_source(0) as TileSetAtlasSource
	var objects := tile_set.get_source(1) as TileSetAtlasSource
	var technical := tile_set.get_source(2) as TileSetAtlasSource
	assert(terrain != null and terrain.get_tiles_count() == 64, "64 tuiles terrain attendues")
	assert(objects != null and objects.get_tiles_count() == 71, "71 objets nommés attendus")
	assert(technical != null and technical.get_tiles_count() == 256, "256 tuiles techniques attendues")
	assert(terrain.get_tile_data(Vector2i.ZERO, 0).get_custom_data("terrain_kind") == "grass")
	var required := {
		"building.cottage_exterior": false,
		"traversal.bridge_wood_stone_long": false,
		"traversal.stairs_stone_north": false,
		"vegetation.tree_pine_xl": false,
	}
	var object_tiles := {}
	for index in range(objects.get_tiles_count()):
		var coordinates := objects.get_tile_id(index)
		var tile_data := objects.get_tile_data(coordinates, 0)
		var asset_id := str(tile_data.get_custom_data("asset_id"))
		if required.has(asset_id):
			required[asset_id] = true
			object_tiles[asset_id] = tile_data
	for asset_id in required:
		assert(required[asset_id], "Objet requis absent : %s" % asset_id)
	assert((object_tiles["building.cottage_exterior"] as TileData).texture_origin.y < 0, "La maison doit être ancrée par son seuil")
	assert((object_tiles["vegetation.tree_pine_xl"] as TileData).texture_origin.y < 0, "L'arbre doit être ancré par son pied")
	assert((object_tiles["traversal.bridge_wood_stone_long"] as TileData).texture_origin == Vector2i.ZERO, "Le pont doit rester centré sur sa traversée")
	var packed_scene := load(WORLD_LAB_PATH) as PackedScene
	assert(packed_scene != null, "Scène laboratoire absente")
	var world_lab := packed_scene.instantiate()
	for required_path in [
		"Map/Terrain/Ground", "Map/Terrain/Paths", "Map/Water/WaterBase",
		"Map/Relief/CliffFaces", "Map/Relief/Stairs", "Map/Architecture/Bridges",
		"Map/Architecture/Buildings", "Map/Decoration/YSortedProps",
		"Gameplay/HeightZones", "Gameplay/ElevationTransitions",
		"Gameplay/CollisionOverrides", "Gameplay/Entrances", "Gameplay/SpawnPoints",
	]:
		assert(world_lab.get_node_or_null(required_path) != null, "Branche absente : %s" % required_path)
	assert((world_lab.get_node("Map/Terrain/Ground") as TileMapLayer).get_used_cells().size() == 40 * 28)
	assert(not (world_lab.get_node("Map/Water/WaterBase") as TileMapLayer).get_used_cells().is_empty())
	assert(not (world_lab.get_node("Map/Architecture/Bridges") as TileMapLayer).get_used_cells().is_empty())
	assert(not (world_lab.get_node("Map/Architecture/Buildings") as TileMapLayer).get_used_cells().is_empty())
	assert(world_lab.get_node_or_null("SceneActors/PlayerProbe") != null)
	world_lab.free()
	var interior := load("res://game/world/scenes/interiors/house_001/house_001.tscn") as PackedScene
	assert(interior != null, "Intérieur de maison absent")
	print("Fondation vérifiée : 320 terrains, 71 objets, 9 données, laboratoire rempli et intérieur séparé.")
	quit()
