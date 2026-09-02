extends SceneTree

const LAUNCHERS := [
	"res://scenes/launchers/niveau-01.tscn",
	"res://scenes/launchers/niveau-02.tscn",
	"res://scenes/launchers/niveau-03.tscn",
	"res://scenes/launchers/niveau-04.tscn",
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	for launcher_path in LAUNCHERS:
		var packed := load(launcher_path) as PackedScene
		var launcher := packed.instantiate()
		root.add_child(launcher)
		await process_frame

		var equipment := launcher.get_node_or_null("Player/Equipment") as WeaponController
		var selector := launcher.get_node_or_null("Interface/WeaponSelection") as WeaponSelectionPanel
		if equipment == null or selector == null:
			push_error("Sélecteur ou équipement absent de %s." % launcher_path)
			failures += 1
		else:
			if selector.visible:
				push_error("Le sélecteur doit être fermé au démarrage dans %s." % launcher_path)
				failures += 1
			if selector.wheel == null or selector.wheel.slot_count != selector.wheel_slots:
				push_error("La roue de %s ne contient pas %d secteurs." % [launcher_path, selector.wheel_slots])
				failures += 1
			elif selector.wheel._slot_at_position(selector.wheel.size * 0.5 + Vector2.UP * selector.wheel.icon_radius) != 0:
				push_error("Le secteur supérieur de la roue de %s n'est pas le premier." % launcher_path)
				failures += 1
			selector.open_menu()
			await process_frame
			if not selector.visible or equipment.input_enabled:
				push_error("Ouvrir l'arsenal ne bloque pas correctement l'arme dans %s." % launcher_path)
				failures += 1
			if selector.wheel.inventory.size() != equipment.inventory.size():
				push_error("Les armes de l'inventaire ne correspondent pas à la roue dans %s." % launcher_path)
				failures += 1
			if not selector.selected_label.text.contains("Pistolet-grappin"):
				push_error("L'arme équipée n'est pas affichée dans %s." % launcher_path)
				failures += 1
			selector.wheel.set_highlighted_index(1)
			if not selector.selected_label.text.contains("Bazooka mécanique"):
				push_error("Le bazooka n'apparaît pas dans la roue de %s." % launcher_path)
				failures += 1
			selector._select_weapon(1)
			if equipment.equipped_index != 1 or selector.visible:
				push_error("Le deuxième secteur n'équipe pas le bazooka dans %s." % launcher_path)
				failures += 1
			equipment._begin_charge()
			equipment.holster()
			if not equipment.is_holstered or equipment.is_charging or equipment.weapon_sprite.visible:
				push_error("Ranger le bazooka ne le masque pas ou n'annule pas sa charge dans %s." % launcher_path)
				failures += 1
			if not selector.selected_label.text.contains("Rangé"):
				push_error("La roue n'indique pas que le bazooka est rangé dans %s." % launcher_path)
				failures += 1
			equipment.unholster()
			if equipment.is_holstered or not equipment.weapon_sprite.visible or equipment.equipped_index != 1:
				push_error("Ressortir le bazooka ne restaure pas l'équipement mémorisé dans %s." % launcher_path)
				failures += 1
			selector.open_menu()
			selector._select_weapon(0)
			if selector.visible or not equipment.input_enabled:
				push_error("Choisir une arme ne referme pas correctement l'arsenal dans %s." % launcher_path)
				failures += 1
			var player := launcher.get_node("Player") as CharacterBody2D
			var anchor := StaticBody2D.new()
			anchor.set_meta("grapple_enabled", true)
			launcher.add_child(anchor)
			anchor.global_position = player.global_position + Vector2(100, -50)
			player.attach_grapple_to(anchor, anchor.global_position)
			equipment.holster()
			if player.grapple_active:
				push_error("Ranger le grappin ne décroche pas la corde dans %s." % launcher_path)
				failures += 1
		launcher.queue_free()
		await process_frame

	print("Roue des armes vérifiée dans 4 lanceurs, erreurs: %d" % failures)
	quit(1 if failures > 0 else 0)
