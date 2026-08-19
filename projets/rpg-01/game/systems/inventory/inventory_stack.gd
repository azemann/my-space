class_name InventoryStack
extends RefCounted

## Valeur runtime d'un emplacement occupé. Une instance_id vide représente une
## pile ordinaire ; une valeur non vide représente un objet individuel unique.

var item: ItemDefinition
var quantity := 0
var instance_id: StringName


func _init(definition: ItemDefinition = null, amount := 0, unique_id: StringName = &"") -> void:
	item = definition
	quantity = amount
	instance_id = unique_id


## Indique si cette pile peut fusionner avec la définition et l'instance données.
func can_merge(definition: ItemDefinition, unique_id: StringName = &"") -> bool:
	return item != null and definition != null \
		and item.item_id == definition.item_id \
		and str(instance_id).is_empty() and str(unique_id).is_empty()


## Crée une copie indépendante de cette valeur runtime.
func duplicate_stack() -> InventoryStack:
	return InventoryStack.new(item, quantity, instance_id)
