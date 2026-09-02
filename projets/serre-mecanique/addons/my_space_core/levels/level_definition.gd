class_name LevelDefinition
extends Resource

@export var level_id := ""
@export var display_name := "Niveau"
@export_file("*.tmx") var source_tmx := ""
@export var map_size_tiles := Vector2i.ZERO
@export var tile_size := Vector2i(32, 32)
@export var player_spawn := Vector2.ZERO
@export var camera_limits := Rect2i()
