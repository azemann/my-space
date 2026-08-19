extends SceneTree

## Vérifie que le catalogue généré correspond exactement aux définitions actives.

const DEFINITIONS_ROOT := "res://game/content/items/definitions"
const CATALOG_PATH := "res://game/content/items/catalog.tres"
const ALLOWED_CATEGORIES := [&"material", &"consumable", &"quest", &"equipment", &"key", &"misc"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog := load(CATALOG_PATH) as ItemCatalog
	assert(catalog != null, "Catalogue d'objets absent")
	assert(catalog.rebuild_index().is_empty(), "Catalogue invalide ou identifiants dupliqués")
	var expected_paths := _resource_paths(DEFINITIONS_ROOT)
	var catalog_paths := PackedStringArray()
	var previous_id := ""
	for definition in catalog.definitions:
		assert(definition != null and definition.is_valid())
		assert(definition.category in ALLOWED_CATEGORIES,
			"Catégorie non contractuelle pour %s : %s" % [definition.item_id, definition.category])
		assert(previous_id < str(definition.item_id) or previous_id.is_empty(),
			"Le catalogue doit être trié par item_id")
		previous_id = str(definition.item_id)
		catalog_paths.append(definition.resource_path)
	catalog_paths.sort()
	assert(catalog_paths == expected_paths,
		"Relancer build_item_catalog.gd après ajout, déplacement ou suppression d'un objet")
	print("Catalogue d'objets vérifié : %d définitions uniques et cataloguées." % catalog.definitions.size())
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
