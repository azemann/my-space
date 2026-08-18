extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for action in [
		&"move_left",
		&"move_right",
		&"move_up",
		&"move_down",
		&"interact",
		&"run",
		&"pause",
		&"psychokinesis_grab",
		&"psychokinesis_throw",
		&"psychokinesis_raise",
		&"psychokinesis_lower",
		&"psychokinesis_cancel",
		&"psychokinesis_move_left",
		&"psychokinesis_move_right",
		&"psychokinesis_move_up",
		&"psychokinesis_move_down",
	]:
		assert(InputMap.has_action(action), "Commande absente : %s" % action)
		assert(not InputMap.action_get_events(action).is_empty(), "Commande sans touche : %s" % action)

	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame
	var player := game.player
	assert(player.get_node_or_null("GroundShadow") is Polygon2D, "Le joueur doit posséder une ombre ancrée au sol")
	assert(player != null)
	assert(player.get_parent() == game.current_map.get_node("World/PlacedObjects/YSortedObjects"))
	assert(player.global_position == Vector2(656, 496))
	assert(game.camera.target == player)
	assert(game.camera.limit_right == 1280 and game.camera.limit_bottom == 960)

	var start := player.global_position
	Input.action_press(&"move_right", 1.0)
	await physics_frame
	await physics_frame
	Input.action_release(&"move_right")
	assert(player.global_position.x > start.x, "Le joueur doit répondre à move_right")
	assert(player.facing == &"east")
	assert(player.animated_sprite.animation == &"walk_east")
	await physics_frame
	await physics_frame
	assert(player.animated_sprite.animation == &"idle_east")

	game.queue_free()
	await process_frame
	print("Runtime vérifié : commandes, spawn, mouvement, animation et caméra persistante.")
	quit()
