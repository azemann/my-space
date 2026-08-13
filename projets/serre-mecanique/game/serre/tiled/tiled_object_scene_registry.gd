class_name TiledObjectSceneRegistry
extends RefCounted

const SCENES := {
	"climbable": preload("res://scenes/objects/movement/climbable_area.tscn"),
	"bounce": preload("res://scenes/objects/movement/bounce_pad.tscn"),
	"hazard": preload("res://scenes/objects/hazards/hazard_area.tscn"),
	"checkpoint": preload("res://scenes/objects/interactions/checkpoint_area.tscn"),
	"collectible": preload("res://scenes/objects/interactions/collectible_area.tscn"),
	"exit": preload("res://scenes/objects/interactions/exit_door.tscn"),
	"interactable": preload("res://scenes/objects/interactions/switch_area.tscn"),
	"trigger": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
	"death_zone": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
	"transition": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
	"water": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
	"wind": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
	"slow_zone": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
	"conveyor": preload("res://scenes/objects/zones/gameplay_zone.tscn"),
}


static func has_scene(kind: String) -> bool:
	return SCENES.has(kind)


static func instantiate(kind: String) -> Node2D:
	var packed := SCENES.get(kind) as PackedScene
	return packed.instantiate() as Node2D if packed else null


static func scene_path(kind: String) -> String:
	var packed := SCENES.get(kind) as PackedScene
	return packed.resource_path if packed else ""
