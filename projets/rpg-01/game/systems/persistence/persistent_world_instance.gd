class_name PersistentWorldInstance
extends Node

## Composant Godot ajouté comme enfant direct d'une instance du monde.
## Il rend la transformation de son parent persistante entre deux chargements
## de carte, sans imposer de script particulier à l'objet concerné.

const PERSISTENT_INSTANCE_GROUP := &"persistent_world_instances"

@export_category("Identité persistante")
## Identifiant stable et unique à l'intérieur de la carte. Cette valeur ne doit
## jamais être dérivée du nom de l'asset, car plusieurs instances peuvent
## partager le même asset.
@export var persistent_id: StringName

@export_category("État d'instance")
## Mémorise la position locale à la carte lors de la capture d'état.
@export var persist_position := true
## Mémorise la rotation globale lors de la capture d'état.
@export var persist_rotation := true
## Ramène un objet physique au repos lors de la restauration d'état. La prise,
## la projection et les vélocités ne deviennent donc pas des états persistants.
@export var normalize_transient_physics := true


func _ready() -> void:
	if str(persistent_id).is_empty():
		push_warning("PersistentWorldInstance sans persistent_id sous %s" % get_parent().get_path())
		return
	add_to_group(PERSISTENT_INSTANCE_GROUP)


func capture_instance_state(map: Node2D) -> Dictionary:
	var target := get_parent() as Node2D
	if target == null:
		return {}
	var state: Dictionary = {}
	if persist_position:
		state["position"] = map.to_local(target.global_position)
	if persist_rotation:
		state["rotation"] = target.global_rotation
	return state


func restore_instance_state(map: Node2D, state: Dictionary) -> void:
	var target := get_parent() as Node2D
	if target == null:
		return
	var world_position := target.global_position
	var world_rotation := target.global_rotation
	if persist_position and state.has("position"):
		var local_position: Vector2 = state["position"]
		world_position = map.to_global(local_position)
	if persist_rotation and state.has("rotation"):
		world_rotation = float(state["rotation"])
	if normalize_transient_physics and target.has_method("restore_persistent_state"):
		target.call("restore_persistent_state", world_position, world_rotation)
		return
	target.global_position = world_position
	target.global_rotation = world_rotation
	if normalize_transient_physics and target is RigidBody2D:
		var body := target as RigidBody2D
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
		body.sleeping = true
