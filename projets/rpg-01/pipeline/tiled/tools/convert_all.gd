extends SceneTree

const Converter = preload("res://pipeline/tiled/tools/tiled_converter.gd")
const Profile = preload("res://pipeline/tiled/tools/rpg_tiled_profile.gd")


func _initialize() -> void:
	var error := Converter.convert_all(Profile)
	if error != OK:
		push_error("Import Tiled interrompu : %s" % error_string(error))
		quit(1)
		return
	print("Import Tiled terminé : toutes les cartes sont validées et converties.")
	quit()
