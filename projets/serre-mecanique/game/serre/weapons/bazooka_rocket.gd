class_name BazookaRocket
extends Node2D

@export_group("Résultat de l'impact")
## Scène créée au premier impact ou lorsque la durée de vie expire. Elle contient le visuel et les dégâts de zone.
@export var explosion_scene: PackedScene

@export_group("Trajectoire")
## Vitesse initiale en pixels par seconde. Augmenter produit un tir plus tendu et plus difficile à esquiver.
@export_range(1.0, 3000.0, 1.0, "or_greater") var speed := 560.0
## Accélération verticale en pixels par seconde carrée. Augmenter courbe davantage la trajectoire vers le bas.
@export_range(0.0, 5000.0, 1.0, "or_greater") var gravity := 150.0
## Durée maximale de vol en secondes. À la fin, la roquette explose même sans collision.
@export_range(0.1, 60.0, 0.1, "or_greater") var maximum_lifetime := 6.0
## Couches physiques capables de déclencher l'impact. La couche du tireur est ignorée automatiquement.
@export_flags_2d_physics var collision_mask := 1

var velocity := Vector2.ZERO
var shooter: CollisionObject2D
var lifetime_left := 0.0
var launched := false
var detonated := false


func launch(direction: Vector2, source: CollisionObject2D, inherited_velocity := Vector2.ZERO, power := 1.0) -> void:
	shooter = source
	velocity = direction.normalized() * speed * clampf(power, 0.0, 1.0) + inherited_velocity * 0.25
	lifetime_left = maximum_lifetime
	launched = true
	rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	if not launched or detonated:
		return
	lifetime_left -= delta
	if lifetime_left <= 0.0:
		detonate(global_position)
		return
	velocity.y += gravity * delta
	var destination := global_position + velocity * delta
	var exclusions: Array[RID] = []
	if is_instance_valid(shooter):
		exclusions.append(shooter.get_rid())
	var query := PhysicsRayQueryParameters2D.create(global_position, destination, collision_mask, exclusions)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		detonate(hit.position)
		return
	global_position = destination
	rotation = velocity.angle()


func detonate(position: Vector2) -> void:
	if detonated:
		return
	detonated = true
	if explosion_scene:
		var explosion := explosion_scene.instantiate() as Node2D
		var parent := get_tree().current_scene if get_tree().current_scene else get_parent()
		parent.add_child(explosion)
		explosion.global_position = position
	queue_free()
