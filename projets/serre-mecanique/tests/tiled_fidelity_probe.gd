extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const Profile = preload("res://game/serre/tiled/serre_tiled_profile.gd")
const SOURCE := "res://maps/niveau-02-racines.tmx"
const SCENE := "res://scenes/levels/niveau-02-racines.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var checked_cells := 0
	var parsed := Converter._parse_tmx(SOURCE)
	var expected_tile_set := Converter._build_map_tile_set(SOURCE, parsed, Profile)
	if expected_tile_set == null:
		push_error("Impossible de préparer les atlas du contrôle de fidélité.")
		quit(1)
		return

	var level := (load(SCENE) as PackedScene).instantiate()
	root.add_child(level)
	await process_frame
	var native_layers := level.find_children("*", "TileMapLayer", true, false)
	if native_layers.size() != parsed.layers.size():
		push_error("Le nombre de calques diffère entre Tiled et Godot.")
		failures += 1

	for source_layer in parsed.layers:
		var native_layer: TileMapLayer
		for candidate in native_layers:
			if str(candidate.get_meta("source_tiled_layer", "")) == str(source_layer.name):
				native_layer = candidate
				break
		if native_layer == null:
			push_error("Calque Tiled absent de Godot : %s" % str(source_layer.name))
			failures += 1
			continue
		if native_layer.visible != bool(source_layer.visible):
			push_error("Visibilité différente pour le calque %s." % str(source_layer.name))
			failures += 1
		if not is_equal_approx(native_layer.modulate.a, float(source_layer.opacity)):
			push_error("Opacité différente pour le calque %s." % str(source_layer.name))
			failures += 1
		if native_layer.z_index != int(source_layer.properties.get("z_index", 0)):
			push_error("Ordre d'affichage différent pour le calque %s." % str(source_layer.name))
			failures += 1

		for index in source_layer.data.size():
			var gid := int(source_layer.data[index])
			var cell := Vector2i(index % int(source_layer.width), floori(float(index) / int(source_layer.width)))
			if gid == 0:
				if native_layer.get_cell_source_id(cell) != -1:
					push_error("Godot contient une tuile absente du TMX en %s:%s." % [source_layer.name, cell])
					failures += 1
				continue
			checked_cells += 1
			var expected := Converter._resolve_gid(gid, parsed)
			if native_layer.get_cell_source_id(cell) != int(expected.source_id):
				push_error("Mauvais atlas en %s:%s." % [source_layer.name, cell])
				failures += 1
			elif native_layer.get_cell_atlas_coords(cell) != expected.atlas_coords:
				push_error("Mauvaises coordonnées d'atlas en %s:%s." % [source_layer.name, cell])
				failures += 1

	print("Fidélité Tiled → Godot vérifiée: %d cellules, erreurs: %d" % [checked_cells, failures])
	level.queue_free()
	quit(1 if failures > 0 else 0)
