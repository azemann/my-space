extends SceneTree

const LADDER_SCRIPT = preload("res://game/serre/gameplay/ladder_area.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node = load("res://scenes/launchers/niveau-01.tscn").instantiate()
	root.add_child(main)
	await physics_frame
	var player: CharacterBody2D = main.get_node("Player")
	var cases := [
		{"path": "Level/Collisions/Echelle", "top": 417.0, "height": 223.0, "shape_count": 3},
		{"path": "Level/Collisions/Chaine", "top": 320.0, "height": 192.0, "shape_count": 1},
	]
	var failures := 0
	for test_case: Dictionary in cases:
		var area: Area2D = main.get_node(test_case.path)
		var collisions := area.find_children("*", "CollisionShape2D", false, false)
		if collisions.size() != test_case.shape_count:
			push_error("%s contient %d collisions au lieu de %d." % [area.name, collisions.size(), test_case.shape_count])
			failures += 1
			continue
		var collision := collisions[0] as CollisionShape2D
		var shape := collision.shape as RectangleShape2D
		var trigger_top := area.global_position.y + collision.position.y - shape.size.y * 0.5
		if area.get_script() != LADDER_SCRIPT:
			push_error("%s n'utilise pas LadderArea." % area.name)
			failures += 1
		if not is_equal_approx(shape.size.y, test_case.height):
			push_error("%s a une hauteur de zone incorrecte: %s." % [area.name, shape.size.y])
			failures += 1
		if not is_equal_approx(trigger_top, test_case.top):
			push_error("%s s'arrête à y=%s au lieu du rebord y=%s." % [area.name, trigger_top, test_case.top])
			failures += 1
		for extra_collision in collisions:
			var extra_shape := extra_collision.shape as RectangleShape2D
			if extra_shape == null or extra_shape.size.x <= 0.0 or extra_shape.size.y <= 0.0:
				push_error("%s possède une collision d'escalade invalide." % area.name)
				failures += 1

	print("Climbables vérifiés: %d, erreurs: %d" % [cases.size(), failures])
	player.queue_free()
	main.queue_free()
	quit(1 if failures > 0 else 0)
