extends SceneTree

const GENERIC_ROOTS := [
	"res://addons/my_space_core",
	"res://addons/tiled_level_pipeline",
]
const FORBIDDEN_IN_GENERIC := [
	"game/serre",
	"niveau-01",
	"niveau-02",
	"racines",
	"irrigation",
	"assets/tilesets",
	"assets/weapons",
]


func _initialize() -> void:
	var failures := 0
	var checked := 0
	for root_path in GENERIC_ROOTS:
		for path in _gd_files(root_path):
			checked += 1
			var source := FileAccess.get_file_as_string(path).to_lower()
			for forbidden in FORBIDDEN_IN_GENERIC:
				if forbidden in source:
					push_error("La couche générique %s dépend encore de '%s'." % [path, forbidden])
					failures += 1
	var profile_source := FileAccess.get_file_as_string("res://game/serre/tiled/serre_tiled_profile.gd")
	if "addons/tiled_level_pipeline" in profile_source:
		push_error("Le profil ne doit pas importer le convertisseur qu'il configure.")
		failures += 1
	print("Frontière d'architecture vérifiée: %d scripts génériques, erreurs: %d" % [checked, failures])
	quit(1 if failures > 0 else 0)


func _gd_files(root_path: String) -> Array[String]:
	var result: Array[String] = []
	var directory := DirAccess.open(root_path)
	if directory == null:
		return result
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var path := root_path.path_join(entry)
		if directory.current_is_dir():
			result.append_array(_gd_files(path))
		elif entry.get_extension() == "gd":
			result.append(path)
		entry = directory.get_next()
	directory.list_dir_end()
	return result
