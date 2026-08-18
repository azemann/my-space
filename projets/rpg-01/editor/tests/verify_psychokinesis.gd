extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for action in [
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
		assert(InputMap.has_action(action), "Commande psychokinétique absente : %s" % action)
		assert(not InputMap.action_get_events(action).is_empty(), "Commande psychokinétique sans liaison : %s" % action)
		assert(_has_joypad_binding(action), "Commande psychokinétique sans liaison manette : %s" % action)
	assert(_has_mouse_button(&"psychokinesis_grab", MOUSE_BUTTON_LEFT), "Le clic gauche doit saisir ou déposer")
	assert(_has_mouse_button(&"psychokinesis_throw", MOUSE_BUTTON_RIGHT), "Le clic droit doit charger puis projeter")

	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame

	var controller := game.get_node("Psychokinesis") as PsychokinesisController
	var stone := game.current_map.get_node("World/PlacedObjects/YSortedObjects/PierreEtrange") as PsychokineticBody2D
	assert(controller != null and stone != null)
	assert(controller.get_node_or_null("TargetDetector") is PsychokinesisTargetDetector)
	assert(controller.get_node_or_null("ManipulationAnchor") is Marker2D)
	assert(controller.get_node_or_null("AimIndicator") is PsychokinesisAimIndicator2D)
	var selection_area_count := 0
	for node in get_nodes_in_group(&"psychokinetic_targets"):
		var selectable := node as PsychokineticBody2D
		assert(selectable.get_node_or_null("StateMachine") is PsychokinesisStateMachine, "%s doit posséder sa machine à états V2" % selectable.name)
		assert(selectable.get_node_or_null("Presentation") is PsychokinesisPresentation2D, "%s doit séparer sa présentation du corps physique" % selectable.name)
		var area := selectable.get_node_or_null("SelectionArea") as Area2D
		assert(area is PsychokinesisInteractionArea2D, "%s doit posséder la SelectionArea V2 canonique" % selectable.name)
		var shape := area.get_node_or_null("HoverShape") as CollisionShape2D
		assert(shape != null and shape.shape != null, "%s doit posséder une forme de survol" % selectable.name)
		assert(selectable.selection_contains_point(shape.global_position), "%s doit répondre au centre de sa propre zone" % selectable.name)
		selection_area_count += 1
	assert(selection_area_count >= 46, "Toutes les familles d'objets doivent partager le même contrat de survol")
	assert(controller.acquisition_range == 208.0 and controller.control_radius == 224.0, "Le voisinage psychokinétique doit rester confortable dans le cadrage 640 × 360")
	assert(AudioServer.get_bus_index(&"Psychokinesis") >= 0, "Le bus audio du pouvoir doit exister")
	for audio_name in [&"LiftAudio", &"HoldAudio", &"ThrowAudio", &"ImpactAudio"]:
		var audio := stone.get_node(NodePath(audio_name)) as AudioStreamPlayer2D
		assert(audio != null and audio.stream != null, "Son psychokinétique absent : %s" % audio_name)
		audio.stream = null # Le pilote audio factice headless conserve sinon ses playbacks à la fermeture.
	stone.effects_enabled = false # Les particules GPU ne sont pas rendues par le pilote headless.
	assert(stone.global_position.is_equal_approx(Vector2(752, 464)), "La pierre doit respecter son point Tiled")
	assert(stone.collision_layer == 4 and stone.collision_mask == 1, "La petite pierre doit heurter le monde depuis la couche Interactions")
	assert((game.player.collision_mask & stone.collision_layer) == 0, "La petite pierre psychokinétique ne doit ni bloquer ni pousser le joueur")
	var shadow := stone.get_node("Shadow") as Node2D
	var selection_ghost := stone.get_node("SelectionGhost") as Node2D
	assert(selection_ghost != null)
	assert(selection_ghost.material is ShaderMaterial, "La détection doit employer une silhouette fantôme dédiée")
	stone.set_targeted(true)
	assert(stone.current_state() == PsychokinesisStateMachine.State.TARGETED)
	for frame in 8:
		stone._process(1.0 / 60.0)
	assert(selection_ghost.visible, "Le fantôme doit apparaître progressivement au survol")
	assert(float((selection_ghost.material as ShaderMaterial).get_shader_parameter(&"opacity")) > 0.0)
	assert(selection_ghost.transform.is_equal_approx(stone.get_node("Visual").transform), "Le halo de survol doit coïncider exactement avec le visuel")
	stone.set_targeted(false)
	assert(stone.current_state() == PsychokinesisStateMachine.State.IDLE)
	assert(not selection_ghost.visible, "Changer de cible ne doit pas laisser de fantôme sur l'ancien objet")
	var shadow_ground_offset := shadow.global_position - stone.global_position
	assert(shadow.top_level, "L'ombre doit être découplée de la rotation du corps")
	assert(controller._find_hovered_target(stone.lifted_global_position()) == stone, "Le survol doit cibler précisément le visuel de la pierre")
	assert(controller._find_hovered_target(stone.lifted_global_position() + Vector2(stone.selection_radius + 2.0, 0.0)) == null, "Le survol ne doit pas sélectionner à côté de l'objet")
	var tiled_rock := game.current_map.get_node("World/PlacedObjects/YSortedObjects/RocherMobile") as PsychokineticBody2D
	var tiled_selection := tiled_rock.get_node("SelectionArea/HoverShape") as CollisionShape2D
	assert(tiled_selection.shape is RectangleShape2D, "Un objet Tiled doit utiliser la même SelectionArea Godot que la pierre test")
	assert(tiled_rock.selection_contains_point(tiled_rock.lifted_global_position()), "Un objet généré depuis Tiled doit répondre sur ses pixels visibles")
	assert(not tiled_rock.selection_contains_point(tiled_rock.global_position + Vector2(-76.0, -90.0)), "Le vide transparent de l'atlas ne doit jamais être sélectionnable")
	assert(controller._find_hovered_target(tiled_rock.lifted_global_position()) == tiled_rock, "Un objet Tiled visible dans le voisinage doit être détecté comme la pierre test")
	tiled_rock.set_targeted(true)
	for frame in 4:
		tiled_rock._process(1.0 / 60.0)
	var tiled_ghost := tiled_rock.get_node("SelectionGhost") as TileMapLayer
	assert(tiled_ghost.visible and tiled_ghost.transform.is_equal_approx((tiled_rock.get_node("Visual") as TileMapLayer).transform), "Le halo d'un objet Tiled doit rester exactement sur son visuel")
	tiled_rock.set_targeted(false)
	var pointer_world := controller._pointer_world_position()
	var pointer_roundtrip := controller.get_viewport().get_canvas_transform() * pointer_world
	assert(pointer_roundtrip.is_equal_approx(controller.get_viewport().get_mouse_position()), "La souris doit employer le même espace écran que la caméra")
	assert(controller.try_grab(stone), "La pierre légère doit être saisissable au niveau 0")
	assert(controller.held_body == stone and stone.is_held and not stone.freeze)
	assert(stone.current_state() == PsychokinesisStateMachine.State.HELD)
	assert(is_equal_approx(stone.target_height, stone.default_hold_height), "La prise doit viser la hauteur de flottement par défaut")
	var simulated_grab_pointer := stone.global_position + Vector2(9.0, -11.0)
	controller._mouse_grab_offset = stone.global_position - simulated_grab_pointer
	controller._mouse_grab_height = stone.height
	assert(controller._mouse_hold_target(simulated_grab_pointer).is_equal_approx(stone.global_position), "Le clic ne doit jamais recentrer l'ancre des pieds sous la souris")
	stone.height += 6.0
	assert(controller._mouse_hold_target(simulated_grab_pointer).is_equal_approx(stone.global_position + Vector2(0.0, 6.0)), "Le point visuel saisi doit rester sous le curseur pendant la montée")
	stone.height -= 6.0

	var desired_position := stone.global_position + Vector2(20.0, 0.0)
	controller._using_mouse = false
	controller._gamepad_offset = desired_position - controller.player.global_position
	controller._control_position = desired_position
	for frame in 12:
		await physics_frame
	assert(stone.global_position.x > 752.0, "La pierre doit poursuivre la souris avec inertie")
	assert(stone.global_position.distance_to(desired_position) < 20.0, "La poursuite physique doit rapprocher la pierre de sa cible")
	var clamped := controller._clamp_to_control_radius(controller.player.global_position + Vector2(1000.0, 0.0))
	assert(is_equal_approx(clamped.distance_to(controller.player.global_position), controller.control_radius), "La manipulation doit rester dans le rayon du pouvoir")
	var initial_target_height := stone.target_height
	stone.change_height(controller.height_step)
	assert(stone.target_height > initial_target_height, "La hauteur doit pouvoir être augmentée")
	for frame in 12:
		stone._physics_process(1.0 / 60.0)
	assert(stone.height > 0.0, "La pierre doit monter progressivement")
	assert(stone.get_node("Visual").position.y < -43.0, "Le visuel doit monter au-dessus de son ancrage au sol")
	assert(shadow.scale.x < 1.0, "L'ombre doit rétrécir avec la hauteur")
	stone.rotation = 0.8
	stone._sync_shadow_to_ground()
	assert(is_zero_approx(shadow.global_rotation), "La rotation de l'objet ne doit jamais faire tourner son ombre")
	assert(shadow.global_position.is_equal_approx(stone.global_position + shadow_ground_offset), "L'ombre doit rester sur l'ancre au sol")
	controller.drop_held()
	assert(controller.held_body == null and not stone.is_held and not stone.freeze)
	assert(stone.current_state() == PsychokinesisStateMachine.State.LANDING)
	assert(is_zero_approx(stone.target_height), "Un objet déposé doit redescendre au sol")

	assert(controller.try_grab(stone))
	controller.begin_charge()
	assert(stone.current_state() == PsychokinesisStateMachine.State.CHARGING)
	var charge_anchor := controller._charge_anchor
	for frame in 20:
		controller._physics_process(1.0 / 60.0)
	assert(stone.charge_ratio > 0.25, "Maintenir la projection doit charger l'impulsion")
	assert(controller._control_position.is_equal_approx(charge_anchor), "La charge doit verrouiller le point de maintien pour libérer la visée")
	controller.throw_held(1.0, Vector2.UP)
	assert(controller.held_body == null and not stone.is_held and stone.is_thrown)
	assert(stone.current_state() == PsychokinesisStateMachine.State.THROWN)
	await physics_frame
	assert(stone.linear_velocity.length() > 300.0, "La projection chargée doit donner une impulsion physique")
	assert(stone.linear_velocity.y < 0.0, "La projection doit suivre la direction de visée et non l'orientation du joueur")
	var peak_height := stone.height
	for frame in 90:
		stone._physics_process(1.0 / 60.0)
		peak_height = maxf(peak_height, stone.height)
	assert(peak_height > stone.default_hold_height, "La projection doit suivre un arc aérien")
	assert(not stone.is_thrown and is_zero_approx(stone.height), "La pierre doit retomber au sol après son arc")
	assert(stone.current_state() == PsychokinesisStateMachine.State.IDLE)
	stone._sync_shadow_to_ground()
	assert(shadow.global_position.is_equal_approx(stone.global_position + shadow_ground_offset), "L'ombre doit suivre le sol pendant et après le lancer")
	assert(shadow.scale.is_equal_approx(stone._shadow_origin_scale), "L'ombre doit retrouver sa taille au moment de l'atterrissage")
	assert(is_equal_approx(shadow.modulate.a, stone._shadow_origin_color.a), "L'ombre doit retrouver son opacité au moment de l'atterrissage")

	game.queue_free()
	for frame in 3:
		await process_frame
	print("Psychokinésie vérifiée : ciblage, sons, hauteur, charge, arc et impact de la petite pierre.")
	quit()


func _has_joypad_binding(action: StringName) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false


func _has_mouse_button(action: StringName, button: MouseButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button:
			return true
	return false
