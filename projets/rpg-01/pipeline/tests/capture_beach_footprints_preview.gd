extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"
const OUTPUT := "res://pipeline/assets/sources/previews/beach-wet-sand-footprints.png"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(640, 360))
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame
	game.player.set_controls_enabled(false)
	game.player.global_position = Vector2(640, 535)
	var trail := game.current_map.get_node("Runtime/Footprints") as FootprintTrail2D
	for index in range(8):
		trail._spawn_footprint(Vector2(545 + index * 24, 552 + (index % 2) * 4), Vector2.RIGHT)
	for frame in 10:
		await process_frame
	var image := root.get_texture().get_image()
	assert(image != null and not image.is_empty())
	assert(image.save_png(ProjectSettings.globalize_path(OUTPUT)) == OK)
	for audio in game.current_map.get_node("Runtime/Ambience").get_children():
		if audio is AudioStreamPlayer2D:
			(audio as AudioStreamPlayer2D).stop()
	game.free()
	await process_frame
	print("Aperçu du sable humide et des empreintes enregistré : %s" % OUTPUT)
	quit()
