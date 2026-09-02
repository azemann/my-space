extends Node2D

const Actions = preload("res://game/serre/contracts/input_actions.gd")

@onready var level: NativeLevel = $Level
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	player.spawn_point = level.get_player_spawn() + Vector2(0, -player.get_standing_half_height())
	player.global_position = player.spawn_point


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(Actions.RESPAWN):
		player.respawn()
