extends SceneTree

const SHEET_PATH := "res://game/actors/player/generated/player_sheet.png"
const MANIFEST_PATH := "res://game/actors/player/generated/player_sheet.json"
const FRAMES_PATH := "res://game/actors/player/generated/player_frames.tres"
const VISUAL_SCENE_PATH := "res://game/actors/player/generated/player_visual.tscn"
const CANVAS := Vector2i(64, 64)
const ROOT := Vector2(32, 56)


func _initialize() -> void:
	var texture := load(SHEET_PATH) as Texture2D
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if texture == null or not manifest is Dictionary:
		push_error("Planche ou manifeste du joueur introuvable.")
		quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var animations := {}
	var animation_names: Array[String] = []
	for record in manifest.frames:
		var animation_name := "%s_%s" % [record.animation, record.direction]
		if not animations.has(animation_name):
			animations[animation_name] = []
			animation_names.append(animation_name)
		animations[animation_name].append(record)
	for animation_name in animation_names:
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.set_animation_speed(animation_name, 10.0)
		for record in animations[animation_name]:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2i(record.cell[0] * CANVAS.x, record.cell[1] * CANVAS.y), CANVAS)
			frames.add_frame(animation_name, atlas, float(record.duration_ms) / 100.0)
	frames.resource_name = "Joueur — idle et marche 4 directions"
	frames.set_meta("source_manifest", MANIFEST_PATH)
	frames.set_meta("root_px", ROOT)
	if ResourceSaver.save(frames, FRAMES_PATH, ResourceSaver.FLAG_CHANGE_PATH) != OK:
		push_error("Impossible d'enregistrer les SpriteFrames du joueur.")
		quit(1)
		return
	frames = null
	var saved_frames := ResourceLoader.load(FRAMES_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as SpriteFrames
	if saved_frames == null:
		push_error("Impossible de relire les SpriteFrames enregistrées.")
		quit(1)
		return

	var visual := Node2D.new()
	visual.name = "PlayerVisual"
	visual.editor_description = "Visuel généré depuis les frames sources. Ne pas ajouter de logique gameplay dans cette scène."
	visual.set_meta("asset_id", manifest.asset_id)
	visual.set_meta("sprite_contract", "res://docs/contracts/PLAYER_SPRITE_CONTRACT.md")
	visual.set_meta("visual_root_px", ROOT)

	var sprite := AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.sprite_frames = saved_frames
	sprite.animation = "idle_south"
	sprite.offset = Vector2(0, CANVAS.y * 0.5 - ROOT.y)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.add_child(sprite)
	sprite.owner = visual

	var packed := PackedScene.new()
	if packed.pack(visual) != OK or ResourceSaver.save(packed, VISUAL_SCENE_PATH) != OK:
		push_error("Impossible d'enregistrer la scène visuelle du joueur.")
		visual.free()
		quit(1)
		return
	visual.free()
	print("Visuel joueur construit : 8 animations et root [32,56].")
	quit()
