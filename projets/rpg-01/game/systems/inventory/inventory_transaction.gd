class_name InventoryTransaction
extends RefCounted

## Résultat explicite d'une mutation d'inventaire. Les appelants peuvent ainsi
## distinguer sac plein, requête invalide et quantité manquante sans deviner.

## Codes stables produits par toutes les opérations d'inventaire.
enum Code {
	SUCCESS,
	INVALID_ITEM,
	INVALID_QUANTITY,
	INVALID_SLOT,
	INSUFFICIENT_SPACE,
	INSUFFICIENT_QUANTITY,
	INCOMPATIBLE_SLOTS,
	DUPLICATE_INSTANCE,
}

var code: Code = Code.SUCCESS
var requested := 0
var moved := 0
var remainder := 0
var source_slot := -1
var target_slot := -1


func _init(result_code: Code = Code.SUCCESS, requested_amount := 0, moved_amount := 0) -> void:
	code = result_code
	requested = requested_amount
	moved = moved_amount
	remainder = maxi(requested - moved, 0)


## Indique si toute la mutation demandée a été appliquée.
func succeeded() -> bool:
	return code == Code.SUCCESS and remainder == 0
