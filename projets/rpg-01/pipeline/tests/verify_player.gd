extends SceneTree

const PLAYER_SCENE := "res://game/actors/player/player.tscn"


func _initialize() -> void:
	var packed := load(PLAYER_SCENE) as PackedScene
	assert(packed != null, "Scène joueur introuvable")
	var player := packed.instantiate() as CharacterBody2D
	assert(player != null)
	assert(player.get_meta("asset_id") == "player.hero")
	assert(player.get_meta("visual_root_px") == Vector2(32, 56))
	var sprite := player.get_node("Visual/AnimatedSprite2D") as AnimatedSprite2D
	assert(sprite != null and sprite.offset == Vector2(0, -24))
	assert(sprite.sprite_frames.get_animation_names().size() == 8)
	for direction in ["south", "west", "east", "north"]:
		assert(sprite.sprite_frames.get_frame_count("idle_%s" % direction) == 2)
		assert(sprite.sprite_frames.get_frame_count("walk_%s" % direction) == 4)
	assert(player.get_node_or_null("FeetCollision") is CollisionShape2D)
	assert(player.get_node_or_null("InteractionOrigin") is Marker2D)
	assert(player.get_node_or_null("CameraAnchor") is Marker2D)
	assert(player.get("config") is PlayerConfig)
	player.free()
	print("Joueur vérifié : contrôleur configurable, 24 frames, 8 animations, root fixe et collision indépendante.")
	quit()
