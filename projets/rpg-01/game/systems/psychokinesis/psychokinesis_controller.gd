class_name PsychokinesisController
extends Node2D

## Orchestre la sélection, la prise, le déplacement vertical et la projection
## des objets psychokinétiques à la souris, au clavier ou à la manette.

@export_category("Portée du pouvoir")
## Distance maximale entre Azeman et une cible détectable.
@export_range(16.0, 320.0, 1.0, "suffix:px") var acquisition_range := 208.0
## Distance maximale à laquelle un objet déjà saisi peut être déplacé.
@export_range(16.0, 320.0, 1.0, "suffix:px") var control_radius := 224.0
## Impulsion horizontale maximale transmise à un objet projeté à pleine charge.
@export_range(10.0, 1000.0, 10.0, "suffix:impulse") var throw_impulse := 340.0
## Distance visée à pleine inclinaison de manette ou lors d'une projection sans direction explicite.
@export_range(32.0, 512.0, 1.0, "suffix:px") var full_aim_distance := 120.0
## Vitesse de déplacement du curseur virtuel contrôlé à la manette.
@export_range(16.0, 512.0, 1.0, "suffix:px/s") var gamepad_cursor_speed := 180.0
## Quantité de hauteur ajoutée ou retirée à chaque commande verticale.
@export_range(1.0, 32.0, 1.0, "suffix:px") var height_step := 6.0
## Durée nécessaire pour atteindre la puissance maximale de projection.
@export_range(0.1, 2.0, 0.05, "suffix:s") var maximum_charge_time := 0.85
## Niveau actuel du pouvoir, comparé au niveau requis par chaque objet.
@export_range(0, 10, 1) var power_level := 0

@export_category("Manipulation directe")
## Conserve sous la souris le point saisi au lieu d'y téléporter l'ancre des pieds.
@export var preserve_mouse_grab_point := true

var player: PlayerController
var held_body: PsychokineticBody2D
var targeted_body: PsychokineticBody2D
var charge_time := 0.0
var is_charging := false
var controls_enabled := true

var _using_mouse := true
var _control_position := Vector2.ZERO
var _charge_anchor := Vector2.ZERO
var _gamepad_offset := Vector2(72.0, 0.0)
var _mouse_grab_offset := Vector2.ZERO
var _mouse_grab_height := 0.0

@onready var target_detector := $TargetDetector as PsychokinesisTargetDetector
@onready var manipulation_anchor := $ManipulationAnchor as Marker2D
@onready var aim_indicator := $AimIndicator as PsychokinesisAimIndicator2D


func _ready() -> void:
	player = get_parent().get_node("PersistentActors/Player") as PlayerController
	aim_indicator.setup(self)


func _process(_delta: float) -> void:
	if not controls_enabled:
		return
	# Le survol est recalculé à chaque image à partir de la position réellement
	# affichée. Il ne dépend ni du serveur physique, ni d'un cache temporel.
	if held_body == null:
		_set_targeted_body(_find_target())


func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return
	if held_body != null and is_instance_valid(held_body):
		_update_gamepad_cursor(delta)
		if is_charging:
			_control_position = _charge_anchor
			charge_time = minf(charge_time + delta, maximum_charge_time)
			held_body.set_charge(charge_time / maximum_charge_time)
		elif _using_mouse:
			_control_position = _mouse_hold_target(_pointer_world_position())
		manipulation_anchor.global_position = _control_position
		held_body.move_held(manipulation_anchor.global_position, delta)
	else:
		held_body = null
	aim_indicator.refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled:
		return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		_using_mouse = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.25:
		_using_mouse = false

	if event.is_action_pressed(&"psychokinesis_grab"):
		if held_body == null:
			try_grab()
		else:
			drop_held()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"psychokinesis_cancel") and held_body != null:
		drop_held()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"psychokinesis_throw") and held_body != null:
		begin_charge()
		get_viewport().set_input_as_handled()
	elif event.is_action_released(&"psychokinesis_throw") and held_body != null and is_charging:
		release_throw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"psychokinesis_raise") and held_body != null:
		held_body.change_height(height_step)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"psychokinesis_lower") and held_body != null:
		held_body.change_height(-height_step)
		get_viewport().set_input_as_handled()


## Active ou bloque les commandes du pouvoir et annule toute manipulation en cours.
func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		cancel_manipulation()


## Tente de saisir la cible préférée ou la meilleure cible détectée.
func try_grab(preferred: PsychokineticBody2D = null) -> bool:
	if held_body != null or player == null:
		return false
	var candidate := preferred if preferred != null else _find_target()
	_set_targeted_body(candidate)
	if not _is_available_target(candidate):
		return false
	held_body = candidate
	targeted_body = candidate
	_control_position = candidate.global_position
	manipulation_anchor.global_position = _control_position
	if _using_mouse and preserve_mouse_grab_point:
		_mouse_grab_offset = candidate.global_position - _pointer_world_position()
	else:
		_mouse_grab_offset = Vector2.ZERO
	_mouse_grab_height = candidate.height
	_gamepad_offset = candidate.global_position - player.global_position
	if _gamepad_offset.is_zero_approx():
		_gamepad_offset = player.facing_vector * 72.0
	held_body.begin_hold(_control_position)
	if not held_body.impacted.is_connected(_on_body_impacted):
		held_body.impacted.connect(_on_body_impacted)
	return true


## Commence à charger une projection pour l'objet actuellement tenu.
func begin_charge() -> void:
	if held_body == null or is_charging:
		return
	is_charging = true
	charge_time = 0.0
	_charge_anchor = held_body.global_position
	_control_position = _charge_anchor
	held_body.begin_charge()


## Relâche l'objet tenu sans le projeter.
func drop_held() -> void:
	if held_body == null:
		return
	var body := held_body
	held_body = null
	is_charging = false
	charge_time = 0.0
	body.drop(player.velocity if player != null else Vector2.ZERO)
	body.set_targeted(false)
	targeted_body = null


## Annule toute sélection, charge ou prise en cours, notamment lors d'un changement de carte.
func cancel_manipulation() -> void:
	if held_body != null and is_instance_valid(held_body):
		drop_held()
	elif is_instance_valid(targeted_body):
		targeted_body.set_targeted(false)
	held_body = null
	targeted_body = null
	is_charging = false
	charge_time = 0.0


## Convertit la charge et la visée courantes en projection, puis libère l'objet.
func release_throw() -> void:
	if held_body == null:
		return
	var aim_target := aim_world_position()
	var aim_vector := aim_target - held_body.global_position
	var direction := aim_vector.normalized()
	if direction.is_zero_approx() and player != null:
		direction = player.facing_vector
	var charge_ratio := clampf(charge_time / maximum_charge_time, 0.0, 1.0)
	var aim_ratio := clampf(aim_vector.length() / full_aim_distance, 0.0, 1.0)
	throw_held(charge_ratio * 0.72 + aim_ratio * 0.28, direction)


## Projette directement l'objet tenu avec une puissance et une direction données.
func throw_held(power := 0.0, direction := Vector2.ZERO) -> void:
	if held_body == null or player == null:
		return
	var body := held_body
	held_body = null
	is_charging = false
	charge_time = 0.0
	var impulse_scale := lerpf(0.72, 1.42, clampf(power, 0.0, 1.0))
	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = player.facing_vector
	body.launch(launch_direction * throw_impulse * impulse_scale, clampf(power, 0.0, 1.0))
	body.set_targeted(false)
	targeted_body = null


func _clamp_to_control_radius(world_position: Vector2) -> Vector2:
	if player == null:
		return world_position
	var offset := world_position - player.global_position
	return player.global_position + offset.limit_length(control_radius)


func _mouse_hold_target(pointer_world_position: Vector2) -> Vector2:
	var desired := pointer_world_position
	if preserve_mouse_grab_point and held_body != null:
		desired += _mouse_grab_offset
		desired.y += held_body.height - _mouse_grab_height
	return _clamp_to_control_radius(desired)


## Renvoie la position mondiale actuellement indiquée comme destination de visée.
func aim_world_position() -> Vector2:
	if _using_mouse:
		return _pointer_world_position()
	return player.global_position + _gamepad_offset if player != null else _control_position


func _aim_world_position() -> Vector2:
	return aim_world_position()


func _update_gamepad_cursor(delta: float) -> void:
	if _using_mouse or player == null:
		return
	var stick := Input.get_vector(
		&"psychokinesis_move_left",
		&"psychokinesis_move_right",
		&"psychokinesis_move_up",
		&"psychokinesis_move_down"
	)
	if stick.length_squared() > 0.01:
		_gamepad_offset = (_gamepad_offset + stick * gamepad_cursor_speed * delta).limit_length(control_radius)
	if not is_charging:
		_control_position = player.global_position + _gamepad_offset


func _find_target() -> PsychokineticBody2D:
	return _find_hovered_target(_pointer_world_position()) if _using_mouse else _find_nearest_target()


func _pointer_world_position() -> Vector2:
	# CanvasItem fournit directement la souris dans le même monde 2D que les
	# HoverShape. Cela évite de mélanger fenêtre physique, viewport étiré et caméra.
	return get_global_mouse_position()


func _find_hovered_target(pointer_world_position: Vector2) -> PsychokineticBody2D:
	return target_detector.find_at_world_point(
		pointer_world_position, player, acquisition_range, power_level)


func _is_available_target(body: PsychokineticBody2D) -> bool:
	return target_detector.is_available(body, player, acquisition_range, power_level)


func _nearby_targets() -> Array[PsychokineticBody2D]:
	return target_detector.nearby_targets(player, acquisition_range, power_level)


func _is_drawn_in_front(candidate: PsychokineticBody2D, current: PsychokineticBody2D, pointer_world_position: Vector2) -> bool:
	return target_detector.is_drawn_in_front(candidate, current, pointer_world_position)


func _find_nearest_target() -> PsychokineticBody2D:
	if player == null:
		return null
	var aim_direction := Input.get_vector(
		&"psychokinesis_move_left",
		&"psychokinesis_move_right",
		&"psychokinesis_move_up",
		&"psychokinesis_move_down"
	)
	if aim_direction.length_squared() < 0.04:
		aim_direction = player.facing_vector
	return target_detector.find_directional(
		player, acquisition_range, power_level, aim_direction)


func _set_targeted_body(next_target: PsychokineticBody2D) -> void:
	if next_target == targeted_body:
		return
	if is_instance_valid(targeted_body):
		targeted_body.set_targeted(false)
	targeted_body = next_target
	if targeted_body != null:
		targeted_body.set_targeted(true)


func _on_body_impacted(_body: PsychokineticBody2D, speed: float) -> void:
	var camera := get_parent().get_node_or_null("Camera") as FollowCamera2D
	if camera != null:
		camera.add_impact_shake(clampf(speed / 420.0, 0.2, 1.0))
