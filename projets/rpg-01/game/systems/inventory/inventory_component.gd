class_name InventoryComponent
extends Node

## Conteneur persistant à emplacements fixes. Toutes ses mutations sont
## atomiques et passent par cette API ; les vues ne modifient jamais les piles.

## Émis une fois après une transaction qui a réellement modifié le contenu.
signal changed
## Émis pour chaque emplacement modifié par une transaction réussie.
signal slot_changed(slot_index: int)
## Émis lorsqu'une transaction est refusée sans modifier le contenu.
signal transaction_rejected(transaction: InventoryTransaction)

const SCHEMA_VERSION := 1

@export_category("Conteneur")
## Identité logique stable du conteneur, par exemple backpack ou quest_pouch.
@export var container_id: StringName = &"backpack"
## Nombre maximal d'emplacements disponibles.
@export_range(1, 200, 1) var capacity := 20
## Catalogue utilisé pour résoudre les identifiants lors d'une restauration.
@export var catalog: ItemCatalog

var slots: Array[InventoryStack] = []


func _ready() -> void:
	if slots.size() != capacity:
		initialize_empty()
	if catalog != null:
		for error in catalog.rebuild_index():
			push_error("Catalogue d'inventaire : %s" % error)


## Réinitialise le conteneur avec le nombre d'emplacements configuré.
func initialize_empty() -> void:
	slots.clear()
	slots.resize(capacity)
	changed.emit()


## Renvoie une copie de la pile d'un emplacement afin de protéger l'autorité du modèle.
func get_slot(slot_index: int) -> InventoryStack:
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return null
	return slots[slot_index].duplicate_stack()


## Compte la quantité totale d'un type d'objet dans ce conteneur.
func amount_of(item_id: StringName) -> int:
	var total := 0
	for stack in slots:
		if stack != null and stack.item != null and stack.item.item_id == item_id:
			total += stack.quantity
	return total


## Indique si un objet unique précis est déjà présent dans ce conteneur.
func has_instance(instance_id: StringName) -> bool:
	if str(instance_id).is_empty():
		return false
	for stack in slots:
		if stack != null and stack.instance_id == instance_id:
			return true
	return false


## Calcule la quantité encore ajoutable sans modifier le contenu.
func free_capacity_for(definition: ItemDefinition, instance_id: StringName = &"") -> int:
	if definition == null or not definition.is_valid():
		return 0
	if not str(instance_id).is_empty():
		return 1 if slots.has(null) else 0
	var available := 0
	for stack in slots:
		if stack == null:
			available += definition.max_stack
		elif stack.can_merge(definition):
			available += maxi(definition.max_stack - stack.quantity, 0)
	return available


## Ajoute toute la quantité demandée ou ne change rien si l'espace manque.
func add(definition: ItemDefinition, quantity: int, instance_id: StringName = &"") -> InventoryTransaction:
	if definition == null or not definition.is_valid():
		return _reject(InventoryTransaction.Code.INVALID_ITEM, quantity)
	if quantity <= 0 or (not str(instance_id).is_empty() and quantity != 1):
		return _reject(InventoryTransaction.Code.INVALID_QUANTITY, quantity)
	if not str(instance_id).is_empty() and has_instance(instance_id):
		return _reject(InventoryTransaction.Code.DUPLICATE_INSTANCE, quantity)
	if free_capacity_for(definition, instance_id) < quantity:
		return _reject(InventoryTransaction.Code.INSUFFICIENT_SPACE, quantity)
	var remaining := quantity
	var touched: Array[int] = []
	if str(instance_id).is_empty():
		for index in slots.size():
			var stack := slots[index]
			if stack == null or not stack.can_merge(definition):
				continue
			var moved := mini(remaining, definition.max_stack - stack.quantity)
			if moved <= 0:
				continue
			stack.quantity += moved
			remaining -= moved
			touched.append(index)
			if remaining == 0:
				break
	for index in slots.size():
		if remaining == 0:
			break
		if slots[index] != null:
			continue
		var moved := 1 if not str(instance_id).is_empty() else mini(remaining, definition.max_stack)
		slots[index] = InventoryStack.new(definition, moved, instance_id)
		remaining -= moved
		touched.append(index)
	_emit_mutation(touched)
	return InventoryTransaction.new(InventoryTransaction.Code.SUCCESS, quantity, quantity)


## Retire toute la quantité demandée ou ne change rien si elle n'est pas possédée.
func remove(item_id: StringName, quantity: int) -> InventoryTransaction:
	if str(item_id).is_empty():
		return _reject(InventoryTransaction.Code.INVALID_ITEM, quantity)
	if quantity <= 0:
		return _reject(InventoryTransaction.Code.INVALID_QUANTITY, quantity)
	if amount_of(item_id) < quantity:
		return _reject(InventoryTransaction.Code.INSUFFICIENT_QUANTITY, quantity)
	var remaining := quantity
	var touched: Array[int] = []
	for index in range(slots.size() - 1, -1, -1):
		var stack := slots[index]
		if stack == null or stack.item.item_id != item_id:
			continue
		var moved := mini(remaining, stack.quantity)
		stack.quantity -= moved
		remaining -= moved
		if stack.quantity == 0:
			slots[index] = null
		touched.append(index)
		if remaining == 0:
			break
	_emit_mutation(touched)
	return InventoryTransaction.new(InventoryTransaction.Code.SUCCESS, quantity, quantity)


## Déplace, fusionne, scinde ou échange atomiquement deux emplacements.
func move(source_index: int, target_index: int, quantity := -1) -> InventoryTransaction:
	if source_index < 0 or source_index >= slots.size() or target_index < 0 or target_index >= slots.size():
		return _reject(InventoryTransaction.Code.INVALID_SLOT, quantity)
	var source := slots[source_index]
	if source == null:
		return _reject(InventoryTransaction.Code.INSUFFICIENT_QUANTITY, quantity)
	var requested := source.quantity if quantity < 0 else quantity
	if requested <= 0 or requested > source.quantity:
		return _reject(InventoryTransaction.Code.INVALID_QUANTITY, requested)
	if source_index == target_index:
		return InventoryTransaction.new(InventoryTransaction.Code.SUCCESS, requested, requested)
	var target := slots[target_index]
	if target == null:
		slots[target_index] = InventoryStack.new(source.item, requested, source.instance_id)
		source.quantity -= requested
		if source.quantity == 0:
			slots[source_index] = null
		_emit_mutation([source_index, target_index])
		return InventoryTransaction.new(InventoryTransaction.Code.SUCCESS, requested, requested)
	if target.can_merge(source.item, source.instance_id):
		if target.quantity + requested > target.item.max_stack:
			return _reject(InventoryTransaction.Code.INSUFFICIENT_SPACE, requested)
		target.quantity += requested
		source.quantity -= requested
		if source.quantity == 0:
			slots[source_index] = null
		_emit_mutation([source_index, target_index])
		return InventoryTransaction.new(InventoryTransaction.Code.SUCCESS, requested, requested)
	if requested != source.quantity:
		return _reject(InventoryTransaction.Code.INCOMPATIBLE_SLOTS, requested)
	slots[source_index] = target
	slots[target_index] = source
	_emit_mutation([source_index, target_index])
	return InventoryTransaction.new(InventoryTransaction.Code.SUCCESS, requested, requested)


## Produit un dictionnaire composé uniquement de valeurs sérialisables.
func capture_state() -> Dictionary:
	var serialized_slots: Array[Dictionary] = []
	for index in slots.size():
		var stack := slots[index]
		if stack == null:
			continue
		serialized_slots.append({
			"slot": index,
			"item_id": str(stack.item.item_id),
			"quantity": stack.quantity,
			"instance_id": str(stack.instance_id),
		})
	return {
		"schema_version": SCHEMA_VERSION,
		"container_id": str(container_id),
		"capacity": capacity,
		"slots": serialized_slots,
	}


## Restaure un état validé sans altérer le contenu si une entrée est invalide.
func restore_state(state: Dictionary) -> bool:
	if catalog == null or int(state.get("schema_version", -1)) != SCHEMA_VERSION:
		return false
	if str(state.get("container_id", "")) != str(container_id):
		return false
	if int(state.get("capacity", -1)) != capacity:
		return false
	var restored: Array[InventoryStack] = []
	restored.resize(capacity)
	var serialized_value: Variant = state.get("slots", [])
	if not serialized_value is Array:
		return false
	var serialized_slots: Array = serialized_value
	var unique_ids: Dictionary = {}
	for value in serialized_slots:
		if not value is Dictionary:
			return false
		var entry := value as Dictionary
		var index := int(entry.get("slot", -1))
		var definition := catalog.get_item(StringName(entry.get("item_id", "")))
		var quantity := int(entry.get("quantity", 0))
		var instance_id := StringName(entry.get("instance_id", ""))
		if index < 0 or index >= capacity or restored[index] != null:
			return false
		if definition == null or quantity <= 0 or quantity > definition.max_stack:
			return false
		if not str(instance_id).is_empty() and quantity != 1:
			return false
		if not str(instance_id).is_empty() and unique_ids.has(str(instance_id)):
			return false
		if not str(instance_id).is_empty():
			unique_ids[str(instance_id)] = true
		restored[index] = InventoryStack.new(definition, quantity, instance_id)
	slots = restored
	var touched: Array[int] = []
	for index in slots.size():
		touched.append(index)
	_emit_mutation(touched)
	return true


func _reject(code: InventoryTransaction.Code, requested: int) -> InventoryTransaction:
	var transaction := InventoryTransaction.new(code, requested, 0)
	transaction_rejected.emit(transaction)
	return transaction


func _emit_mutation(touched: Array[int]) -> void:
	for index in touched:
		slot_changed.emit(index)
	changed.emit()
