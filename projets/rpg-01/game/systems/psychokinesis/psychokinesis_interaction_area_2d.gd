class_name PsychokinesisInteractionArea2D
extends Area2D

## Zone de survol attachée à un PsychokineticBody2D. Elle traduit la collision
## de sélection en état de pointeur utilisable par le détecteur de cibles.

## Émis quand la souris entre ou sort de la zone de sélection de l'objet.
signal hover_changed(target: PsychokineticBody2D, hovered: bool)

var target: PsychokineticBody2D
var is_hovered := false


func _ready() -> void:
	target = get_parent() as PsychokineticBody2D
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## Efface l'état de survol, par exemple après une reconstruction de l'objet.
func reset() -> void:
	set_hovered(false)


## Modifie l'état de survol et avertit le corps psychokinétique propriétaire.
func set_hovered(value: bool) -> void:
	if is_hovered == value:
		return
	is_hovered = value
	if target != null:
		hover_changed.emit(target, is_hovered)


## Teste précisément un point mondial contre la forme rectangulaire ou circulaire de survol.
func contains_world_point(world_point: Vector2, tolerance_px := 0.0) -> bool:
	var collision := get_node_or_null("HoverShape") as CollisionShape2D
	if collision == null or collision.disabled or collision.shape == null:
		return false
	var local_point := collision.to_local(world_point)
	if collision.shape is RectangleShape2D:
		var half_size := (collision.shape as RectangleShape2D).size * 0.5 + Vector2.ONE * tolerance_px
		return absf(local_point.x) <= half_size.x and absf(local_point.y) <= half_size.y
	if collision.shape is CircleShape2D:
		return local_point.length() <= (collision.shape as CircleShape2D).radius + tolerance_px
	return false


## Aligne la zone de sélection sur le visuel lorsque celui-ci lévite.
func follow_lift(focus_offset: Vector2, height: float, bob: float) -> void:
	position = focus_offset + Vector2(0.0, -height - bob)


func _on_mouse_entered() -> void:
	set_hovered(true)


func _on_mouse_exited() -> void:
	set_hovered(false)
