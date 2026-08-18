extends SceneTree

const BEACH_SCENE := "res://game/world/maps/plage-du-reveil/plage-du-reveil.tscn"
const MAIN_SCENE := "res://game/core/main.tscn"
const OBJECT_SCENES = preload("res://game/world/objects/world_object_scene_registry.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var level := (load(BEACH_SCENE) as PackedScene).instantiate()
	assert(level.get_meta("source_tmx") == "res://maps/source/plage-du-reveil.tmx")
	assert(level.get_meta("default_spawn_id") == "beach-awakening")
	assert(level.get_meta("camera_bounds") == Rect2(0, 0, 1280, 960))
	var practice_stone_marker := level.get_node_or_null("World/Gameplay/Entities/PierreEtrangeSpawn") as Marker2D
	assert(practice_stone_marker != null)
	assert(practice_stone_marker.get_meta("scene_path") == "res://game/entities/psychokinetic/practice_stone.tscn")
	assert(level.get_node_or_null("World/PlacedObjects/YSortedObjects/MatBrise") is PsychokineticBody2D)
	assert(level.get_node_or_null("World/Gameplay/CollisionOverrides/SeaBoundary") is StaticBody2D)
	assert(level.get_node_or_null("World/Gameplay/CollisionOverrides/DunesWest") is StaticBody2D)
	var dunes_west := level.get_node("World/Gameplay/CollisionOverrides/DunesWest") as StaticBody2D
	assert(dunes_west.get_meta("precision") == "authored_polygon")
	assert(dunes_west.get_node("CollisionPolygon2D").polygon.size() == 6)
	var dynamic_count := 0
	var persistent_ids: Dictionary = {}
	for group_path in [
		"World/PlacedObjects/GroundObjects",
		"World/PlacedObjects/YSortedObjects",
		"World/PlacedObjects/WaterObjects",
		"World/PlacedObjects/ForegroundObjects",
	]:
		var object_group := level.get_node(group_path)
		for object in object_group.get_children():
			assert(object is PsychokineticBody2D, "%s doit être une entité psychokinétique" % object.name)
			assert(object.scene_file_path == OBJECT_SCENES.PSYCHOKINETIC_PROP_PATH,
				"%s doit rester lié à la scène Godot générique" % object.name)
			assert(object.get_meta("object_scene", "") == OBJECT_SCENES.PSYCHOKINETIC_PROP_PATH)
			var persistence := object.get_node_or_null("Persistence") as PersistentWorldInstance
			assert(persistence != null, "%s doit exposer sa persistance dans l'arbre Godot" % object.name)
			assert(not str(persistence.persistent_id).is_empty(), "%s doit avoir un identifiant persistant" % object.name)
			assert(not persistent_ids.has(persistence.persistent_id), "Identifiant persistant dupliqué : %s" % persistence.persistent_id)
			persistent_ids[persistence.persistent_id] = true
			assert(object.profile.response == PsychokinesisProfile.Response.MOVABLE)
			assert(object.profile.required_power == 0, "%s doit être manipulable dès le premier pouvoir" % object.name)
			assert(object.get_node_or_null("Visual") is TileMapLayer)
			assert(not (object.get_node("Visual") as TileMapLayer).collision_enabled)
			assert(object.get_node_or_null("PhysicsFootprint") is CollisionShape2D)
			assert(object.get_node_or_null("SelectionArea") is Area2D, "%s doit exposer une zone de survol Godot" % object.name)
			assert(object.get_node_or_null("SelectionArea/HoverShape") is CollisionShape2D)
			assert(object.get_node_or_null("Shadow") is Polygon2D)
			dynamic_count += 1
	assert(dynamic_count == 47, "Les 47 props placés sur la plage doivent être psychokinétiques")
	assert(level.get_node_or_null("World/Gameplay/SpawnPoints/AzemanAwakening") is Marker2D)
	assert(level.get_node_or_null("World/Gameplay/Interactions/TelekinesisDiscovery") is Area2D)
	assert(level.get_node_or_null("World/Gameplay/CameraZones/AwakeningCameraZone") is Area2D)
	level.free()

	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame
	var player := game.player
	var practice_stone := game.current_map.get_node_or_null("World/PlacedObjects/YSortedObjects/PierreEtrange") as PsychokineticBody2D
	assert(practice_stone != null)
	assert(practice_stone.profile.response == PsychokinesisProfile.Response.MOVABLE)
	assert(practice_stone.profile.mass_class == PsychokinesisProfile.MassClass.LIGHT)
	var mast := game.current_map.get_node("World/PlacedObjects/YSortedObjects/MatBrise") as PsychokineticBody2D
	assert(mast.blocks_actors_when_grounded and mast.collision_layer == 5, "Un gros prop doit bloquer le joueur lorsqu'il repose au sol")
	mast.begin_hold(mast.global_position)
	assert(mast.collision_layer == 4, "Un prop contrôlé ne doit plus pousser ni bloquer le joueur")
	mast.drop()
	mast.height = 0.0
	mast._physics_process(1.0 / 60.0)
	assert(mast.collision_layer == 5, "Le prop doit redevenir un obstacle après son retour au sol")
	assert(_motion_is_blocked(player, Vector2(656, 600), Vector2(0, 96)), "La mer doit bloquer le joueur")
	assert(_motion_is_blocked(player, Vector2(320, 200), Vector2(0, -96)), "Les dunes doivent fermer le nord hors du passage")
	assert(not _motion_is_blocked(player, Vector2(656, 200), Vector2(0, -96)), "Le passage vers l'intérieur doit rester ouvert")
	for audio in game.current_map.get_node("Runtime/Ambience").get_children():
		if audio is AudioStreamPlayer2D:
			(audio as AudioStreamPlayer2D).stop()
	game.free()
	await process_frame
	print("Plage vérifiée : terrain, épave, limites, réveil et découverte télékinétique sont structurés.")
	quit()


func _motion_is_blocked(player: CharacterBody2D, origin: Vector2, motion: Vector2) -> bool:
	player.global_position = origin
	PhysicsServer2D.body_set_state(player.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, player.global_transform)
	return player.test_move(player.global_transform, motion)
