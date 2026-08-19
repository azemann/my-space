class_name InteractionController
extends Node

## Route les demandes du joueur vers le meilleur composant interactif placé
## devant lui. Le joueur ne connaît ni inventaire, ni coffre, ni dialogue.

## Émis lorsqu'un composant a accepté l'interaction.
signal interaction_succeeded(target: Node)
## Émis lorsqu'aucun composant à portée n'a accepté l'interaction.
signal interaction_missed

@export_category("Détection")
## Rayon autour du point d'interaction orienté du joueur.
@export_range(4.0, 64.0, 1.0, "suffix:px") var interaction_radius := 30.0

@onready var player: PlayerController = get_parent().get_node("PersistentActors/Player") as PlayerController


func _ready() -> void:
	if player == null:
		push_error("InteractionController nécessite le joueur persistant.")
		return
	player.interaction_requested.connect(_on_interaction_requested)


func _on_interaction_requested(origin: Vector2, direction: Vector2) -> void:
	var candidates: Array[Node] = []
	for node in get_tree().get_nodes_in_group(&"player_interactables"):
		if not node.has_method("can_interact") or not node.has_method("interaction_position"):
			continue
		if not bool(node.call("can_interact", player)):
			continue
		var position: Vector2 = node.call("interaction_position")
		var actor_offset := position - player.global_position
		var is_in_front := actor_offset.is_zero_approx() or direction.normalized().dot(actor_offset.normalized()) > 0.1
		if is_in_front and origin.distance_to(position) <= interaction_radius:
			candidates.append(node)
	candidates.sort_custom(func(left: Node, right: Node) -> bool:
		var left_position: Vector2 = left.call("interaction_position")
		var right_position: Vector2 = right.call("interaction_position")
		var left_alignment := direction.normalized().dot((left_position - player.global_position).normalized())
		var right_alignment := direction.normalized().dot((right_position - player.global_position).normalized())
		if not is_equal_approx(left_alignment, right_alignment):
			return left_alignment > right_alignment
		return origin.distance_squared_to(left_position) < origin.distance_squared_to(right_position))
	for candidate in candidates:
		if bool(candidate.call("try_interact", player)):
			interaction_succeeded.emit(candidate)
			return
	interaction_missed.emit()
