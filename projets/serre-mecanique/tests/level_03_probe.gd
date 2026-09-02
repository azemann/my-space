extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const SOURCE := "res://maps/niveau-03-automates.tmx"
const SCENE := "res://scenes/levels/niveau-03-automates.tscn"
const LAUNCHER := "res://scenes/launchers/niveau-03.tscn"
const TEXTURE := "res://assets/tilesets/niveau-03-serre-mecanique-32x32-v002.png"
const GEOMETRY := "res://assets/tilesets/serre-mecanique-32x32.png"
const ORIGINAL := "res://sources/imagegen/generated/serre-mecanique-tileset-32x32-alpha-v001.png"
const ISOLATED_PROP_IDS := {
	52: true, 53: true, 54: true, 55: true, 56: true, 59: true,
	60: true, 61: true, 62: true, 63: true, 64: true, 65: true,
	66: true, 67: true, 68: true, 69: true, 70: true, 71: true,
	72: true, 73: true, 74: true, 75: true, 76: true, 77: true,
	78: true, 79: true,
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var parsed := Converter._parse_tmx(SOURCE)
	if str(parsed.get("tileset_source", "")) != "../assets/tilesets/niveau-03-serre-mecanique-32x32-v002.tsx":
		push_error("Le niveau 3 ne référence pas son TSX de production bord à bord.")
		failures += 1
	if parsed.layers.size() != 8 or parsed.object_groups.size() != 8:
		push_error("Le niveau 3 doit contenir 8 calques visuels et 8 calques d'objets.")
		failures += 1
	var production := Image.load_from_file(ProjectSettings.globalize_path(TEXTURE))
	var geometry := Image.load_from_file(ProjectSettings.globalize_path(GEOMETRY))
	var original := Image.load_from_file(ProjectSettings.globalize_path(ORIGINAL))
	for tile_id in range(80):
		var tile_x := (tile_id % 16) * 32
		var tile_y := floori(tile_id / 16.0) * 32
		for local_y in range(32):
			for local_x in range(32):
				var pixel := Vector2i(tile_x + local_x, tile_y + local_y)
				if ISOLATED_PROP_IDS.has(tile_id):
					if production.get_pixelv(pixel) != original.get_pixelv(pixel):
						push_error("L'objet isolé %d a été déformé ou rogné." % tile_id)
						failures += 1
						break
				elif production.get_pixelv(pixel).a != geometry.get_pixelv(pixel).a:
					push_error("Le masque raccordable de la tuile %d a changé." % tile_id)
					failures += 1
					break
			if failures > 0:
				break
		if failures > 0:
			break

	var occupied_cells := 0
	for layer in parsed.layers:
		for gid in layer.data:
			occupied_cells += 1 if int(gid) > 0 else 0
	if occupied_cells < 1000:
		push_error("Le niveau 3 ressemble encore à un gabarit vide.")
		failures += 1

	var packed := load(SCENE) as PackedScene
	var launcher := load(LAUNCHER) as PackedScene
	if packed == null or launcher == null:
		push_error("La scène ou le lanceur du niveau 3 est absent.")
		failures += 1
	else:
		var test_scene := launcher.instantiate()
		var test_player := test_scene.get_node_or_null("Player") as CharacterBody2D
		if test_player == null or test_player.position != Vector2(64, 625):
			push_error("Le lanceur du niveau 3 ne contient pas notre joueur au point de test.")
			failures += 1
		test_scene.free()
		var level := packed.instantiate()
		root.add_child(level)
		await process_frame
		if level.get_player_spawn() != Vector2(64, 640):
			push_error("Le point d'apparition du niveau 3 est incorrect.")
			failures += 1
		var tile_layers := level.find_children("*", "TileMapLayer", true, false)
		if tile_layers.size() != 8:
			push_error("Les 8 TileMapLayer du niveau 3 ne sont pas présents.")
			failures += 1
		elif (tile_layers[0].tile_set.get_source(0) as TileSetAtlasSource).texture.resource_path != TEXTURE:
			push_error("Godot n'utilise pas la planche de production du niveau 3.")
			failures += 1
		var reusable_objects := level.find_children("*", "Area2D", true, false).filter(
			func(node): return not str(node.get_meta("object_scene", "")).is_empty()
		)
		if reusable_objects.size() != 15:
			push_error("Le niveau 3 doit contenir 15 objets de gameplay réutilisables.")
			failures += 1
		var climbables := reusable_objects.filter(
			func(node): return str(node.get_meta("kind", "")) == "climbable"
		)
		if climbables.size() != 2:
			push_error("L'échelle et la chaîne du niveau 3 doivent être escaladables.")
			failures += 1
		else:
			for climbable in climbables:
				var collision := climbable.get_node_or_null("CollisionShape2D") as CollisionShape2D
				var shape := collision.shape as RectangleShape2D if collision else null
				if shape == null or shape.size != Vector2(32, 128):
					push_error("%s n'a pas sa zone étendue de 32 × 128 px." % climbable.name)
					failures += 1
		level.queue_free()

	print("Niveau 3 vérifié: %d tuiles occupées, erreurs: %d" % [occupied_cells, failures])
	quit(1 if failures > 0 else 0)
