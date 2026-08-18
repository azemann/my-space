extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"
const VALLEY_SCENE := "res://game/world/maps/vallee-des-sources/vallee-des-sources.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	game.initial_spawn_id = &"village-arrival"
	var initial_map := game.get_node("WorldContainer/CurrentMap")
	game.get_node("WorldContainer").remove_child(initial_map)
	initial_map.free()
	var valley := (load(VALLEY_SCENE) as PackedScene).instantiate()
	valley.name = "CurrentMap"
	game.get_node("WorldContainer").add_child(valley)
	root.add_child(game)
	await process_frame
	await physics_frame
	var player := game.player
	var world := game.current_map.get_node("World") as Node2D
	var collision_root := game.current_map.get_node("World/Gameplay/CollisionOverrides")
	assert(collision_root.get_child_count() >= 45, "La carte doit couvrir eau, relief et limites avec des volumes continus")

	assert(_map_motion_is_blocked(player, world, Vector2(800, 480), Vector2(220, 0)), "La rivière nord doit être infranchissable")
	assert(not _map_motion_is_blocked(player, world, Vector2(752, 656), Vector2(256, 0)), "Le pont doit rester franchissable d'ouest en est")
	assert(_map_motion_is_blocked(player, world, Vector2(500, 416), Vector2(0, -128)), "La face de falaise nord doit bloquer")
	assert(not _map_motion_is_blocked(player, world, Vector2(592, 416), Vector2(0, -128)), "L'escalier nord doit être le passage autorisé")
	assert(_map_motion_is_blocked(player, world, Vector2(400, 200), Vector2(96, 0)), "Le côté du plateau doit bloquer le contournement")
	assert(_map_motion_is_blocked(player, world, Vector2(32, 720), Vector2(-64, 0)), "Le bord du monde doit bloquer")

	var camera_zone := game.current_map.get_node("World/Gameplay/CameraZones/WorldCameraBounds") as Area2D
	assert(camera_zone.collision_layer == 4)
	assert(camera_zone.collision_mask == 2, "Une zone caméra doit détecter les acteurs")
	await physics_frame
	assert(game.camera.active_zones.has(camera_zone), "La caméra doit activer la zone qui contient le joueur")
	var bridge_camera_zone := game.current_map.get_node("World/Gameplay/CameraZones/BridgeCameraZone") as Area2D
	player.global_position = world.to_global(Vector2(880, 656))
	PhysicsServer2D.body_set_state(player.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, player.global_transform)
	await physics_frame
	await physics_frame
	assert(game.camera.active_zones.has(bridge_camera_zone), "La zone caméra du pont doit détecter le joueur")
	assert(game.camera.desired_zoom.is_equal_approx(Vector2.ONE))
	assert(game.camera.zone_offset == Vector2(0, -16))

	game.queue_free()
	await process_frame
	print("Traversabilité vérifiée : eau, falaises, côtés et limites bloquent ; pont et escalier passent ; zone caméra active.")
	quit()


func _map_motion_is_blocked(player: CharacterBody2D, world: Node2D, map_origin: Vector2, map_motion: Vector2) -> bool:
	player.global_position = world.to_global(map_origin)
	PhysicsServer2D.body_set_state(player.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, player.global_transform)
	var global_motion := world.to_global(map_origin + map_motion) - world.to_global(map_origin)
	return player.test_move(player.global_transform, global_motion)
