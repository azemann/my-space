extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"
const BEACH_SCENE := "res://game/world/maps/plage-du-reveil/plage-du-reveil.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame

	var mast_path := "World/PlacedObjects/YSortedObjects/MatBrise"
	var mast := game.current_map.get_node(mast_path) as PsychokineticBody2D
	var stone := game.current_map.get_node("World/PlacedObjects/YSortedObjects/PierreEtrange") as PsychokineticBody2D
	var mast_persistence := mast.get_node("Persistence") as PersistentWorldInstance
	var stone_persistence := stone.get_node("Persistence") as PersistentWorldInstance
	assert(mast_persistence.persistent_id == &"tiled.1")
	assert(stone_persistence.persistent_id == &"practice_stone")

	# Le composant doit aussi fonctionner sur un Node2D créé dans l'éditeur,
	# sans que son parent possède un script de persistance particulier.
	var editor_instance := Node2D.new()
	editor_instance.name = "EditorConfiguredInstance"
	editor_instance.position = Vector2(111.0, 222.0)
	game.current_map.add_child(editor_instance)
	var editor_persistence := PersistentWorldInstance.new()
	editor_persistence.name = "Persistence"
	editor_persistence.persistent_id = &"test.editor_instance"
	editor_instance.add_child(editor_persistence)
	assert(game.world_state.capture_map_state(game.current_map) == 49)
	editor_instance.position = Vector2(900.0, 800.0)
	assert(game.world_state.restore_map_state(game.current_map) == 49)
	assert(editor_instance.position == Vector2(111.0, 222.0))
	editor_instance.free()

	var mast_position := mast.global_position + Vector2(73.0, 41.0)
	var stone_position := stone.global_position + Vector2(-52.0, 28.0)
	mast.global_position = mast_position
	mast.global_rotation = 0.37
	mast.linear_velocity = Vector2(120.0, -30.0)
	mast.angular_velocity = 2.0
	stone.global_position = stone_position
	assert(game.world_state.capture_map_state(game.current_map) == 48)

	await game.change_map(load(BEACH_SCENE) as PackedScene, &"beach-awakening")
	await physics_frame

	var restored_mast := game.current_map.get_node(mast_path) as PsychokineticBody2D
	var restored_stone := game.current_map.get_node("World/PlacedObjects/YSortedObjects/PierreEtrange") as PsychokineticBody2D
	assert(game.world_state.has_map_state(&"plage-du-reveil"))
	assert(restored_mast.global_position.is_equal_approx(mast_position),
		"Position restaurée %s, attendue %s" % [restored_mast.global_position, mast_position])
	assert(is_equal_approx(restored_mast.global_rotation, 0.37))
	assert(restored_mast.linear_velocity.is_zero_approx())
	assert(is_zero_approx(restored_mast.angular_velocity))
	assert(not restored_mast.is_held and not restored_mast.is_thrown)
	assert(is_zero_approx(restored_mast.height))
	assert(restored_stone.global_position.is_equal_approx(stone_position))

	game.queue_free()
	await process_frame
	print("État du monde vérifié : capture et restauration de 48 instances sur la plage.")
	quit()
