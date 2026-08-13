extends CharacterBody2D

const Actions = preload("res://game/serre/contracts/input_actions.gd")

## Ressource regroupant vitesse, accélérations, saut, gravité et escalade.
@export var config: PlayerConfig = preload("res://resources/characters/player-default.tres")
## Ressource de cadrage : décalage, lissage et limites mondiales.
@export var camera_profile: CameraProfile = preload("res://resources/camera/platformer-default.tres")
## Ressource contrôlant portée, longueur, rembobinage et sensations du grappin.
@export var grapple_config = preload("res://resources/characters/grapple-worms-like.tres")

var spawn_point := Vector2.ZERO
var coyote_left := 0.0
var jump_buffer_left := 0.0
var facing := 1.0
var ladders_in_range := 0
var is_climbing := false
var grapple_active := false
var grapple_anchor_local := Vector2.ZERO
var grapple_collider: Node2D
var grapple_length := 0.0
var grapple_pose_time := 0.0
var grapple_release_left := 0.0
var jump_takeoff_left := 0.0
var landing_pose_left := 0.0
@onready var equipment = get_node_or_null("Equipment")
@onready var body_sprite: AnimatedSprite2D = get_node_or_null("BodySprite")
@onready var health: HealthComponent = get_node_or_null("Health")


func _ready() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera and camera_profile:
		camera.position = camera_profile.offset
		camera.position_smoothing_enabled = camera_profile.smoothing_enabled
		camera.position_smoothing_speed = camera_profile.smoothing_speed
		camera.limit_left = camera_profile.limits.position.x
		camera.limit_top = camera_profile.limits.position.y
		camera.limit_right = camera_profile.limits.end.x
		camera.limit_bottom = camera_profile.limits.end.y
	if equipment:
		equipment.primary_pressed.connect(_on_equipment_primary_pressed)
		equipment.primary_released.connect(_on_equipment_primary_released)
		equipment.holstered_changed.connect(_on_equipment_holstered_changed)
	if body_sprite:
		body_sprite.play(&"idle")
	queue_redraw()


func _physics_process(delta: float) -> void:
	var jump_down := Input.is_action_pressed(Actions.JUMP)
	var jump_pressed := Input.is_action_just_pressed(Actions.JUMP)
	if grapple_active and jump_pressed:
		release_grapple()

	if grapple_active:
		_process_grapple(delta)
		_update_visual_direction()
		_update_character_animation(delta)
		queue_redraw()
		return

	var climb_direction := Input.get_axis(Actions.CLIMB_UP, Actions.CLIMB_DOWN)
	if ladders_in_range > 0 and climb_direction != 0.0:
		is_climbing = true
	if ladders_in_range == 0:
		is_climbing = false

	if is_climbing:
		velocity.y = climb_direction * config.climb_speed
		jump_buffer_left = 0.0
		coyote_left = 0.0
		if jump_pressed:
			is_climbing = false
			velocity.y = config.jump_velocity
			jump_takeoff_left = 0.15
	else:
		if not is_on_floor():
			velocity.y += config.gravity * delta
			coyote_left -= delta
		else:
			coyote_left = config.coyote_time

		if jump_pressed:
			jump_buffer_left = config.jump_buffer
		jump_buffer_left -= delta
		if jump_buffer_left > 0.0 and coyote_left > 0.0:
			velocity.y = config.jump_velocity
			jump_buffer_left = 0.0
			coyote_left = 0.0
			jump_takeoff_left = 0.15
		if not jump_down and velocity.y < config.short_jump_velocity:
			velocity.y = config.short_jump_velocity

	var direction := Input.get_axis(Actions.MOVE_LEFT, Actions.MOVE_RIGHT)
	if direction != 0.0:
		facing = sign(direction)
	var acceleration := config.acceleration if is_on_floor() else config.air_acceleration
	velocity.x = move_toward(velocity.x, direction * config.speed, acceleration * delta)

	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		landing_pose_left = 0.14
	_update_visual_direction()
	_update_character_animation(delta)
	if global_position.y > 820.0:
		respawn()
	queue_redraw()


func _fire_grapple() -> void:
	var origin: Vector2 = equipment.get_muzzle_global_position() if equipment else global_position
	var direction: Vector2 = equipment.get_aim_direction() if equipment else get_global_mouse_position() - origin
	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT.rotated(deg_to_rad(grapple_config.launch_fallback_angle))
		direction.x *= facing
	direction = direction.normalized()
	var query := PhysicsRayQueryParameters2D.create(
		origin,
		origin + direction * grapple_config.max_distance,
		1,
		[get_rid()]
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider := hit.get("collider") as Node2D
	if collider:
		attach_grapple_to(collider, hit.position)


func _on_equipment_primary_pressed(definition: Resource) -> void:
	if str(definition.get("weapon_id")) == "grappling_pistol":
		if grapple_active:
			release_grapple()
		else:
			_fire_grapple()
		return
	var projectile_scene := definition.get("projectile_scene") as PackedScene
	if projectile_scene:
		_fire_projectile_weapon(definition, projectile_scene, 1.0)


func _on_equipment_primary_released(definition: Resource, power: float, direction: Vector2) -> void:
	var projectile_scene := definition.get("projectile_scene") as PackedScene
	if projectile_scene:
		_fire_projectile_weapon(definition, projectile_scene, power, direction)


func _on_equipment_holstered_changed(holstered: bool, _definition: Resource) -> void:
	if holstered and grapple_active:
		release_grapple()


func _fire_projectile_weapon(definition: Resource, projectile_scene: PackedScene, power := 1.0, firing_direction := Vector2.ZERO) -> void:
	if grapple_active:
		release_grapple()
	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return
	var parent := get_tree().current_scene if get_tree().current_scene else get_parent()
	parent.add_child(projectile)
	projectile.global_position = equipment.get_muzzle_global_position() if equipment else global_position
	var direction: Vector2 = firing_direction
	if direction.length_squared() < 0.01:
		direction = equipment.get_aim_direction() if equipment else Vector2.RIGHT * facing
	if projectile.has_method("launch"):
		projectile.launch(direction, self, velocity, power)
	var recoil := float(definition.get("recoil_impulse"))
	velocity -= direction * recoil * power


func _process_grapple(delta: float) -> void:
	if not is_instance_valid(grapple_collider):
		release_grapple()
		return
	is_climbing = false
	var anchor := get_grapple_anchor()
	var radial := global_position - anchor
	if radial.length_squared() < 1.0:
		radial = Vector2.DOWN
	else:
		radial = radial.normalized()

	var rope_input := Input.get_axis(Actions.ROPE_REEL_IN, Actions.ROPE_REEL_OUT)
	grapple_length = clampf(
		grapple_length + rope_input * grapple_config.reel_speed * delta,
		grapple_config.min_length,
		grapple_config.max_distance
	)

	var swing_input := Input.get_axis(Actions.MOVE_LEFT, Actions.MOVE_RIGHT)
	var tangent := Vector2(-radial.y, radial.x)
	if tangent.x < 0.0:
		tangent = -tangent
	velocity += tangent * swing_input * grapple_config.swing_acceleration * delta
	velocity.y += config.gravity * delta
	velocity = velocity.limit_length(grapple_config.maximum_speed)
	if swing_input != 0.0:
		facing = sign(swing_input)

	move_and_slide()
	_enforce_grapple_constraint()


func _enforce_grapple_constraint() -> void:
	if not grapple_active:
		return
	var anchor := get_grapple_anchor()
	var offset := global_position - anchor
	var distance := offset.length()
	if distance <= grapple_length or distance <= 0.001:
		return
	var radial := offset / distance
	global_position = anchor + radial * grapple_length
	var outward_speed := velocity.dot(radial)
	if outward_speed > 0.0:
		velocity -= radial * outward_speed


func can_grapple_to(collider: Object) -> bool:
	if collider == null:
		return false
	if bool(collider.get_meta("grapple_enabled", false)):
		return true
	var kind := str(collider.get_meta("tiled_type", collider.get_meta("kind", "")))
	return kind in ["one_way", "grapple_surface"]


func attach_grapple_to(collider: Node2D, anchor_position: Vector2) -> bool:
	if not can_grapple_to(collider):
		return false
	var distance := global_position.distance_to(anchor_position)
	if distance > grapple_config.max_distance or distance < grapple_config.min_length * 0.5:
		return false
	grapple_collider = collider
	grapple_anchor_local = collider.to_local(anchor_position)
	grapple_length = clampf(distance, grapple_config.min_length, grapple_config.max_distance)
	grapple_active = true
	grapple_pose_time = 0.0
	grapple_release_left = 0.0
	is_climbing = false
	queue_redraw()
	return true


func get_grapple_anchor() -> Vector2:
	if not is_instance_valid(grapple_collider):
		return global_position
	return grapple_collider.to_global(grapple_anchor_local)


func release_grapple() -> void:
	if grapple_active:
		grapple_release_left = 0.16
	grapple_active = false
	grapple_collider = null
	queue_redraw()


func enter_ladder() -> void:
	ladders_in_range += 1


func exit_ladder() -> void:
	ladders_in_range = maxi(0, ladders_in_range - 1)
	if ladders_in_range == 0:
		is_climbing = false


func bounce(impulse := -620.0) -> void:
	is_climbing = false
	velocity.y = impulse


func take_damage(amount: int) -> void:
	if health == null:
		return
	health.apply_damage(amount)
	if health.current_health <= 0:
		respawn()
		health.reset()


func receive_explosion(damage: int, impulse: Vector2, _origin: Vector2) -> void:
	release_grapple()
	is_climbing = false
	velocity += impulse
	take_damage(damage)


func respawn() -> void:
	release_grapple()
	grapple_release_left = 0.0
	global_position = spawn_point
	velocity = Vector2.ZERO
	ladders_in_range = 0
	is_climbing = false


func get_standing_half_height() -> float:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var capsule := collision.shape as CapsuleShape2D if collision else null
	return capsule.height * 0.5 if capsule else 20.0


func _update_visual_direction() -> void:
	if body_sprite:
		body_sprite.flip_h = facing < 0.0


func _update_character_animation(delta: float) -> void:
	if body_sprite == null:
		return
	if grapple_active:
		grapple_pose_time += delta
		var grapple_frame := 0
		if grapple_pose_time < 0.25:
			grapple_frame = mini(2, int(grapple_pose_time / (0.25 / 3.0)))
		elif grapple_pose_time < 0.5:
			grapple_frame = 3 + mini(2, int((grapple_pose_time - 0.25) / (0.25 / 3.0)))
		elif Input.is_action_pressed(Actions.ROPE_REEL_IN):
			grapple_frame = 12 + int(fmod(grapple_pose_time * 10.0, 2.0))
		else:
			grapple_frame = 6 + int(fmod((grapple_pose_time - 0.5) * 12.0, 6.0))
		_set_manual_animation_frame(&"grapple", grapple_frame)
		return
	if grapple_release_left > 0.0 and not is_on_floor():
		grapple_release_left = maxf(0.0, grapple_release_left - delta)
		_set_manual_animation_frame(&"grapple", 14 if grapple_release_left > 0.08 else 15)
		return
	if is_climbing:
		_play_loop(&"climb", absf(velocity.y) / maxf(config.climb_speed, 1.0))
		if is_zero_approx(velocity.y):
			body_sprite.pause()
		return
	if not is_on_floor():
		if jump_takeoff_left > 0.0:
			jump_takeoff_left = maxf(0.0, jump_takeoff_left - delta)
			var takeoff_phase := 1.0 - jump_takeoff_left / 0.15
			_set_manual_animation_frame(&"jump", 3 + mini(2, int(takeoff_phase * 3.0)))
		elif velocity.y < -400.0:
			_set_manual_animation_frame(&"jump", 6)
		elif velocity.y < -180.0:
			_set_manual_animation_frame(&"jump", 7)
		elif velocity.y < -40.0:
			_set_manual_animation_frame(&"jump", 8)
		elif velocity.y < 100.0:
			_set_manual_animation_frame(&"jump", 10)
		elif velocity.y < 300.0:
			_set_manual_animation_frame(&"jump", 11)
		elif velocity.y < 500.0:
			_set_manual_animation_frame(&"jump", 12)
		else:
			_set_manual_animation_frame(&"jump", 13)
		return
	jump_takeoff_left = 0.0
	if landing_pose_left > 0.0:
		landing_pose_left = maxf(0.0, landing_pose_left - delta)
		_set_manual_animation_frame(&"jump", 14 if landing_pose_left > 0.07 else 15)
	elif absf(velocity.x) > 5.0:
		_play_loop(&"walk", absf(velocity.x) / maxf(config.speed, 1.0))
	else:
		_play_loop(&"idle")


func _play_loop(animation_name: StringName, speed_scale := 1.0) -> void:
	body_sprite.speed_scale = clampf(speed_scale, 0.1, 2.0)
	if body_sprite.animation != animation_name or not body_sprite.is_playing():
		body_sprite.play(animation_name)


func _set_manual_animation_frame(animation_name: StringName, frame_index: int) -> void:
	body_sprite.animation = animation_name
	body_sprite.pause()
	body_sprite.frame = clampi(frame_index, 0, 15)


func _draw() -> void:
	if grapple_active and is_instance_valid(grapple_collider):
		var rope_start: Vector2 = to_local(equipment.get_muzzle_global_position()) if equipment else Vector2.ZERO
		draw_line(rope_start, to_local(get_grapple_anchor()), grapple_config.rope_color, grapple_config.rope_width, false)
