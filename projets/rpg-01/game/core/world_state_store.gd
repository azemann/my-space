class_name WorldStateStore
extends Node

signal map_state_captured(map_id: StringName, instance_count: int)
signal map_state_restored(map_id: StringName, instance_count: int)

const SCHEMA_VERSION := 1

@export_category("Persistance de session")
## Active la capture et la restauration des états d'instance lors des
## changements de carte. Désactiver cette option rétablit les placements auteur.
@export var enabled := true

var _map_states: Dictionary = {}


func capture_map_state(map: Node2D) -> int:
	if not enabled or map == null:
		return 0
	var map_id := _map_id(map)
	var instance_states: Dictionary = {}
	for component in _persistent_instances(map):
		var persistent_id := str(component.persistent_id)
		if persistent_id.is_empty():
			push_warning("Instance persistante sans persistent_id dans la carte '%s' : %s" % [map_id, component.get_parent().name])
			continue
		if instance_states.has(persistent_id):
			push_error("persistent_id dupliqué dans la carte '%s' : %s" % [map_id, persistent_id])
			continue
		instance_states[persistent_id] = component.capture_instance_state(map)
	_map_states[str(map_id)] = {
		"schema_version": SCHEMA_VERSION,
		"instances": instance_states,
	}
	map_state_captured.emit(map_id, instance_states.size())
	return instance_states.size()


func restore_map_state(map: Node2D) -> int:
	if not enabled or map == null:
		return 0
	var map_id := _map_id(map)
	var map_state: Dictionary = _map_states.get(str(map_id), {})
	var instance_states: Dictionary = map_state.get("instances", {})
	var restored_count := 0
	for component in _persistent_instances(map):
		var persistent_id := str(component.persistent_id)
		if not instance_states.has(persistent_id):
			continue
		var instance_state: Dictionary = instance_states[persistent_id]
		component.restore_instance_state(map, instance_state)
		restored_count += 1
	map_state_restored.emit(map_id, restored_count)
	return restored_count


func has_map_state(map_id: StringName) -> bool:
	return _map_states.has(str(map_id))


func clear_session_state() -> void:
	_map_states.clear()


func _persistent_instances(map: Node2D) -> Array[PersistentWorldInstance]:
	var instances: Array[PersistentWorldInstance] = []
	var pending: Array[Node] = [map]
	while not pending.is_empty():
		var parent: Node = pending.pop_back()
		for child in parent.get_children():
			pending.append(child)
			var component := child as PersistentWorldInstance
			if component != null and not component.is_queued_for_deletion():
				instances.append(component)
	return instances


func _map_id(map: Node) -> StringName:
	return StringName(map.get_meta("level_id", map.name))
