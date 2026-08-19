extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"
const HOVER_OUTPUT := "res://pipeline/assets/sources/previews/psychokinesis-hover-v002.png"
const HELD_OUTPUT := "res://pipeline/assets/sources/previews/psychokinesis-held-v002.png"
const TILED_OUTPUT := "res://pipeline/assets/sources/previews/psychokinesis-tiled-hover-v002.png"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(640, 360))
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame
	var controller := game.get_node("Psychokinesis") as PsychokinesisController
	var stone := game.current_map.get_node("World/PlacedObjects/YSortedObjects/PierreEtrange") as PsychokineticBody2D
	var tiled_targets: Array[PsychokineticBody2D] = [
		game.current_map.get_node("World/PlacedObjects/GroundObjects/Cordage") as PsychokineticBody2D,
		game.current_map.get_node("World/PlacedObjects/YSortedObjects/CaisseFermee") as PsychokineticBody2D,
		game.current_map.get_node("World/PlacedObjects/YSortedObjects/SacocheAzeman") as PsychokineticBody2D,
		game.current_map.get_node("World/PlacedObjects/YSortedObjects/RocherMobile") as PsychokineticBody2D,
		game.current_map.get_node("World/PlacedObjects/YSortedObjects/RocherLourd") as PsychokineticBody2D,
	]
	for target in tiled_targets:
		target.set_targeted(true)
	for frame in 12:
		await process_frame
	assert(_save_viewport(TILED_OUTPUT) == OK, "Impossible d'enregistrer les survols Tiled")
	for target in tiled_targets:
		target.set_targeted(false)
	stone.set_targeted(true)
	for frame in 12:
		await process_frame
	assert(_save_viewport(HOVER_OUTPUT) == OK, "Impossible d'enregistrer le survol psychokinétique")
	assert(controller.try_grab(stone))
	stone.target_height = 34.0
	stone.set_charge(0.72)
	for frame in 24:
		await physics_frame
	await process_frame
	assert(_save_viewport(HELD_OUTPUT) == OK, "Impossible d'enregistrer la prise psychokinétique")
	for audio_name in [&"LiftAudio", &"HoldAudio", &"ThrowAudio", &"ImpactAudio"]:
		var audio := stone.get_node(NodePath(audio_name)) as AudioStreamPlayer2D
		audio.stop()
		audio.stream = null
	game.queue_free()
	for frame in 3:
		await process_frame
	print("Aperçus psychokinétiques enregistrés : %s et %s" % [HOVER_OUTPUT, HELD_OUTPUT])
	quit()


func _save_viewport(path: String) -> Error:
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		return ERR_CANT_CREATE
	return image.save_png(ProjectSettings.globalize_path(path))
