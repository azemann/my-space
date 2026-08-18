extends SceneTree

const WORLD_PATH := "res://game/world/scenes/scene_001_world_lab/scene_001_world_lab.tscn"
const WORLD_SIZE_PX := Vector2(1280, 896)


func _initialize() -> void:
	var packed := load(WORLD_PATH) as PackedScene
	if packed == null:
		push_error("Scène laboratoire introuvable.")
		quit(1)
		return
	var world := packed.instantiate()
	root.add_child(world)
	var player_camera := world.get_node_or_null("SceneActors/PlayerProbe/Camera2D") as Camera2D
	if player_camera != null:
		player_camera.enabled = false
	var ui := world.get_node_or_null("LabUI") as CanvasLayer
	if ui != null:
		ui.visible = false
	var camera := Camera2D.new()
	camera.name = "DiagnosticOverviewCamera"
	camera.position = WORLD_SIZE_PX * 0.5
	camera.zoom = Vector2(0.4, 0.4)
	camera.enabled = true
	world.add_child(camera)
