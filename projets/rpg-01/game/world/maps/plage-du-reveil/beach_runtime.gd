extends Node

## Installe les éléments de gameplay propres à la Plage du Réveil qui ne sont
## pas directement produits par Tiled, puis nettoie ses sons à la fermeture.

const PRACTICE_STONE := preload("res://game/entities/psychokinetic/practice_stone.tscn")


func _ready() -> void:
	var map := get_parent()
	var marker := map.get_node_or_null("World/Gameplay/Entities/PierreEtrangeSpawn") as Marker2D
	var actor_parent := map.get_node_or_null("World/PlacedObjects/YSortedObjects")
	if marker == null or actor_parent == null:
		push_error("Placement Tiled de la pierre psychokinétique absent.")
		return
	var stone := PRACTICE_STONE.instantiate() as PsychokineticBody2D
	stone.name = "PierreEtrange"
	actor_parent.add_child(stone)
	stone.global_position = marker.global_position


func _exit_tree() -> void:
	# Arrête explicitement les boucles avant la libération de la carte. Cela évite
	# qu'un flux d'ambiance reste actif pendant une transition de carte.
	var ambience := get_node_or_null("Ambience")
	if ambience == null:
		return
	for child in ambience.get_children():
		if child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
