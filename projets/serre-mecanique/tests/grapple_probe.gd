extends SceneTree

const MAIN_LEVEL_2 := "res://scenes/launchers/niveau-02.tscn"
const PISTOL_TEXTURE := "res://assets/weapons/grappling-pistol-v001.png"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var main := (load(MAIN_LEVEL_2) as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	var player := main.get_node("Player") as CharacterBody2D
	var equipment := player.get_node("Equipment")
	var bodies := main.find_children("*", "StaticBody2D", true, false)
	var one_way: StaticBody2D
	var solid: StaticBody2D
	var one_way_count := 0
	for body in bodies:
		var kind := str(body.get_meta("tiled_type", ""))
		if kind == "one_way":
			one_way_count += 1
			if one_way == null:
				one_way = body
		elif kind == "solid" and solid == null:
			solid = body

	if one_way_count != 10 or one_way == null:
		push_error("Les dix plateformes one_way du niveau 2 ne sont pas disponibles pour le test.")
		failures += 1
	elif not player.can_grapple_to(one_way):
		push_error("Le grappin refuse une plateforme one_way.")
		failures += 1
	if solid == null:
		push_error("Aucun sol plein n'est disponible pour le test négatif.")
		failures += 1
	else:
		if player.can_grapple_to(solid):
			push_error("Le grappin accepte un sol non typé.")
			failures += 1
		solid.set_meta("grapple_enabled", true)
		if not player.can_grapple_to(solid):
			push_error("grapple_enabled=true n'autorise pas l'accroche.")
			failures += 1

	if equipment.equipped_weapon == null or str(equipment.equipped_weapon.weapon_id) != "grappling_pistol":
		push_error("Le pistolet-grappin n'est pas équipé au démarrage.")
		failures += 1
	elif equipment.equipped_weapon.texture.resource_path != PISTOL_TEXTURE:
		push_error("Le contrôleur d'équipement n'utilise pas le nouvel asset.")
		failures += 1

	if one_way:
		var anchor := player.global_position + Vector2(120, -80)
		if not player.attach_grapple_to(one_way, anchor):
			push_error("L'accroche programmée à une one_way a échoué.")
			failures += 1
		else:
			var rope_length: float = player.grapple_length
			player.global_position = anchor + Vector2(0, rope_length + 60.0)
			player.velocity = Vector2(0, 180)
			player._enforce_grapple_constraint()
			if not is_equal_approx(player.global_position.distance_to(anchor), rope_length):
				push_error("La contrainte ne maintient pas la corde à sa longueur maximale.")
				failures += 1
			if player.velocity.dot((player.global_position - anchor).normalized()) > 0.01:
				push_error("La vitesse continue à étirer une corde déjà tendue.")
				failures += 1
			var preserved_velocity := Vector2(210, -160)
			player.velocity = preserved_velocity
			player.release_grapple()
			if player.velocity != preserved_velocity:
				push_error("Le décrochage ne conserve pas l'élan du joueur.")
				failures += 1

	print("Grappin vérifié: %d one_way, erreurs: %d" % [one_way_count, failures])
	main.queue_free()
	quit(1 if failures > 0 else 0)
