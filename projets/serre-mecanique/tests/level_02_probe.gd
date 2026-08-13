extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const SOURCE := "res://maps/niveau-02-racines.tmx"
const SCENE := "res://scenes/levels/niveau-02-racines.tscn"
const LAUNCHER := "res://scenes/launchers/niveau-02.tscn"
const TEXTURE := "res://assets/tilesets/niveau-02-serre-mecanique-32x32-v002.png"
const ARENA_TEXTURE := "res://assets/tilesets/niveau-04-arene-combat-32x32-v001.png"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var parsed := Converter._parse_tmx(SOURCE)
	if str(parsed.get("tileset_source", "")) != "../assets/tilesets/niveau-02-serre-mecanique-32x32-v002.tsx":
		push_error("Le niveau 2 ne référence pas son nouveau TSX.")
		failures += 1
	if parsed.tilesets.size() != 2:
		push_error("Le niveau 2 doit référencer exactement ses deux tilesets utilisés.")
		failures += 1
	if parsed.layers.size() != 8 or parsed.object_groups.size() != 8:
		push_error("Le niveau 2 doit conserver ses 8 calques visuels et ses 8 calques d'objets.")
		failures += 1

	var occupied_cells := 0
	var visible_ladder_tiles := 0
	var visible_chain_tiles := 0
	for layer in parsed.layers:
		for gid in layer.data:
			if int(gid) > 0:
				occupied_cells += 1
			if int(gid) == 58:
				visible_ladder_tiles += 1
			if int(gid) == 59:
				visible_chain_tiles += 1
	if occupied_cells < 1000:
		push_error("Le niveau 2 ressemble encore à un gabarit vide.")
		failures += 1
	if visible_ladder_tiles != 3 or visible_chain_tiles != 3:
		push_error("L'échelle ou la chaîne visuelle n'est pas alignée sur le parcours.")
		failures += 1

	var packed := load(SCENE) as PackedScene
	var launcher := load(LAUNCHER) as PackedScene
	if launcher == null:
		push_error("Le lanceur du niveau 2 est absent.")
		failures += 1
	else:
		var test_scene := launcher.instantiate()
		var test_player := test_scene.get_node_or_null("Player") as CharacterBody2D
		if test_player == null or test_player.position != Vector2(64, 625):
			push_error("Le lanceur du niveau 2 ne contient pas notre joueur au point de test.")
			failures += 1
		var grapple_surfaces := test_scene.find_children("*", "StaticBody2D", true, false).filter(
			func(node): return str(node.get_meta("tiled_type", "")) == "grapple_surface"
		)
		if grapple_surfaces.size() != 1:
			push_error("Le cordage du niveau 2 n'est pas converti en surface de grappin unique.")
			failures += 1
		elif test_player == null or not test_player.can_grapple_to(grapple_surfaces[0]):
			push_error("Le joueur refuse encore le cordage typé grapple_surface.")
			failures += 1
		test_scene.free()
	if packed == null:
		push_error("La scène du niveau 2 n'existe pas.")
		failures += 1
	else:
		var level := packed.instantiate()
		root.add_child(level)
		await process_frame
		if level.find_children("*", "TileMapLayer", true, false).size() != 8:
			push_error("Les 8 calques visuels ne sont pas présents dans Godot.")
			failures += 1
		var climbables := level.find_children("*", "Area2D", true, false).filter(
			func(node): return str(node.get_meta("kind", "")) == "climbable"
		)
		if climbables.size() != 2:
			push_error("L'échelle et la chaîne ne sont pas toutes deux escaladables.")
			failures += 1
		else:
			for climbable in climbables:
				var collision := climbable.get_node_or_null("CollisionShape2D") as CollisionShape2D
				var shape := collision.shape as RectangleShape2D if collision else null
				if climbable.get_script() == null or shape == null or shape.size != Vector2(32, 128):
					push_error("%s n'a pas sa zone escaladable 32 × 128 px." % climbable.name)
					failures += 1
		if level.get_player_spawn() != Vector2(64, 640):
			push_error("Le point d'apparition du niveau 2 est incorrect.")
			failures += 1
		var tile_layers := level.find_children("*", "TileMapLayer", true, false)
		if not tile_layers.is_empty():
			var native_tile_set: TileSet = tile_layers[0].tile_set
			if native_tile_set.get_source_count() != 2:
				push_error("Godot ne contient pas les deux atlas du niveau 2.")
				failures += 1
			else:
				var primary_atlas := native_tile_set.get_source(0) as TileSetAtlasSource
				var arena_atlas := native_tile_set.get_source(1) as TileSetAtlasSource
				if primary_atlas == null or primary_atlas.texture.resource_path != TEXTURE:
					push_error("Le premier atlas Godot n'est pas le tileset principal du niveau 2.")
					failures += 1
				if arena_atlas == null or arena_atlas.texture.resource_path != ARENA_TEXTURE:
					push_error("Le second atlas Godot n'est pas le tileset de l'arène.")
					failures += 1
			var platform_layer: TileMapLayer
			for candidate in tile_layers:
				if str(candidate.get_meta("source_tiled_layer", "")) == "05 — Plateformes":
					platform_layer = candidate
					break
			if platform_layer == null:
				push_error("Le calque de plateformes est absent de la scène Godot.")
				failures += 1
			else:
				if platform_layer.get_cell_source_id(Vector2i(10, 2)) != 1:
					push_error("La plateforme issue de l'arène n'utilise pas le second atlas.")
					failures += 1
				if platform_layer.get_cell_atlas_coords(Vector2i(10, 2)) != Vector2i(2, 2):
					push_error("Le firstgid du second atlas n'est pas correctement soustrait.")
					failures += 1
		level.queue_free()

	# The two 96 px rises are serviced by climbables; every ordinary rise is <= 64 px.
	var ordinary_rises := [64, 64, 64, -64, -64, 64, 64, 64]
	for rise in ordinary_rises:
		if rise > 64:
			push_error("Un saut ordinaire dépasse la hauteur de sécurité de 64 px.")
			failures += 1

	print("Niveau 2 vérifié: %d tuiles occupées, erreurs: %d" % [occupied_cells, failures])
	quit(1 if failures > 0 else 0)
