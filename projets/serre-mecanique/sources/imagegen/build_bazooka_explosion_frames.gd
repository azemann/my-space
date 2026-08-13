extends SceneTree

const TEXTURE := "res://assets/effects/explosions/bazooka-explosion.png"
const OUTPUT := "res://resources/effects/bazooka-explosion-frames.tres"


func _initialize() -> void:
	var texture := load(TEXTURE) as Texture2D
	if texture == null:
		push_error("Texture d'explosion introuvable: %s" % TEXTURE)
		quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"explode")
	frames.set_animation_loop(&"explode", false)
	frames.set_animation_speed(&"explode", 18.0)
	for frame in 16:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2((frame % 4) * 64, (frame / 4) * 64, 64, 64)
		frames.add_frame(&"explode", atlas)
	var error := ResourceSaver.save(frames, OUTPUT)
	if error != OK:
		push_error("Impossible d'enregistrer %s: erreur %d" % [OUTPUT, error])
		quit(1)
		return
	print("SpriteFrames généré: %s" % OUTPUT)
	quit()
