class_name PsychokineticBody2D
extends RigidBody2D

signal grabbed(body: PsychokineticBody2D)
signal dropped(body: PsychokineticBody2D)
signal thrown(body: PsychokineticBody2D, impulse: Vector2)
signal impacted(body: PsychokineticBody2D, speed: float)

@export_category("Identité psychokinétique")
## Données de gameplay partagées : réponse, masse logique, matière et niveau requis.
@export var profile: PsychokinesisProfile

@export_category("Poursuite physique")
@export_range(1.0, 40.0, 0.5) var hold_response := 26.0
@export_range(40.0, 800.0, 5.0, "suffix:px/s") var maximum_follow_speed := 560.0
@export_range(100.0, 4000.0, 25.0, "suffix:px/s²") var hold_acceleration := 3000.0

@export_category("Hauteur physique abstraite")
@export_range(0.0, 128.0, 1.0, "suffix:px") var maximum_height := 48.0
@export_range(0.0, 128.0, 1.0, "suffix:px") var default_hold_height := 20.0
@export_range(0.0, 8.0, 0.1, "suffix:px") var float_amplitude := 1.8
@export_range(0.1, 8.0, 0.1, "suffix:Hz") var float_frequency := 1.7
@export_range(20.0, 400.0, 5.0, "suffix:px/s") var throw_vertical_speed := 115.0
@export_range(20.0, 800.0, 5.0, "suffix:px/s²") var aerial_gravity := 290.0

@export_category("Contrat spatial")
## Centre de la silhouette relativement à l'ancre au sol, calculé par le pipeline d'asset.
@export var visual_focus_offset := Vector2(0.0, -30.0)
## Secours pour une ancienne scène sans SelectionArea ; les scènes V2 doivent toutes en posséder une.
@export_range(4.0, 96.0, 1.0, "suffix:px") var selection_radius := 30.0
@export var blocks_actors_when_grounded := false
@export var effects_enabled := true

var is_held := false
var is_thrown := false
var is_targeted := false
var hold_target := Vector2.ZERO
var height := 0.0
var target_height := 0.0
var vertical_velocity := 0.0
var charge_ratio := 0.0

var is_pointer_over: bool:
	get:
		return interaction != null and interaction.is_hovered

@onready var state_machine := get_node_or_null("StateMachine") as PsychokinesisStateMachine
@onready var presentation := get_node_or_null("Presentation") as PsychokinesisPresentation2D
@onready var interaction := get_node_or_null("SelectionArea") as PsychokinesisInteractionArea2D
@onready var visual := get_node_or_null("Visual") as Node2D
@onready var selection_ghost := get_node_or_null("SelectionGhost") as Node2D
@onready var selection_area := interaction as Area2D
@onready var shadow := get_node_or_null("Shadow") as Node2D

# Alias temporaires conservés pour les tests et outils d'inspection existants.
var _shadow_origin_scale := Vector2.ONE
var _shadow_origin_color := Color.WHITE
var _float_time := 0.0
var _grab_elapsed := 1.0
var _ground_collision_layer := 4


func _ready() -> void:
	add_to_group(&"psychokinetic_targets")
	sleeping_state_changed.connect(_refresh_processing_state)
	gravity_scale = 0.0
	linear_damp = 4.0
	angular_damp = 2.5
	_ground_collision_layer = collision_layer
	if interaction == null or state_machine == null or presentation == null:
		push_error("%s ne respecte pas la composition psychokinétique V2." % name)
		return
	presentation.setup(self)
	_shadow_origin_scale = presentation.shadow_origin_scale
	_shadow_origin_color = presentation.shadow_origin_color
	_update_elevation_visual()
	_refresh_processing_state()


func restore_persistent_state(world_position: Vector2, world_rotation: float) -> void:
	freeze = true
	global_position = world_position
	global_rotation = world_rotation
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	is_held = false
	is_thrown = false
	is_targeted = false
	height = 0.0
	target_height = 0.0
	vertical_velocity = 0.0
	charge_ratio = 0.0
	if state_machine != null:
		state_machine.reset()
	if interaction != null:
		interaction.reset()
	if presentation != null:
		presentation.reset()
	freeze = true
	sleeping = true
	_restore_ground_collision()
	_update_elevation_visual()
	_sync_shadow_to_ground()
	_refresh_processing_state()


func _process(delta: float) -> void:
	if presentation != null:
		presentation.tick(delta, _float_time)
	_refresh_processing_state()


func _physics_process(delta: float) -> void:
	_float_time += delta
	_grab_elapsed += delta
	if is_thrown:
		vertical_velocity -= aerial_gravity * delta
		height += vertical_velocity * delta
		if height <= 0.0 and vertical_velocity < 0.0:
			_land()
	else:
		var acceleration := (target_height - height) * 80.0 - vertical_velocity * 18.0
		vertical_velocity += acceleration * delta
		height = clampf(height + vertical_velocity * delta, 0.0, maximum_height)
		if height == 0.0 or height == maximum_height:
			vertical_velocity = 0.0
		if height <= 0.01 and not is_held:
			_restore_ground_collision()
			if state_machine != null and state_machine.state == PsychokinesisStateMachine.State.LANDING:
				state_machine.transition(PsychokinesisStateMachine.State.IDLE)
	_update_elevation_visual()
	_refresh_processing_state()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not is_held:
		return
	var error := hold_target - state.transform.origin
	var desired_velocity := (error * hold_response).limit_length(maximum_follow_speed)
	var mass_response := 1.0 / sqrt(maxf(mass, 0.25))
	state.linear_velocity = state.linear_velocity.move_toward(
		desired_velocity,
		hold_acceleration * mass_response * state.step
	)
	state.angular_velocity = move_toward(state.angular_velocity, 0.0, 12.0 * state.step)


func can_be_grabbed(power_level: int) -> bool:
	return profile != null and profile.can_be_moved(power_level)


func begin_hold(target_position: Vector2) -> void:
	if state_machine == null or not state_machine.transition(PsychokinesisStateMachine.State.HELD):
		return
	is_held = true
	is_thrown = false
	hold_target = target_position
	freeze = false
	sleeping = false
	linear_velocity *= 0.2
	angular_velocity = 0.0
	target_height = clampf(default_hold_height, 0.0, maximum_height)
	charge_ratio = 0.0
	_set_airborne_collision()
	_grab_elapsed = 0.0
	presentation.on_hold_started()
	_refresh_processing_state()
	grabbed.emit(self)


func begin_charge() -> void:
	if not is_held or state_machine == null:
		return
	state_machine.transition(PsychokinesisStateMachine.State.CHARGING)


func move_held(target_position: Vector2, _delta: float) -> void:
	if is_held:
		hold_target = target_position


func change_height(amount: float) -> void:
	if is_held:
		target_height = clampf(target_height + amount, 0.0, maximum_height)


func set_targeted(value: bool) -> void:
	if is_targeted == value:
		return
	is_targeted = value
	if state_machine != null and not is_held and not is_thrown:
		if value:
			state_machine.transition(PsychokinesisStateMachine.State.TARGETED)
		elif state_machine.state == PsychokinesisStateMachine.State.TARGETED:
			state_machine.transition(PsychokinesisStateMachine.State.IDLE)
	if not value and not is_held and presentation != null:
		presentation.clear_target_highlight()
	_refresh_processing_state()


func set_charge(value: float) -> void:
	charge_ratio = clampf(value, 0.0, 1.0)
	if charge_ratio > 0.0:
		begin_charge()
	elif state_machine != null and state_machine.state == PsychokinesisStateMachine.State.CHARGING:
		state_machine.transition(PsychokinesisStateMachine.State.HELD)
	queue_redraw()


func drop(inherited_velocity := Vector2.ZERO) -> void:
	if not is_held:
		return
	state_machine.transition(PsychokinesisStateMachine.State.LANDING)
	is_held = false
	is_thrown = false
	freeze = false
	target_height = 0.0
	linear_velocity = inherited_velocity
	charge_ratio = 0.0
	presentation.on_released()
	_refresh_processing_state()
	dropped.emit(self)


func launch(impulse: Vector2, power := 0.0) -> void:
	if not is_held:
		return
	state_machine.transition(PsychokinesisStateMachine.State.THROWN)
	is_held = false
	is_thrown = true
	freeze = false
	target_height = 0.0
	vertical_velocity = throw_vertical_speed * lerpf(0.85, 1.25, clampf(power, 0.0, 1.0))
	charge_ratio = 0.0
	_set_airborne_collision()
	presentation.on_thrown()
	_refresh_processing_state()
	apply_central_impulse(impulse)
	angular_velocity = clampf(impulse.length() * 0.012, 1.5, 7.0)
	thrown.emit(self, impulse)


func pointer_distance(pointer_world_position: Vector2) -> float:
	return pointer_world_position.distance_to(lifted_global_position())


func selection_contains_point(pointer_world_position: Vector2, tolerance_px := 0) -> bool:
	if interaction != null:
		return interaction.contains_world_point(pointer_world_position, float(tolerance_px))
	return pointer_distance(pointer_world_position) <= selection_radius + float(tolerance_px)


func lifted_global_position() -> Vector2:
	return global_position + visual_focus_offset + Vector2(0.0, -height)


func current_state() -> PsychokinesisStateMachine.State:
	return state_machine.state if state_machine != null else PsychokinesisStateMachine.State.IDLE


# Sondes publiques utiles aux tests sans simuler une souris système.
func _on_selection_area_mouse_entered() -> void:
	if interaction != null:
		interaction.set_hovered(true)


func _on_selection_area_mouse_exited() -> void:
	if interaction != null:
		interaction.set_hovered(false)


func _update_elevation_visual() -> void:
	if presentation == null:
		return
	var ratio := height / maximum_height if maximum_height > 0.0 else 0.0
	var bob := sin(_float_time * TAU * float_frequency) * float_amplitude * ratio if is_held else 0.0
	presentation.apply_elevation(height, bob, _grab_elapsed)


func _sync_shadow_to_ground() -> void:
	if presentation != null:
		presentation.sync_shadow_to_ground()


func _land() -> void:
	var impact_speed := maxf(linear_velocity.length(), absf(vertical_velocity))
	height = 0.0
	vertical_velocity = 0.0
	is_thrown = false
	linear_velocity *= 0.42
	angular_velocity *= 0.55
	if state_machine != null:
		state_machine.transition(PsychokinesisStateMachine.State.LANDING)
		state_machine.transition(PsychokinesisStateMachine.State.IDLE)
	_restore_ground_collision()
	presentation.on_landed()
	_refresh_processing_state()
	impacted.emit(self, impact_speed)


func _set_airborne_collision() -> void:
	if blocks_actors_when_grounded:
		collision_layer = _ground_collision_layer & ~1


func _restore_ground_collision() -> void:
	if blocks_actors_when_grounded:
		collision_layer = _ground_collision_layer


func _refresh_processing_state() -> void:
	var physical_activity := is_held or is_thrown or (not freeze and not sleeping) \
		or height > 0.01 or absf(vertical_velocity) > 0.01
	var visual_activity := physical_activity or is_targeted
	set_physics_process(physical_activity)
	set_process(visual_activity)
