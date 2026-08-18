extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame

	var checked := 0
	var largest_error := 0.0
	var largest_error_name := "aucun écart"
	for node in get_nodes_in_group(&"psychokinetic_targets"):
		var body := node as PsychokineticBody2D
		var hover_shape := body.get_node("SelectionArea/HoverShape") as CollisionShape2D
		var expected_center := _rendered_content_center(body)
		var error := hover_shape.global_position.distance_to(expected_center)
		if error > largest_error:
			largest_error = error
			largest_error_name = body.name
		assert(error <= 0.05,
			"Zone de survol décentrée sur %s : %.3f px" % [body.name, error])
		checked += 1

	for audio in game.current_map.get_node("Runtime/Ambience").get_children():
		if audio is AudioStreamPlayer2D:
			(audio as AudioStreamPlayer2D).stop()
	game.queue_free()
	for frame in 3:
		await process_frame
	print("Alignement psychokinétique vérifié : %d objets, erreur maximale %.3f px (%s)." % [
		checked, largest_error, largest_error_name])
	quit()


func _rendered_content_center(body: PsychokineticBody2D) -> Vector2:
	var visual := body.get_node("Visual") as Node2D
	if visual is Sprite2D:
		return visual.global_position
	var layer := visual as TileMapLayer
	var cell := Vector2i.ZERO
	var source_id := layer.get_cell_source_id(cell)
	var atlas := layer.tile_set.get_source(source_id) as TileSetAtlasSource
	var atlas_coordinates := layer.get_cell_atlas_coords(cell)
	var tile_data := atlas.get_tile_data(atlas_coordinates, 0)
	var region := atlas.get_tile_texture_region(atlas_coordinates, 0)
	var content_center_in_region := Vector2(
		float(body.get_meta("content_offset_x")) + float(body.get_meta("content_width")) * 0.5,
		float(body.get_meta("content_offset_y")) + float(body.get_meta("content_height")) * 0.5
	)
	var rendered_center_local := layer.map_to_local(cell) \
		+ Vector2(tile_data.texture_origin) \
		+ content_center_in_region - Vector2(region.size) * 0.5
	return layer.to_global(rendered_center_local)
