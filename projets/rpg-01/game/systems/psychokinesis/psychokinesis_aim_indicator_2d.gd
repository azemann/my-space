class_name PsychokinesisAimIndicator2D
extends Node2D

## Dessine le lien entre le joueur, l'objet tenu et la direction de projection.
## Ce composant est uniquement visuel et ne modifie jamais la physique.

var controller: PsychokinesisController


## Relie l'indicateur au contrôleur dont il doit représenter l'état.
func setup(owner_controller: PsychokinesisController) -> void:
	controller = owner_controller


## Demande un nouveau dessin lors de la prochaine mise à jour visuelle.
func refresh() -> void:
	queue_redraw()


func _draw() -> void:
	if controller == null or controller.held_body == null \
		or not is_instance_valid(controller.held_body) or controller.player == null:
		return
	var start := to_local(controller.player.global_position + Vector2(0.0, -17.0))
	var end := to_local(controller.held_body.lifted_global_position())
	var pulse := 0.48 + sin(Time.get_ticks_msec() * 0.012) * 0.1
	var charge := controller.held_body.charge_ratio
	var color := Color(0.42, 0.78, 1.0, pulse).lerp(Color(0.91, 0.42, 1.0, 0.82), charge)
	draw_line(start, end, Color(color, 0.14 + charge * 0.12), 3.0 + charge * 1.5, false)
	draw_dashed_line(start, end, color, 1.2 + charge, 5.0, false)
	if controller.is_charging:
		var aim_end := to_local(controller.aim_world_position())
		draw_line(end, aim_end, Color(color, 0.22), 2.0, false)
		draw_dashed_line(end, aim_end, Color(color, 0.92), 1.25 + charge, 7.0, false)
		var direction := (aim_end - end).normalized()
		if not direction.is_zero_approx():
			var arrow_base := aim_end - direction * 9.0
			draw_line(aim_end, arrow_base + direction.rotated(0.65) * 7.0, color, 1.5)
			draw_line(aim_end, arrow_base + direction.rotated(-0.65) * 7.0, color, 1.5)
