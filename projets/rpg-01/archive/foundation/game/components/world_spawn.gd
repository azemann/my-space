extends Node2D

const Portal = preload("res://game/world/components/scene_portal.gd")


func _ready() -> void:
	if Portal.pending_spawn.is_empty():
		return
	var actors := get_tree().get_nodes_in_group("player")
	var marker := find_child(Portal.pending_spawn, true, false) as Marker2D
	if not actors.is_empty() and marker != null:
		(actors[0] as Node2D).global_position = marker.global_position
	Portal.pending_spawn = ""
