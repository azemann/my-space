extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(ProjectSettings.get_setting("display/window/size/mode") == 3)
	assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 640)
	assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 360)

	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame

	assert(game.get_node_or_null("Display") is DisplayController)
	assert(game.camera.config.zoom.is_equal_approx(Vector2.ONE))
	var world_zone := game.current_map.get_node("World/Gameplay/CameraZones/WorldCameraBounds") as Area2D
	assert(is_equal_approx(float(world_zone.get_meta("zoom")), 1.0))
	var awakening_zone := game.current_map.get_node("World/Gameplay/CameraZones/AwakeningCameraZone") as Area2D
	assert(is_equal_approx(float(awakening_zone.get_meta("zoom")), 1.0))

	game.camera._on_camera_zone_body_entered(game.player, awakening_zone)
	assert(game.camera.desired_zoom.is_equal_approx(Vector2.ONE))
	assert(game.camera.config.pixel_perfect_motion and game.camera.config.pixel_perfect_zoom)
	assert(not game.camera.position_smoothing_enabled, "Le lissage final appartient au contrôleur pixel-perfect")
	assert(game.camera._validated_zoom(0.9).is_equal_approx(Vector2.ONE), "Un ancien zoom fractionnaire doit être normalisé")
	game.player.set_physics_process(false)
	game.player.velocity = Vector2(95, 37)
	for frame in 30:
		game.player.global_position += game.player.velocity / 60.0
		game.camera._physics_process(1.0 / 60.0)
		assert(game.camera.global_position == game.camera.global_position.round(),
			"La position finale de caméra doit rester sur la grille des pixels")
		assert(game.camera.zoom == game.camera.desired_zoom,
			"Le zoom pixel-perfect ne doit pas traverser de valeurs intermédiaires")

	game.queue_free()
	await process_frame
	print("Affichage vérifié : plein écran et caméra pixel-perfect ×1.")
	quit()
