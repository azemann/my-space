extends Area2D

static var pending_spawn := ""

@export_file("*.tscn") var destination_scene := ""
@export var destination_spawn := "default"
@export var prompt := "Entrer"

var _actor_inside: CharacterBody2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if _actor_inside == null or destination_scene.is_empty():
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		pending_spawn = destination_spawn
		get_tree().change_scene_to_file(destination_scene)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		_actor_inside = body


func _on_body_exited(body: Node2D) -> void:
	if body == _actor_inside:
		_actor_inside = null
