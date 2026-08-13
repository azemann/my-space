class_name SerreTiledProfile
extends RefCounted

const Registry = preload("res://game/serre/tiled/tiled_object_scene_registry.gd")
const LevelDefinition = preload("res://addons/my_space_core/levels/level_definition.gd")
const LEVEL_SCRIPT = preload("res://addons/my_space_core/levels/level_native.gd")
const GROUND_MATERIAL = preload("res://resources/physics/ground-material.tres")

const FROZEN_LEVELS := {
	"niveau-01-serre": true,
}
const CLIMBABLE_TOP_EXTENSION := 32.0


static func maps_directory() -> String:
	return "res://maps"


static func tile_sets_directory() -> String:
	return "res://resources/tilesets"


static func level_resources_directory() -> String:
	return "res://resources/levels"


static func level_scenes_directory() -> String:
	return "res://scenes/levels"


static func tile_set_path(level_id: String) -> String:
	return tile_sets_directory().path_join("%s.tres" % level_id)


static func level_resource_path(level_id: String) -> String:
	return level_resources_directory().path_join("%s-data.tres" % level_id)


static func level_scene_path(level_id: String) -> String:
	return level_scenes_directory().path_join("%s.tscn" % level_id)


static func is_level_frozen(level_id: String) -> bool:
	return FROZEN_LEVELS.has(level_id)


static func fallback_tileset_texture() -> String:
	return "res://assets/tilesets/serre-mecanique-32x32.png"


static func fallback_tileset_columns() -> int:
	return 16


static func fallback_tileset_rows() -> int:
	return 5


static func fallback_tile_size() -> Vector2i:
	return Vector2i(32, 32)


static func level_script() -> Script:
	return LEVEL_SCRIPT


static func create_level_definition():
	return LevelDefinition.new()


static func ground_material() -> PhysicsMaterial:
	return GROUND_MATERIAL


static func has_object_scene(kind: String) -> bool:
	return Registry.has_scene(kind)


static func instantiate_object(kind: String) -> Node2D:
	return Registry.instantiate(kind)


static func object_scene_path(kind: String) -> String:
	return Registry.scene_path(kind)


static func postprocess_registered_object(kind: String, instance: Node2D) -> void:
	if kind != "climbable" or not instance is Area2D:
		return
	# Règle propre au personnage de Serre mécanique : prolonger la zone d'une
	# tuile afin que sa capsule franchisse complètement la plateforme one-way.
	var collision := instance.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var shape := collision.shape as RectangleShape2D if collision else null
	if collision and shape:
		shape.size.y += CLIMBABLE_TOP_EXTENSION
		collision.position.y -= CLIMBABLE_TOP_EXTENSION * 0.5
