extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const Profile = preload("res://game/serre/tiled/serre_tiled_profile.gd")
const SOURCE := "res://maps/gabarits/niveau-02-gabarit.tmx"
const TILESET_TARGET := "res://resources/tilesets/niveau-02-gabarit.tres"
const SCENE_TARGET := "res://scenes/gabarits/niveau-02-gabarit.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/gabarits"))
	var parsed := Converter._parse_tmx(SOURCE)
	var failures := 0

	if parsed.layers.size() != 8:
		push_error("Le gabarit doit contenir 8 calques de tuiles.")
		failures += 1
	if parsed.object_groups.size() != 8:
		push_error("Le gabarit doit contenir 8 calques d'objets.")
		failures += 1
	if str(parsed.properties.get("level_name", "")) != "Niveau 2 — à définir":
		push_error("Les propriétés de carte ne sont pas conservées.")
		failures += 1
	if parsed.tilesets.size() != 1 or int(parsed.tilesets[0].first_gid) != 1:
		push_error("Le tileset et son firstgid ne sont pas conservés par le parseur.")
		failures += 1

	var shapes := {}
	for group in parsed.object_groups:
		for object in group.objects:
			shapes[str(object.shape)] = true
	for expected in ["rectangle", "ellipse", "polygon", "polyline", "point"]:
		if not shapes.has(expected):
			push_error("Forme Tiled absente du test: %s" % expected)
			failures += 1

	var tile_set := Converter._build_map_tile_set(SOURCE, parsed, Profile)
	if tile_set == null:
		push_error("Le tileset propre au niveau 2 ne se charge pas.")
		failures += 1
	else:
		var save_error := ResourceSaver.save(tile_set, TILESET_TARGET)
		if save_error != OK:
			push_error("Impossible d'enregistrer le TileSet du gabarit.")
			failures += 1
		else:
			var convert_error := Converter._convert_map(SOURCE, SCENE_TARGET, tile_set, parsed, Profile)
			if convert_error != OK:
				push_error("Impossible de convertir le gabarit: %s" % convert_error)
				failures += 1

	if failures == 0:
		var packed := load(SCENE_TARGET) as PackedScene
		var level := packed.instantiate()
		root.add_child(level)
		await process_frame
		if level.find_children("*", "TileMapLayer", true, false).size() != 8:
			push_error("Les 8 calques de tuiles ne sont pas présents dans Godot.")
			failures += 1
		if level.find_children("*", "CollisionPolygon2D", true, false).size() < 2:
			push_error("Les collisions polygonales ou elliptiques sont absentes.")
			failures += 1
		if level.find_children("*", "StaticBody2D", true, false).size() != 5:
			push_error("Les cinq exemples de collision ne sont pas convertis.")
			failures += 1
		if level.get_player_spawn() != Vector2(64, 608):
			push_error("Le point d'apparition éditable n'est pas retrouvé.")
			failures += 1
		level.queue_free()

	print("Capacités Tiled vérifiées, erreurs: %d" % failures)
	quit(1 if failures > 0 else 0)
