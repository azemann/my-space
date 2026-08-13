extends SceneTree

const PLAYER_SCENE := "res://scenes/player/player.tscn"
const PLAYER_ANIMATIONS := "res://resources/characters/player-mechanic-animations.tres"
const ANIMATION_NAMES := [&"idle", &"walk", &"jump", &"climb", &"grapple"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var animations := load(PLAYER_ANIMATIONS) as SpriteFrames
	if animations == null:
		push_error("La bibliothèque SpriteFrames du joueur est absente.")
		failures += 1
	else:
		for animation_name in ANIMATION_NAMES:
			if not animations.has_animation(animation_name):
				push_error("Animation absente: %s." % animation_name)
				failures += 1
				continue
			if animations.get_frame_count(animation_name) != 16:
				push_error("L'animation %s ne contient pas 16 frames." % animation_name)
				failures += 1
			for frame in animations.get_frame_count(animation_name):
				var texture := animations.get_frame_texture(animation_name, frame)
				var image := texture.get_image() if texture else Image.new()
				var used := image.get_used_rect()
				if image.get_size() != Vector2i(64, 64) or not image.detect_alpha():
					push_error("Frame invalide: %s[%d]." % [animation_name, frame])
					failures += 1
				elif used.size.x > 60 or used.size.y > 56 or used.end.y != 60:
					push_error("Frame hors contrat spatial: %s[%d], rectangle %s." % [animation_name, frame, used])
					failures += 1

	var player := (load(PLAYER_SCENE) as PackedScene).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	var sprite := player.get_node_or_null("BodySprite") as AnimatedSprite2D
	var collision := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if sprite == null or sprite.sprite_frames == null:
		push_error("Le BodySprite du joueur n'utilise pas les nouvelles animations.")
		failures += 1
	else:
		player.facing = -1.0
		player._update_visual_direction()
		if not sprite.flip_h:
			push_error("Le personnage ne se retourne pas vers la gauche.")
			failures += 1
	if collision == null or not collision.shape is CapsuleShape2D:
		push_error("La capsule du joueur est absente.")
		failures += 1
	else:
		var capsule := collision.shape as CapsuleShape2D
		if capsule.height <= 0.0 or capsule.radius <= 0.0 or capsule.height < capsule.radius * 2.0:
			push_error("La capsule du personnage possède des dimensions invalides.")
			failures += 1
		var idle_texture := sprite.sprite_frames.get_frame_texture(&"idle", 0)
		var image := idle_texture.get_image()
		var local_bottom := image.get_used_rect().end.y - image.get_height() * 0.5
		var visible_bottom := sprite.position.y + local_bottom * sprite.scale.y
		if not is_equal_approx(visible_bottom, capsule.height * 0.5):
			push_error("Les pieds visibles ne sont pas alignés avec le bas de la collision.")
			failures += 1

	print("Animations joueur vérifiées: 5 × 16 frames, alpha, pivot, capsule adaptable, erreurs: %d" % failures)
	player.queue_free()
	quit(1 if failures > 0 else 0)
