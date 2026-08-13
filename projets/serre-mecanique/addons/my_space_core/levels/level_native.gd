@tool
class_name NativeLevel
extends Node2D

@export var definition: LevelDefinition


func get_player_spawn() -> Vector2:
	var legacy_marker := get_node_or_null("Gameplay/PlayerSpawn") as Marker2D
	if legacy_marker:
		return legacy_marker.global_position
	for node in find_children("*", "Marker2D", true, false):
		if node.name == "PlayerSpawn" or str(node.get_meta("kind", "")) == "player_spawn":
			return (node as Marker2D).global_position
	return definition.player_spawn if definition else Vector2.ZERO
