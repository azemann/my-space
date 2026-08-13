extends SceneTree

const LAUNCHER := "res://scenes/launchers/niveau-02.tscn"
const EXPLOSION := "res://scenes/effects/bazooka_explosion.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var launcher := (load(LAUNCHER) as PackedScene).instantiate()
	root.add_child(launcher)
	await process_frame
	await physics_frame
	var player := launcher.get_node("Player") as CharacterBody2D
	var equipment := player.get_node("Equipment") as WeaponController
	var health := player.get_node("Health") as HealthComponent

	if equipment.inventory.size() != 2:
		push_error("L'inventaire du joueur ne contient pas le grappin et le bazooka.")
		failures += 1
	elif not equipment.equip(1):
		push_error("Le bazooka ne peut pas être équipé.")
		failures += 1
	else:
		var bazooka := equipment.equipped_weapon
		if str(bazooka.weapon_id) != "mechanical_bazooka":
			push_error("La deuxième arme n'est pas le bazooka mécanique.")
			failures += 1
		if bazooka.projectile_scene == null or bazooka.recoil_impulse <= 0.0:
			push_error("Le projectile ou le recul du bazooka n'est pas configurable.")
			failures += 1
		if bazooka.fire_audio == null:
			push_error("Le son de départ du bazooka n'est pas affecté à sa ressource.")
			failures += 1
		if not bazooka.charge_enabled or bazooka.charge_duration <= 0.0 or bazooka.charge_material == null:
			push_error("Le cycle maintenir, charger, relâcher n'est pas activé sur le bazooka.")
			failures += 1
		var weapon_audio := equipment.get_node_or_null("WeaponAudio") as AudioStreamPlayer2D
		if weapon_audio == null or weapon_audio.bus != &"Weapons":
			push_error("Le lecteur du son de tir n'est pas relié au bus Weapons.")
			failures += 1
		player.velocity = Vector2.ZERO
		equipment.aim_direction = Vector2.RIGHT
		equipment._begin_charge()
		equipment._update_charge(bazooka.charge_duration * 0.5)
		if not equipment.is_charging or not is_equal_approx(equipment.charge_ratio, 0.5):
			push_error("La jauge n'atteint pas une demi-charge après la moitié de sa durée.")
			failures += 1
		equipment._release_charge()
		var rockets := launcher.find_children("*", "BazookaRocket", true, false)
		if rockets.size() != 1:
			push_error("Le tir ne crée pas exactement une roquette.")
			failures += 1
		else:
			var rocket := rockets[0] as BazookaRocket
			var expected_power: float = lerpf(bazooka.minimum_power, 1.0, 0.5)
			if not rocket.launched or not is_equal_approx(rocket.velocity.x, rocket.speed * expected_power):
				push_error("La vitesse de la roquette ne correspond pas à la demi-charge.")
				failures += 1
		if equipment.is_charging or not is_zero_approx(equipment.charge_ratio):
			push_error("La jauge ne revient pas à zéro après le tir.")
			failures += 1
		if weapon_audio and not weapon_audio.playing:
			push_error("Le son du bazooka ne démarre pas au relâchement.")
			failures += 1
		if player.velocity.x >= 0.0:
			push_error("Le bazooka n'applique pas son recul au joueur.")
			failures += 1

	var previous_health := health.current_health
	player.velocity = Vector2.ZERO
	var explosion := (load(EXPLOSION) as PackedScene).instantiate() as BazookaExplosion
	launcher.add_child(explosion)
	explosion.global_position = player.global_position + Vector2(-24, 0)
	await process_frame
	await physics_frame
	if health.current_health >= previous_health:
		push_error("L'explosion proche n'inflige aucun dégât au joueur.")
		failures += 1
	if player.velocity.length() <= 0.0:
		push_error("L'explosion proche n'applique aucune projection au joueur.")
		failures += 1
	if explosion.animation.sprite_frames.get_frame_count(&"explode") != 16:
		push_error("L'explosion ne possède pas ses 16 frames.")
		failures += 1

	print("Bazooka vérifié: ressource, audio de tir, roquette, recul, explosion, dégâts, erreurs: %d" % failures)
	launcher.queue_free()
	quit(1 if failures > 0 else 0)
