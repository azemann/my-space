@tool
class_name PlayerConfig
extends Resource

@export_group("Déplacement")
@export_range(1.0, 400.0, 1.0, "suffix:px/s") var walk_speed := 92.0
@export_range(1.0, 3.0, 0.05) var run_multiplier := 1.45
@export_range(1.0, 3000.0, 10.0, "suffix:px/s²") var acceleration := 900.0
@export_range(1.0, 3000.0, 10.0, "suffix:px/s²") var deceleration := 1200.0
@export_range(0.0, 0.9, 0.01) var input_deadzone := 0.18

@export_group("Actions Input Map")
@export var move_left_action: StringName = &"move_left"
@export var move_right_action: StringName = &"move_right"
@export var move_up_action: StringName = &"move_up"
@export var move_down_action: StringName = &"move_down"
@export var run_action: StringName = &"run"
@export var interact_action: StringName = &"interact"

@export_group("Animation")
@export var idle_prefix: StringName = &"idle"
@export var walk_prefix: StringName = &"walk"
@export_range(0.0, 20.0, 0.1, "suffix:px/s") var animation_velocity_threshold := 2.0

@export_group("Interaction")
@export_range(4.0, 64.0, 1.0, "suffix:px") var interaction_distance := 20.0

