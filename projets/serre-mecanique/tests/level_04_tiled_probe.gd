extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const SOURCE := "res://maps/niveau-04-arene-parcours.tmx"
const TSX := "res://assets/tilesets/niveau-04-arene-combat-32x32-v001.tsx"
const TEXTURE := "res://assets/tilesets/niveau-04-arene-combat-32x32-v001.png"
const SCENE := "res://scenes/levels/niveau-04-arene-parcours.tscn"
const LAUNCHER := "res://scenes/launchers/niveau-04.tscn"


func _pixel(image: Image, tile_id: int, x: int, y: int) -> Color:
	return image.get_pixel((tile_id % 16) * 32 + x, floori(tile_id / 16.0) * 32 + y)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var parsed := Converter._parse_tmx(SOURCE)
	if str(parsed.get("tileset_source", "")) != "../assets/tilesets/niveau-04-arene-combat-32x32-v001.tsx":
		push_error("Le niveau 4 n'utilise pas le nouveau tileset d'arène.")
		failures += 1
	if parsed.layers.size() != 8 or parsed.object_groups.size() != 8:
		push_error("L'arène doit contenir 8 calques visuels et 8 calques d'objets.")
		failures += 1
	if str(parsed.properties.get("level_mode", "")) != "arena" or int(parsed.properties.get("max_players", 0)) != 4:
		push_error("Les propriétés multijoueur de la carte Tiled sont absentes.")
		failures += 1

	var tileset := Converter._parse_external_tileset(TSX)
	if int(tileset.get("columns", 0)) != 16 or int(tileset.get("rows", 0)) != 5:
		push_error("Le TSX du niveau 4 n'est pas une grille 16 × 5.")
		failures += 1
	if str(tileset.get("texture_path", "")) != TEXTURE:
		push_error("Le TSX ne pointe pas vers le PNG du nouveau jeu de tuiles.")
		failures += 1

	var atlas := Image.load_from_file(ProjectSettings.globalize_path(TEXTURE))
	var rgb_seams := 0
	for tile_id in [0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 26]:
		for y in range(32):
			if _pixel(atlas, tile_id, 0, y) != _pixel(atlas, tile_id, 1, y):
				rgb_seams += 1
			if _pixel(atlas, tile_id, 30, y) != _pixel(atlas, tile_id, 31, y):
				rgb_seams += 1
	for pair in [[0, 1], [1, 0], [3, 4], [4, 3], [26, 26]]:
		for y in range(32):
			if _pixel(atlas, pair[0], 31, y) != _pixel(atlas, pair[1], 0, y):
				rgb_seams += 1
	for left_id in [40, 41]:
		var right_id := 41 if left_id == 40 else 42
		for y in range(15, 24):
			if _pixel(atlas, left_id, 31, y) != _pixel(atlas, right_id, 0, y):
				rgb_seams += 1
	for tile_id in [37, 38, 39]:
		for x in range(32):
			if _pixel(atlas, tile_id, x, 31) != _pixel(atlas, tile_id, x, 0):
				rgb_seams += 1
	if rgb_seams > 0:
		push_error("Le tileset contient %d coutures RGB malgré des bords opaques." % rgb_seams)
		failures += 1

	var occupied_cells := 0
	var ladder_tiles := 0
	var rope_tiles := 0
	var chain_tiles := 0
	for layer in parsed.layers:
		for gid in layer.data:
			occupied_cells += 1 if int(gid) > 0 else 0
			ladder_tiles += 1 if int(gid) == 38 else 0
			rope_tiles += 1 if int(gid) == 39 else 0
			chain_tiles += 1 if int(gid) == 40 else 0
	if occupied_cells < 300:
		push_error("Le parcours du niveau 4 est trop vide.")
		failures += 1
	if ladder_tiles != 4 or rope_tiles != 7 or chain_tiles != 7:
		push_error("Les raccourcis verticaux visibles ne correspondent pas au parcours.")
		failures += 1

	var player_spawns := 0
	var weapon_spawns := 0
	var climbables := 0
	var bounce_zones := 0
	for group in parsed.object_groups:
		for object in group.objects:
			var kind := str(object.get("type", ""))
			var tag := str(object.get("properties", {}).get("tag", ""))
			if kind == "player_spawn" or tag == "arena_player_spawn":
				player_spawns += 1
			if tag == "weapon_spawn":
				weapon_spawns += 1
			climbables += 1 if kind == "climbable" else 0
			bounce_zones += 1 if kind == "bounce" else 0
	if player_spawns != 4 or weapon_spawns != 5:
		push_error("L'arène doit préparer 4 apparitions de joueurs et 5 apparitions d'armes.")
		failures += 1
	if climbables != 4 or bounce_zones != 2:
		push_error("Le parkour doit contenir 4 raccourcis escaladables et 2 propulseurs.")
		failures += 1

	var packed := load(SCENE) as PackedScene
	var launcher := load(LAUNCHER) as PackedScene
	if packed == null or launcher == null:
		push_error("La scène Godot ou le lanceur solo du niveau 4 est absent.")
		failures += 1
	else:
		var test_scene := launcher.instantiate()
		var test_player := test_scene.get_node_or_null("Player") as CharacterBody2D
		if test_player == null or test_player.position != Vector2(96, 625):
			push_error("Le lanceur du niveau 4 ne contient pas notre joueur au point de test.")
			failures += 1
		test_scene.free()
		var level := packed.instantiate()
		root.add_child(level)
		await process_frame
		if level.get_player_spawn() != Vector2(96, 640):
			push_error("Godot n'a pas importé l'apparition principale de l'arène.")
			failures += 1
		var tile_layers := level.find_children("*", "TileMapLayer", true, false)
		if tile_layers.size() != 8:
			push_error("Godot n'a pas créé les 8 TileMapLayer du niveau 4.")
			failures += 1
		elif (tile_layers[0].tile_set.get_source(0) as TileSetAtlasSource).texture.resource_path != TEXTURE:
			push_error("La scène Godot n'utilise pas le tileset d'arène.")
			failures += 1
		var reusable_objects := level.find_children("*", "Area2D", true, false).filter(
			func(node): return not str(node.get_meta("object_scene", "")).is_empty()
		)
		if reusable_objects.size() != 13:
			push_error("Godot doit importer 13 objets de gameplay réutilisables dans l'arène.")
			failures += 1
		var imported_climbables := reusable_objects.filter(
			func(node): return str(node.get_meta("kind", "")) == "climbable"
		)
		if imported_climbables.size() != 4:
			push_error("Les quatre raccourcis ne sont pas escaladables dans Godot.")
			failures += 1
		else:
			for climbable in imported_climbables:
				var collision := climbable.get_node_or_null("CollisionShape2D") as CollisionShape2D
				var shape := collision.shape as RectangleShape2D if collision else null
				if shape == null or shape.size.x != 16.0 or shape.size.y < 96.0:
					push_error("%s n'a pas sa collision verticale étendue." % climbable.name)
					failures += 1
		var imported_player_spawns := 0
		var imported_weapon_spawns := 0
		for marker in level.find_children("*", "Marker2D", true, false):
			var kind := str(marker.get_meta("kind", ""))
			var tag := str(marker.get_meta("tag", ""))
			imported_player_spawns += 1 if kind == "player_spawn" or tag == "arena_player_spawn" else 0
			imported_weapon_spawns += 1 if tag == "weapon_spawn" else 0
		if imported_player_spawns != 4 or imported_weapon_spawns != 5:
			push_error("Godot n'a pas conservé les repères multijoueur et d'armes.")
			failures += 1
		level.queue_free()

	print("Niveau 4 Godot vérifié: %d tuiles, 4 joueurs, 5 armes, erreurs: %d" % [occupied_cells, failures])
	quit(1 if failures > 0 else 0)
