extends SceneTree

const PLAYER_SCENE := "res://scenes/player/player.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _action(action: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)


func _has_key(action: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return true
	return false


func _has_mouse_button(action: StringName, button: MouseButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button:
			return true
	return false


func _run() -> void:
	var failures := 0
	var expected_defaults := {
		&"move_left": [KEY_Q, KEY_A, KEY_LEFT],
		&"move_right": [KEY_D, KEY_RIGHT],
		&"jump": [KEY_SPACE],
		&"climb_up": [KEY_Z, KEY_W, KEY_UP],
		&"climb_down": [KEY_S, KEY_DOWN],
		&"rope_reel_in": [KEY_Z, KEY_W, KEY_UP],
		&"rope_reel_out": [KEY_S, KEY_DOWN],
		&"weapon_menu": [KEY_TAB],
		&"weapon_cancel": [KEY_ESCAPE],
		&"weapon_holster": [KEY_C],
		&"respawn": [KEY_R],
	}
	for action in expected_defaults:
		if not InputMap.has_action(action):
			push_error("Action InputMap absente: %s." % action)
			failures += 1
			continue
		for keycode in expected_defaults[action]:
			if not _has_key(action, keycode):
				push_error("La touche %s manque à l'action %s." % [OS.get_keycode_string(keycode), action])
				failures += 1
	if not InputMap.has_action(&"weapon_primary") or not _has_mouse_button(&"weapon_primary", MOUSE_BUTTON_LEFT):
		push_error("Le clic gauche manque à l'action weapon_primary.")
		failures += 1

	var player := (load(PLAYER_SCENE) as PackedScene).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame

	player.velocity = Vector2.ZERO
	player.coyote_left = 1.0
	_action(&"climb_up", true)
	await physics_frame
	await process_frame
	_action(&"climb_up", false)
	if player.velocity.y < 0.0:
		push_error("Z déclenche encore une impulsion de saut.")
		failures += 1

	player.velocity = Vector2.ZERO
	player.coyote_left = 1.0
	_action(&"jump", true)
	await physics_frame
	await process_frame
	_action(&"jump", false)
	if player.velocity.y >= 0.0:
		push_error("Espace ne déclenche pas le saut.")
		failures += 1

	var anchor_body := StaticBody2D.new()
	anchor_body.set_meta("tiled_type", "one_way")
	root.add_child(anchor_body)
	anchor_body.global_position = player.global_position + Vector2(120, -80)
	player.velocity = Vector2.ZERO
	player.attach_grapple_to(anchor_body, anchor_body.global_position)
	var initial_length: float = player.grapple_length
	_action(&"rope_reel_in", true)
	await physics_frame
	await process_frame
	_action(&"rope_reel_in", false)
	var shortened_length: float = player.grapple_length
	if shortened_length >= initial_length:
		push_error("Z ne raccourcit pas la corde.")
		failures += 1

	_action(&"rope_reel_out", true)
	await physics_frame
	await process_frame
	_action(&"rope_reel_out", false)
	if player.grapple_length <= shortened_length:
		push_error("S n'allonge pas la corde.")
		failures += 1

	var saved_jump_events := InputMap.action_get_events(&"jump")
	InputMap.action_erase_events(&"jump")
	var custom_jump := InputEventKey.new()
	custom_jump.keycode = KEY_J
	InputMap.action_add_event(&"jump", custom_jump)
	if not _has_key(&"jump", KEY_J) or _has_key(&"jump", KEY_SPACE):
		push_error("L'action jump ne peut pas être reconfigurée à l'exécution.")
		failures += 1
	InputMap.action_erase_events(&"jump")
	for event in saved_jump_events:
		InputMap.action_add_event(&"jump", event)

	print("InputMap vérifié: actions, touches par défaut et reconfiguration, erreurs: %d" % failures)
	player.queue_free()
	anchor_body.queue_free()
	quit(1 if failures > 0 else 0)
