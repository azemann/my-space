class_name FootprintDecal2D
extends Node2D

## Une empreinte visuelle autonome. L'apparence et la disparition sont
## entièrement définies par la scène et son AnimationPlayer.

@export var fade_animation: StringName = &"fade_out"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play(fade_animation)


func set_left_foot(is_left: bool) -> void:
	$Visual.flip_h = not is_left


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == fade_animation:
		queue_free()
