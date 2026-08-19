class_name InventoryPickup
extends Node

## Composant reliant explicitement une instance physique du monde à une
## définition d'inventaire. L'objet reste présent mais désactivé après collecte
## afin que la persistance de carte puisse mémoriser son état.

## Émis uniquement après l'ajout atomique de toute la quantité dans le sac.
signal collected(item: ItemDefinition, quantity: int)
## Émis quand le sac refuse la transaction, notamment lorsqu'il est plein.
signal collection_rejected(transaction: InventoryTransaction)

@export_category("Contenu")
## Type d'objet ajouté au sac.
@export var item: ItemDefinition
## Quantité remise par cette instance du monde.
@export_range(1, 999, 1) var quantity := 1
## Identité facultative d'un objet unique ; vide pour une pile ordinaire.
@export var instance_id: StringName
## Texte destiné au futur indicateur contextuel d'interaction.
@export var prompt := "Ramasser"

var is_collected := false
var _original_visible := true
var _original_process_mode := Node.PROCESS_MODE_INHERIT
var _original_freeze := false
var _collision_states: Dictionary = {}


func _ready() -> void:
	add_to_group(&"player_interactables")
	var target := get_parent()
	if target is CanvasItem:
		_original_visible = (target as CanvasItem).visible
	_original_process_mode = target.process_mode
	if target is RigidBody2D:
		_original_freeze = (target as RigidBody2D).freeze
	_capture_collision_states(target)
	if item == null or not item.is_valid():
		push_error("InventoryPickup sans ItemDefinition valide sous %s" % target.get_path())


## Renvoie la position mondiale utilisée par le routeur d'interaction.
func interaction_position() -> Vector2:
	var target := get_parent() as Node2D
	return target.global_position if target != null else Vector2.ZERO


## Vérifie que l'instance est disponible et que l'acteur possède un sac.
func can_interact(actor: Node) -> bool:
	var player := actor as PlayerController
	return not is_collected and item != null and player != null and player.inventory != null


## Tente le transfert atomique vers le sac de l'acteur.
func try_interact(actor: Node) -> bool:
	if not can_interact(actor):
		return false
	var player := actor as PlayerController
	var transaction := player.inventory.add(item, quantity, instance_id)
	if not transaction.succeeded():
		collection_rejected.emit(transaction)
		return false
	_set_collected(true)
	collected.emit(item, quantity)
	return true


## Produit le fragment d'état consommé par PersistentWorldInstance.
func capture_persistent_state_fragment() -> Dictionary:
	return {"collected": is_collected}


## Restaure l'état collecté sans rejouer la transaction ni ses effets.
func restore_persistent_state_fragment(state: Dictionary) -> void:
	_set_collected(bool(state.get("collected", false)))


func _set_collected(collected_state: bool) -> void:
	is_collected = collected_state
	var target := get_parent()
	if target is CanvasItem:
		(target as CanvasItem).visible = _original_visible and not is_collected
	if target is RigidBody2D:
		(target as RigidBody2D).freeze = true if is_collected else _original_freeze
	target.process_mode = Node.PROCESS_MODE_DISABLED if is_collected else _original_process_mode
	for collision_object in _collision_states:
		if not is_instance_valid(collision_object):
			continue
		var values: Vector2i = _collision_states[collision_object]
		(collision_object as CollisionObject2D).collision_layer = 0 if is_collected else values.x
		(collision_object as CollisionObject2D).collision_mask = 0 if is_collected else values.y
	if target.is_in_group(&"psychokinetic_targets") and is_collected:
		target.remove_from_group(&"psychokinetic_targets")
	elif not is_collected and target is PsychokineticBody2D and not target.is_in_group(&"psychokinetic_targets"):
		target.add_to_group(&"psychokinetic_targets")


func _capture_collision_states(root_node: Node) -> void:
	var pending: Array[Node] = [root_node]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		if node is CollisionObject2D:
			var collision_object := node as CollisionObject2D
			_collision_states[collision_object] = Vector2i(collision_object.collision_layer, collision_object.collision_mask)
		pending.append_array(node.get_children())
