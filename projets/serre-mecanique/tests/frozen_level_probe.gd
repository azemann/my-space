extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const Profile = preload("res://game/serre/tiled/serre_tiled_profile.gd")
const FROZEN_SCENE := "res://scenes/levels/niveau-01-serre.tscn"
const LEVEL_2_TSX := "res://assets/tilesets/niveau-02-serre-mecanique-32x32-v002.tsx"


func _initialize() -> void:
	var before := FileAccess.get_file_as_string(FROZEN_SCENE)
	var info := Converter._parse_external_tileset(LEVEL_2_TSX)
	var result := Converter.convert_all(Profile)
	var after := FileAccess.get_file_as_string(FROZEN_SCENE)
	var failures := 0

	if result != OK:
		push_error("La régénération a échoué avec le code %s." % result)
		failures += 1
	if before != after:
		push_error("La scène figée du niveau 1 a été modifiée.")
		failures += 1
	if int(info.get("columns", 0)) != 16 or int(info.get("rows", 0)) != 5:
		push_error("Le tileset du niveau 2 n'est pas une grille 16 x 5.")
		failures += 1
	if str(info.get("texture_path", "")) != "res://assets/tilesets/niveau-02-serre-mecanique-32x32-v002.png":
		push_error("Le TSX du niveau 2 ne référence pas son image dédiée.")
		failures += 1

	print("Gel niveau 1 et tileset niveau 2 vérifiés, erreurs: %d" % failures)
	quit(1 if failures > 0 else 0)
