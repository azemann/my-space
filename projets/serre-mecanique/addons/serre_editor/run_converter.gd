extends SceneTree

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const Profile = preload("res://game/serre/tiled/serre_tiled_profile.gd")


func _initialize() -> void:
	var result := Converter.convert_all(Profile)
	quit(result)
