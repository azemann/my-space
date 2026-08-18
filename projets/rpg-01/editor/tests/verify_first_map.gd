extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"
const MAP_SCENE := "res://game/world/maps/vallee-des-sources/vallee-des-sources.tscn"


func _initialize() -> void:
	assert(ProjectSettings.get_setting("application/run/main_scene") == MAIN_SCENE)
	var main := (load(MAIN_SCENE) as PackedScene).instantiate()
	assert(main is GameRoot, "Le point d'entrée doit être le socle persistant du jeu")
	assert(main.get_node_or_null("WorldContainer/CurrentMap") != null)
	assert(main.get_node_or_null("PersistentActors/Player") is PlayerController)
	assert(main.get_node_or_null("Camera") is FollowCamera2D)
	assert(main.get_node_or_null("Interface/HUD") is Control)
	main.free()
	var packed := load(MAP_SCENE) as PackedScene
	assert(packed != null, "Carte introuvable")
	var level := packed.instantiate()
	var world := level.get_node_or_null("World")
	assert(world != null and world.get_meta("generated_by") == "rpg_tiled_converter")
	assert(level.get_meta("source_tmx") == "res://maps/source/vallee-des-sources.tmx")
	assert(level.get_meta("actor_parent_path") == NodePath("World/PlacedObjects/YSortedObjects"))
	assert(level.get_node_or_null("World/PlacedObjects/ArchitectureObjects/MaisonDuGardien") is TileMapLayer)
	assert(level.get_node_or_null("World/PlacedObjects/ArchitectureObjects/PontDeLaSource") is TileMapLayer)
	assert(level.get_node_or_null("World/Gameplay/HeightZones/NorthPlateau") is Area2D)
	assert(level.get_node_or_null("World/Gameplay/ElevationTransitions/NorthStairsTransition") is Area2D)
	assert(level.get_node_or_null("World/Gameplay/CollisionOverrides/WaterRow10Segment01") is StaticBody2D)
	assert(level.get_node_or_null("World/Gameplay/CollisionOverrides/WorldBoundaryNorth") is StaticBody2D)
	assert(level.get_node_or_null("World/Gameplay/CollisionOverrides/NorthCliffSideWest") is StaticBody2D)
	assert(level.get_node_or_null("World/Gameplay/Entrances/MaisonDuGardienDoor") is Area2D)
	assert(level.get_node_or_null("World/Gameplay/SpawnPoints/VillageArrival") is Marker2D)
	assert(level.get_node_or_null("World/Gameplay/CameraZones/BridgeCameraZone") is Area2D)
	assert(level.get_meta("camera_bounds") == Rect2(0, 0, 1280, 1280))
	assert(level.get_node_or_null("Runtime/Camera") == null, "Une carte ne doit pas posséder la caméra persistante")
	assert(level.get_node_or_null("World/PlacedObjects/YSortedObjects/Player") == null, "Une carte ne doit pas embarquer le joueur persistant")
	level.free()
	print("Architecture vérifiée : jeu persistant séparé de la vallée, pont, maison et contrats gameplay prêts.")
	quit()
