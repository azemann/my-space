class_name ItemCatalog
extends Resource

## Registre auteur des définitions d'objets. Il résout les identifiants stables
## des sauvegardes sans faire dépendre le runtime de chemins de ressources.

## Définitions disponibles dans cette version du jeu.
@export var definitions: Array[ItemDefinition] = []

var _by_id: Dictionary = {}


## Reconstruit l'index et renvoie les erreurs de définition rencontrées.
func rebuild_index() -> PackedStringArray:
	_by_id.clear()
	var errors := PackedStringArray()
	for definition in definitions:
		if definition == null or not definition.is_valid():
			errors.append("Définition d'objet absente ou invalide")
			continue
		var key := str(definition.item_id)
		if _by_id.has(key):
			errors.append("item_id dupliqué : %s" % key)
			continue
		_by_id[key] = definition
	return errors


## Renvoie la définition correspondant à un identifiant stable, ou null.
func get_item(item_id: StringName) -> ItemDefinition:
	if _by_id.is_empty() and not definitions.is_empty():
		rebuild_index()
	return _by_id.get(str(item_id)) as ItemDefinition


## Indique si le catalogue contient une définition valide pour cet identifiant.
func has_item(item_id: StringName) -> bool:
	return get_item(item_id) != null
