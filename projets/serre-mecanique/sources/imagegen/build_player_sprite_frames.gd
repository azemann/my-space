extends SceneTree

const OUTPUT := "res://resources/characters/player-mechanic-animations.tres"
const FRAME_SIZE := Vector2(64, 64)
const ANIMATIONS := {
	&"idle": {"texture": "res://assets/characters/player/animations/idle.png", "fps": 8.0, "loop": true},
	&"walk": {"texture": "res://assets/characters/player/animations/walk.png", "fps": 12.0, "loop": true},
	&"jump": {"texture": "res://assets/characters/player/animations/jump.png", "fps": 12.0, "loop": false},
	&"climb": {"texture": "res://assets/characters/player/animations/climb.png", "fps": 10.0, "loop": true},
	&"grapple": {"texture": "res://assets/characters/player/animations/grapple.png", "fps": 12.0, "loop": false},
}


func _initialize() -> void:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation(&"default")
	for animation: StringName in ANIMATIONS:
		var definition: Dictionary = ANIMATIONS[animation]
		var texture := load(definition.texture) as Texture2D
		if texture == null:
			push_error("Texture d'animation introuvable: %s" % definition.texture)
			quit(1)
			return
		sprite_frames.add_animation(animation)
		sprite_frames.set_animation_speed(animation, definition.fps)
		sprite_frames.set_animation_loop(animation, definition.loop)
		for frame in 16:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				(frame % 4) * FRAME_SIZE.x,
				(frame / 4) * FRAME_SIZE.y,
				FRAME_SIZE.x,
				FRAME_SIZE.y
			)
			sprite_frames.add_frame(animation, atlas)
	var error := ResourceSaver.save(sprite_frames, OUTPUT)
	if error != OK:
		push_error("Impossible d'enregistrer %s: erreur %d" % [OUTPUT, error])
		quit(1)
		return
	print("SpriteFrames généré: %s" % OUTPUT)
	quit()
