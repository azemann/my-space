class_name PlayerController
extends CharacterBody2D

## Contrôleur du personnage jouable. Il transforme les actions du Input Map en
## déplacement physique, orientation, animation et demandes d'interaction.

## Émis lorsque la direction regardée change.
signal facing_changed(direction: StringName, vector: Vector2)
## Émis quand le joueur demande une interaction devant lui.
signal interaction_requested(origin: Vector2, direction: Vector2)

## Ressource qui centralise les vitesses, actions et conventions d'animation.
@export var config: PlayerConfig
## Autorise les commandes du joueur. Désactivé temporairement pendant les transitions.
@export var controls_enabled := true

@onready var visual: Node2D = $Visual
@onready var animated_sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D
@onready var interaction_origin: Marker2D = $InteractionOrigin
@onready var inventory: InventoryComponent = $Inventory

var facing: StringName = &"south"
var facing_vector := Vector2.DOWN


func _ready() -> void:
	if config == null:
		push_error("PlayerConfig absent sur le joueur.")
		set_physics_process(false)
		return
	_update_interaction_origin()
	_play_animation(false)


func _physics_process(delta: float) -> void:
	if not controls_enabled or config == null:
		velocity = velocity.move_toward(Vector2.ZERO, config.deceleration * delta if config else 1000.0 * delta)
		move_and_slide()
		_play_animation(false)
		return
	var input_vector := Input.get_vector(
		config.move_left_action,
		config.move_right_action,
		config.move_up_action,
		config.move_down_action,
		config.input_deadzone
	)
	if not input_vector.is_zero_approx():
		_set_facing_from_vector(input_vector)
	var speed := config.walk_speed
	if Input.is_action_pressed(config.run_action):
		speed *= config.run_multiplier
	var target_velocity := input_vector * speed
	var rate := config.acceleration if not input_vector.is_zero_approx() else config.deceleration
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()
	_play_animation(velocity.length() > config.animation_velocity_threshold)


func _unhandled_input(event: InputEvent) -> void:
	if controls_enabled and config != null and event.is_action_pressed(config.interact_action):
		interaction_requested.emit(interaction_origin.global_position, facing_vector)
		get_viewport().set_input_as_handled()


## Active ou bloque les commandes tout en arrêtant proprement le déplacement.
func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
		_play_animation(false)


func _set_facing_from_vector(direction: Vector2) -> void:
	var next_facing: StringName
	var next_vector: Vector2
	if absf(direction.x) > absf(direction.y):
		next_facing = &"east" if direction.x > 0.0 else &"west"
		next_vector = Vector2.RIGHT if direction.x > 0.0 else Vector2.LEFT
	else:
		next_facing = &"south" if direction.y > 0.0 else &"north"
		next_vector = Vector2.DOWN if direction.y > 0.0 else Vector2.UP
	if next_facing == facing:
		return
	facing = next_facing
	facing_vector = next_vector
	_update_interaction_origin()
	set_meta("facing", facing)
	facing_changed.emit(facing, facing_vector)


func _update_interaction_origin() -> void:
	interaction_origin.position = facing_vector * config.interaction_distance + Vector2(0, -6)


func _play_animation(moving: bool) -> void:
	if animated_sprite == null or config == null:
		return
	var prefix := config.walk_prefix if moving else config.idle_prefix
	var animation := StringName("%s_%s" % [prefix, facing])
	if animated_sprite.animation != animation:
		animated_sprite.play(animation)
