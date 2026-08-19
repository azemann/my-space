extends SceneTree

## Reconstruit le catalogue runtime depuis toutes les ItemDefinition actives.

const DEFINITIONS_ROOT := "res://game/content/items/definitions"
const CATALOG_PATH := "res://game/content/items/catalog.tres"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var definitions: Array[ItemDefinition] = []
	for path in _resource_paths(DEFINITIONS_ROOT):
		var definition := load(path) as ItemDefinition
		if definition == null:
			push_error("Ressource non ItemDefinition dans le dossier d'objets : %s" % path)
			quit(1)
			return
		definitions.append(definition)
	definitions.sort_custom(func(left: ItemDefinition, right: ItemDefinition) -> bool:
		return str(left.item_id) < str(right.item_id))

	var catalog := ItemCatalog.new()
	catalog.resource_name = "Catalogue principal des objets"
	catalog.definitions = definitions
	var errors := catalog.rebuild_index()
	if not errors.is_empty():
		for error in errors:
			push_error(error)
		quit(1)
		return
	var save_error := ResourceSaver.save(catalog, CATALOG_PATH)
	if save_error != OK:
		push_error("Échec d'écriture du catalogue : %s" % error_string(save_error))
		quit(1)
		return
	print("Catalogue d'objets généré : %d définitions triées." % definitions.size())
	quit()


func _resource_paths(root_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	var pending := PackedStringArray([root_path])
	while not pending.is_empty():
		var directory := pending[pending.size() - 1]
		pending.resize(pending.size() - 1)
		for child_directory in DirAccess.get_directories_at(directory):
			pending.append(directory.path_join(child_directory))
		for file_name in DirAccess.get_files_at(directory):
			if file_name.ends_with(".tres"):
				result.append(directory.path_join(file_name))
	result.sort()
	return result
