extends SceneTree

const TILESET_PATH := "res://resources/tilesets/world-foundation-v001.tres"
const OBJECT_METADATA := "res://assets/tilesets/world-objects-v005.json"
const PLAYER_SCENE := preload("res://game/actors/player/player_probe.tscn")
const PORTAL_SCRIPT := preload("res://game/world/components/scene_portal.gd")
const WORLD_SCRIPT := preload("res://game/world/components/world_spawn.gd")
const WORLD_PATH := "res://game/world/scenes/scene_001_world_lab/scene_001_world_lab.tscn"
const INTERIOR_PATH := "res://game/world/scenes/interiors/house_001/house_001.tscn"
const TILE := 32
const WORLD_SIZE := Vector2i(40, 28)

var _tile_set: TileSet
var _assets := {}


func _initialize() -> void:
	_tile_set = load(TILESET_PATH) as TileSet
	var metadata = JSON.parse_string(FileAccess.get_file_as_string(OBJECT_METADATA))
	if _tile_set == null or not metadata is Dictionary:
		push_error("Entrées du laboratoire introuvables.")
		quit(1)
		return
	for sprite in metadata["sprites"]:
		_assets[str(sprite["id"])] = {
			"coordinates": Vector2i(int(sprite["atlas_coordinates"][0]), int(sprite["atlas_coordinates"][1])),
			"size": Vector2i(int(sprite["size_in_cells"][0]), int(sprite["size_in_cells"][1])),
		}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(INTERIOR_PATH.get_base_dir()))
	var world_error := _save_scene(_build_world(), WORLD_PATH)
	var interior_error := _save_scene(_build_interior(), INTERIOR_PATH)
	if world_error != OK or interior_error != OK:
		push_error("Échec d'enregistrement : monde=%s intérieur=%s" % [error_string(world_error), error_string(interior_error)])
		quit(1)
		return
	print("Laboratoire rempli : terrain, rivière, pont, falaise, escalier, maison, intérieur et joueur-probe.")
	quit()


func _build_world() -> Node2D:
	var root := Node2D.new()
	root.name = "Scene001WorldLab"
	root.script = WORLD_SCRIPT
	root.editor_description = "Laboratoire jouable du monde extérieur. Généré par build_world_lab.gd depuis des composants nommés."
	var map := _node(root, "Map", "Composition visible et éditable dans Godot.", root)
	var terrain := _node(map, "Terrain", "Sols sans autorité implicite sur le gameplay.", root)
	var ground := _layer(terrain, "Ground", "Sol continu.", root)
	var variations := _layer(terrain, "GroundVariations", "Variantes discrètes.", root)
	var paths := _layer(terrain, "Paths", "Chemins raccordables.", root)
	var farm := _layer(terrain, "CultivatedSoil", "Potager de démonstration.", root)
	var stone := _layer(terrain, "StoneFloors", "Cour pavée.", root)
	var water := _node(map, "Water", "Eau visuelle ; collisions dans Gameplay.", root)
	var water_base := _layer(water, "WaterBase", "Rivière principale.", root)
	var water_banks := _layer(water, "WaterBanks", "Berges à compléter avec le lot eau.", root)
	var water_effects := _layer(water, "WaterEffects", "Plantes et détails aquatiques.", root)
	var relief := _node(map, "Relief", "Différences de hauteur visuelles.", root)
	var cliff_back := _layer(relief, "CliffBack", "Rebord supérieur.", root)
	var cliff_faces := _layer(relief, "CliffFaces", "Face bloquante de la falaise.", root)
	var cliff_front := _layer(relief, "CliffFront", "Rebord de premier plan.", root)
	var stairs := _layer(relief, "Stairs", "Passage visuel entre hauteurs.", root)
	var architecture := _node(map, "Architecture", "Structures du laboratoire.", root)
	var bridges := _layer(architecture, "Bridges", "Pont au-dessus de la rivière.", root)
	var buildings := _layer(architecture, "Buildings", "Maison extérieure.", root, true)
	var fences := _layer(architecture, "Fences", "Enclos de démonstration.", root, true)
	var decoration := _node(map, "Decoration", "Décor sans règle implicite.", root)
	var ground_decor := _layer(decoration, "GroundDecor", "Fleurs et galets.", root)
	var y_sorted := _layer(decoration, "YSortedProps", "Arbres et obstacles ancrés au sol.", root, true)
	var canopy := _layer(decoration, "Canopy", "Réservé aux canopées séparées.", root)

	for y in range(WORLD_SIZE.y):
		for x in range(WORLD_SIZE.x):
			ground.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
	# Un axe principal relie la maison, la place et le pont. Le chemin vertical
	# conduit réellement à l'escalier et au plateau au lieu de couper la carte.
	for x in range(WORLD_SIZE.x):
		paths.set_cell(Vector2i(x, 18), 0, Vector2i(3, 0))
	for y in range(WORLD_SIZE.y):
		paths.set_cell(Vector2i(18, y), 0, Vector2i(1, 0))
	paths.set_cell(Vector2i(18, 18), 0, Vector2i(0, 1))
	for x in range(8, 19):
		paths.set_cell(Vector2i(x, 17), 0, Vector2i(3, 0))
	for y in range(4, 10):
		for x in range(3, 11):
			farm.set_cell(Vector2i(x, y), 0, Vector2i((x + y) % 8, 3))
	for y in range(13, 18):
		for x in range(13, 22):
			stone.set_cell(Vector2i(x, y), 0, Vector2i((x + y) % 8, 4 + (x + y) % 4))
	for y in range(WORLD_SIZE.y):
		for x in range(26, 30):
			water_base.set_cell(Vector2i(x, y), 2, Vector2i(12 + (x + y) % 4, 0))
	for x in range(13, 24):
		if x < 17 or x > 19:
			cliff_faces.set_cell(Vector2i(x, 10), 2, Vector2i(15, 5))
	for x in range(13, 24):
		variations.set_cell(Vector2i(x, 4), 0, Vector2i.ZERO)

	_place(bridges, "traversal.bridge_wood_stone_long", Vector2i(28, 18))
	_place(stairs, "traversal.stairs_stone_north", Vector2i(18, 10))
	_place(buildings, "building.cottage_exterior", Vector2i(8, 18))
	_place(fences, "boundary.fence_wood_long", Vector2i(6, 3))
	_place(fences, "boundary.fence_wood_long", Vector2i(6, 11))
	_place(fences, "boundary.gate_wood_closed", Vector2i(11, 9))

	for placement in [
		["vegetation.tree_pine_xl", Vector2i(2, 5)],
		["vegetation.tree_pine_large", Vector2i(12, 4)],
		["vegetation.tree_pine_medium_a", Vector2i(2, 13)],
		["vegetation.tree_pine_medium_b", Vector2i(4, 25)],
		["vegetation.tree_pine_xl", Vector2i(12, 26)],
		["vegetation.tree_pine_large", Vector2i(22, 26)],
		["vegetation.tree_pine_xl", Vector2i(34, 4)],
		["vegetation.tree_pine_medium_a", Vector2i(38, 8)],
		["vegetation.tree_pine_large", Vector2i(35, 14)],
		["vegetation.tree_pine_medium_b", Vector2i(38, 21)],
		["vegetation.tree_pine_xl", Vector2i(33, 26)],
		["vegetation.bush_round_a", Vector2i(5, 23)],
		["vegetation.bush_round_b", Vector2i(14, 23)],
		["vegetation.bush_round_c", Vector2i(33, 10)],
		["vegetation.bush_round_d", Vector2i(36, 24)],
		["obstacle.boulder_cluster_large", Vector2i(33, 20)],
		["obstacle.boulder_cluster_medium", Vector2i(23, 7)],
		["obstacle.rock_small", Vector2i(31, 7)],
		["prop.well_stone_round", Vector2i(16, 16)],
		["prop.signpost_wood", Vector2i(23, 18)],
		["prop.barrel_water", Vector2i(11, 18)],
	]:
		_place(y_sorted, placement[0], placement[1])

	for placement in [
		["farm.crop_cabbages", Vector2i(5, 6)],
		["farm.crop_carrots_a", Vector2i(8, 6)],
		["farm.crop_sprouts_a", Vector2i(5, 9)],
		["farm.crop_carrots_b", Vector2i(9, 9)],
		["decor.flower_cluster_pink_a", Vector2i(11, 14)],
		["decor.flower_cluster_blue_a", Vector2i(22, 12)],
		["decor.flower_cluster_white_a", Vector2i(24, 22)],
		["decor.flower_cluster_yellow_a", Vector2i(32, 16)],
		["decor.grass_tuft_a", Vector2i(15, 21)],
		["decor.grass_tuft_b", Vector2i(22, 4)],
		["decor.pebbles_cluster_large", Vector2i(31, 23)],
		["decor.pebbles_cluster_small", Vector2i(24, 6)],
	]:
		_place(ground_decor, placement[0], placement[1])

	for placement in [
		["water.lily_pad_medium", Vector2i(27, 23)],
		["water.lily_pad_small", Vector2i(29, 8)],
		["water.lotus_pink", Vector2i(27, 5)],
		["water.cattails_cluster_a", Vector2i(26, 12)],
		["water.cattails_cluster_b", Vector2i(29, 25)],
	]:
		_place(water_effects, placement[0], placement[1])
	_place(cliff_front, "relief.cliff_pillar_medium", Vector2i(14, 10))
	_place(cliff_front, "relief.cliff_pillar_tall", Vector2i(22, 10))

	var gameplay := _node(root, "Gameplay", "Autorité invisible du laboratoire.", root)
	var height_zones := _node(gameplay, "HeightZones", "Plateau niveau 1 et sol niveau 0.", root)
	_add_area(height_zones, "PlateauHeight1", Vector2(13 * TILE, 3 * TILE), Vector2(11 * TILE, 7 * TILE), root, null, {"height_level": 1})
	var transitions := _node(gameplay, "ElevationTransitions", "L'escalier est le seul lien entre niveaux.", root)
	_add_area(transitions, "StairsLevel0To1", Vector2(17 * TILE, 9 * TILE), Vector2(3 * TILE, 3 * TILE), root, null, {"from_level": 0, "to_level": 1})
	var collisions := _node(gameplay, "CollisionOverrides", "Eau, falaise, pont et limites.", root)
	_add_world_collisions(collisions, root)
	_node(gameplay, "Navigation", "Sera construite après validation physique.", root)
	var entrances := _node(gameplay, "Entrances", "Accès vers les intérieurs.", root)
	_add_portal(entrances, "CottageEntrance", Vector2(8 * TILE - 19, 18 * TILE - 14), Vector2(38, 28), INTERIOR_PATH, "entry", root)
	_node(gameplay, "Exits", "Sorties futures du laboratoire.", root)
	_node(gameplay, "Interactions", "Interactions locales futures.", root)
	var spawns := _node(gameplay, "SpawnPoints", "Points d'apparition nommés.", root)
	_add_marker(spawns, "default", Vector2(19 * TILE, 18 * TILE), root)
	_add_marker(spawns, "house_exit", Vector2(8 * TILE, 19 * TILE), root)
	var actors := _node(root, "SceneActors", "Acteurs présents dans la scène.", root)
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = Vector2(19 * TILE, 18 * TILE)
	player.set("camera_limits", Rect2(Vector2.ZERO, Vector2(WORLD_SIZE * TILE)))
	_add_owned(actors, player, root)
	_node(root, "SceneEffects", "Effets locaux.", root)
	_node(root, "SceneLogic", "Logique propre au laboratoire.", root, Node.new())
	_add_debug_ui(root, "LAB RPG — Flèches : déplacement   Entrée/Espace : porte", root)
	return root


func _build_interior() -> Node2D:
	var root := Node2D.new()
	root.name = "House001Interior"
	root.script = WORLD_SCRIPT
	root.editor_description = "Premier intérieur minimal, séparé de la maison extérieure."
	var map := _node(root, "Map", "Carte intérieure.", root)
	var terrain := _node(map, "Terrain", "Sol intérieur.", root)
	var floors := _layer(terrain, "StoneFloors", "Sol provisoire de l'intérieur.", root)
	for y in range(2, 11):
		for x in range(2, 14):
			floors.set_cell(Vector2i(x, y), 0, Vector2i((x + y) % 8, 4 + (x + y) % 4))
	var gameplay := _node(root, "Gameplay", "Gameplay intérieur.", root)
	var collisions := _node(gameplay, "CollisionOverrides", "Murs de la pièce avec ouverture au sud.", root)
	_add_rect_body(collisions, "NorthWall", Vector2(2 * TILE, 2 * TILE), Vector2(12 * TILE, TILE), root)
	_add_rect_body(collisions, "WestWall", Vector2(2 * TILE, 2 * TILE), Vector2(TILE, 9 * TILE), root)
	_add_rect_body(collisions, "EastWall", Vector2(13 * TILE, 2 * TILE), Vector2(TILE, 9 * TILE), root)
	_add_rect_body(collisions, "SouthWallLeft", Vector2(2 * TILE, 10 * TILE), Vector2(5 * TILE, TILE), root)
	_add_rect_body(collisions, "SouthWallRight", Vector2(9 * TILE, 10 * TILE), Vector2(5 * TILE, TILE), root)
	var exits := _node(gameplay, "Exits", "Retour vers l'extérieur.", root)
	_add_portal(exits, "ExteriorDoor", Vector2(8 * TILE, 10.2 * TILE), Vector2(64, 28), WORLD_PATH, "house_exit", root)
	var spawns := _node(gameplay, "SpawnPoints", "Points d'arrivée intérieurs.", root)
	_add_marker(spawns, "entry", Vector2(8 * TILE, 9 * TILE), root)
	var actors := _node(root, "SceneActors", "Acteurs intérieurs.", root)
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = Vector2(8 * TILE, 7 * TILE)
	player.set("camera_limits", Rect2(Vector2(2 * TILE, 2 * TILE), Vector2(12 * TILE, 9 * TILE)))
	_add_owned(actors, player, root)
	_add_debug_ui(root, "INTÉRIEUR — Entrée/Espace devant la sortie", root)
	return root


func _add_world_collisions(parent: Node, owner: Node) -> void:
	_add_rect_body(parent, "NorthBoundary", Vector2.ZERO, Vector2(WORLD_SIZE.x * TILE, TILE), owner)
	_add_rect_body(parent, "SouthBoundary", Vector2(0, (WORLD_SIZE.y - 1) * TILE), Vector2(WORLD_SIZE.x * TILE, TILE), owner)
	_add_rect_body(parent, "WestBoundary", Vector2.ZERO, Vector2(TILE, WORLD_SIZE.y * TILE), owner)
	_add_rect_body(parent, "EastBoundary", Vector2((WORLD_SIZE.x - 1) * TILE, 0), Vector2(TILE, WORLD_SIZE.y * TILE), owner)
	_add_rect_body(parent, "RiverNorth", Vector2(26 * TILE, 0), Vector2(4 * TILE, 16 * TILE), owner)
	_add_rect_body(parent, "RiverSouth", Vector2(26 * TILE, 20 * TILE), Vector2(4 * TILE, 8 * TILE), owner)
	_add_rect_body(parent, "BridgeNorthRail", Vector2(24 * TILE, 16 * TILE), Vector2(8 * TILE, 10), owner)
	_add_rect_body(parent, "BridgeSouthRail", Vector2(24 * TILE, 20 * TILE - 10), Vector2(8 * TILE, 10), owner)
	_add_rect_body(parent, "PlateauNorth", Vector2(13 * TILE, 3 * TILE), Vector2(11 * TILE, TILE), owner)
	_add_rect_body(parent, "PlateauWest", Vector2(13 * TILE, 3 * TILE), Vector2(TILE, 8 * TILE), owner)
	_add_rect_body(parent, "PlateauEast", Vector2(23 * TILE, 3 * TILE), Vector2(TILE, 8 * TILE), owner)
	_add_rect_body(parent, "CliffSouthLeft", Vector2(13 * TILE, 10 * TILE), Vector2(4 * TILE, TILE), owner)
	_add_rect_body(parent, "CliffSouthRight", Vector2(20 * TILE, 10 * TILE), Vector2(4 * TILE, TILE), owner)


func _node(parent: Node, name: String, description: String, owner: Node, custom: Node = null) -> Node:
	var node := custom if custom != null else Node2D.new()
	node.name = name
	node.editor_description = description
	_add_owned(parent, node, owner)
	return node


func _layer(parent: Node, name: String, description: String, owner: Node, y_sort := false) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = name
	layer.tile_set = _tile_set
	layer.y_sort_enabled = y_sort
	layer.editor_description = description
	_add_owned(parent, layer, owner)
	return layer


func _place(layer: TileMapLayer, asset_id: String, cell: Vector2i) -> void:
	assert(_assets.has(asset_id), "Asset absent : %s" % asset_id)
	layer.set_cell(cell, 1, _assets[asset_id]["coordinates"])


func _add_rect_body(parent: Node, name: String, position: Vector2, size: Vector2, owner: Node) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = name
	body.position = position
	_add_owned(parent, body, owner)
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = size * 0.5
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	_add_owned(body, collision, owner)
	return body


func _add_area(parent: Node, name: String, position: Vector2, size: Vector2, owner: Node, script: Script = null, metadata := {}) -> Area2D:
	var area := Area2D.new()
	area.name = name
	area.position = position
	area.collision_layer = 2
	area.collision_mask = 1
	if script != null:
		area.script = script
	for key in metadata:
		area.set_meta(str(key), metadata[key])
	_add_owned(parent, area, owner)
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = size * 0.5
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	_add_owned(area, collision, owner)
	return area


func _add_portal(parent: Node, name: String, position: Vector2, size: Vector2, destination: String, spawn: String, owner: Node) -> void:
	var portal := _add_area(parent, name, position, size, owner, PORTAL_SCRIPT)
	portal.set("destination_scene", destination)
	portal.set("destination_spawn", spawn)
	portal.editor_description = "Porte vers %s, arrivée %s." % [destination, spawn]


func _add_marker(parent: Node, name: String, position: Vector2, owner: Node) -> void:
	var marker := Marker2D.new()
	marker.name = name
	marker.position = position
	_add_owned(parent, marker, owner)


func _add_debug_ui(parent: Node, message: String, owner: Node) -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "LabUI"
	_add_owned(parent, canvas, owner)
	var panel := ColorRect.new()
	panel.name = "InstructionBackground"
	panel.position = Vector2(12, 12)
	panel.size = Vector2(540, 34)
	panel.color = Color(0.03, 0.05, 0.06, 0.78)
	_add_owned(canvas, panel, owner)
	var label := Label.new()
	label.name = "Instructions"
	label.position = Vector2(22, 20)
	label.text = message
	label.add_theme_color_override("font_color", Color("f3e4bd"))
	_add_owned(canvas, label, owner)


func _add_owned(parent: Node, child: Node, owner: Node) -> void:
	parent.add_child(child)
	child.owner = owner


func _save_scene(root: Node, path: String) -> Error:
	var packed := PackedScene.new()
	var pack_error := packed.pack(root)
	if pack_error != OK:
		root.free()
		return pack_error
	var save_error := ResourceSaver.save(packed, path)
	root.free()
	return save_error
