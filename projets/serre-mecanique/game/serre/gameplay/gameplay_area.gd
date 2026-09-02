@tool
class_name GameplayArea
extends Area2D

@export var config: InteractionConfig


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	var kind := str(get_meta("kind", config.kind if config else ""))
	match kind:
		"hazard":
			if body.has_method("take_damage"):
				body.take_damage(int(get_meta("damage", config.damage if config else 1)))
			if bool(get_meta("respawn", config.respawn if config else true)) and body.has_method("respawn"):
				body.respawn()
		"death_zone":
			if body.has_method("respawn"):
				body.respawn()
		"bounce":
			if body.has_method("bounce"):
				body.bounce(float(get_meta("impulse_y", config.impulse_y if config else -620.0)))
		"checkpoint":
			if "spawn_point" in body:
				var offset := Vector2(
					float(get_meta("spawn_offset_x", 0.0)),
					float(get_meta("spawn_offset_y", -24.0))
				)
				body.spawn_point = global_position + offset
		"exit":
			print("Niveau terminé — prochaine scène: %s" % str(get_meta("next_level", config.next_level if config else "")))
		"collectible":
			queue_free()
		"trigger", "interactable":
			print("Événement Tiled: %s" % str(get_meta("event", get_meta("action", ""))))
		"transition":
			print("Transition Tiled vers: %s" % str(get_meta("target", "")))
		"wind":
			body.velocity += Vector2(
				float(get_meta("force_x", 0.0)),
				float(get_meta("force_y", 0.0))
			)
