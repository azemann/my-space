class_name BazookaExplosion
extends Area2D

signal detonated(position: Vector2, radius: float)

@export_group("Effet de combat")
## Dégâts infligés au centre de l'explosion. Ils diminuent progressivement jusqu'à 1 au bord du cercle DamageRadius.
@export_range(0, 10000, 1, "or_greater") var maximum_damage := 45
## Force maximale de projection en pixels par seconde au centre. Augmenter donne des envols plus violents.
@export_range(0.0, 5000.0, 1.0, "or_greater") var maximum_knockback := 520.0
## Couches physiques recherchées pour les dégâts. Les objets sans méthode de dégâts sont simplement ignorés.
@export_flags_2d_physics var damage_mask := 1

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_shape: CollisionShape2D = $DamageRadius
@onready var explosion_audio: AudioStreamPlayer2D = $ExplosionAudio


func _ready() -> void:
	call_deferred("_begin_explosion")


func _begin_explosion() -> void:
	detonated.emit(global_position, get_damage_radius())
	_apply_radial_effect()
	animation.animation_finished.connect(queue_free)
	animation.play(&"explode")
	if explosion_audio.stream:
		explosion_audio.play()


func _apply_radial_effect() -> void:
	var shape := damage_shape.shape as CircleShape2D
	if shape == null:
		return
	var damage_radius := shape.radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = damage_mask
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hits := get_world_2d().direct_space_state.intersect_shape(query, 64)
	var affected := {}
	for hit in hits:
		var body := hit.get("collider") as Node2D
		if body == null or affected.has(body.get_instance_id()):
			continue
		affected[body.get_instance_id()] = true
		var distance := global_position.distance_to(body.global_position)
		var strength := clampf(1.0 - distance / damage_radius, 0.0, 1.0)
		if strength <= 0.0:
			continue
		var direction := (body.global_position - global_position).normalized()
		if direction.is_zero_approx():
			direction = Vector2.UP
		var impulse := direction * maximum_knockback * strength
		impulse.y -= maximum_knockback * 0.32 * strength
		var damage := maxi(1, roundi(maximum_damage * strength))
		if body.has_method("receive_explosion"):
			body.receive_explosion(damage, impulse, global_position)
		elif body.has_method("take_damage"):
			body.take_damage(damage)


func get_damage_radius() -> float:
	var shape := damage_shape.shape as CircleShape2D if damage_shape else null
	return shape.radius if shape else 0.0
