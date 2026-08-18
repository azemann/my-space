extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"
const BUDGET := preload("res://game/config/runtime_budget.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	for frame in 120:
		await physics_frame

	var targets: Array[Node] = get_nodes_in_group(&"psychokinetic_targets")
	assert(targets.size() >= 46, "La plage doit conserver tous ses objets déplaçables")
	assert(targets.size() <= BUDGET.maximum_psychokinetic_targets)
	var idle_processing := 0
	for node in targets:
		var body := node as PsychokineticBody2D
		assert(body != null and body.can_be_grabbed(0), "%s doit rester manipulable" % node.name)
		assert((body.collision_layer & 4) != 0, "%s doit conserver sa couche de physique d'interaction" % node.name)
		if body.is_processing() or body.is_physics_processing():
			idle_processing += 1
	assert(idle_processing <= BUDGET.maximum_idle_targets_processing,
		"Trop d'objets déplaçables continuent de travailler au repos : %d" % idle_processing)

	var controller := game.get_node("Psychokinesis") as PsychokinesisController
	var nearby := controller._nearby_targets()
	assert(not nearby.is_empty(), "Le voisinage doit trouver les objets proches du réveil")
	assert(nearby.size() < targets.size(), "Le filtre de portée ne doit pas retourner toute la carte")
	var runtime_node_count := _count_nodes(game)
	assert(runtime_node_count <= BUDGET.maximum_runtime_nodes,
		"Budget de nœuds dépassé : %d / %d" % [runtime_node_count, BUDGET.maximum_runtime_nodes])
	var footprints := game.current_map.get_node("Runtime/Footprints") as FootprintTrail2D
	assert(footprints.profile.maximum_visible_footprints <= BUDGET.maximum_visible_footprints)

	for audio in game.current_map.get_node("Runtime/Ambience").get_children():
		if audio is AudioStreamPlayer2D:
			(audio as AudioStreamPlayer2D).stop()
	var target_count := targets.size()
	var nearby_count := nearby.size()
	nearby.clear()
	targets.clear()
	controller = null
	footprints = null
	game.queue_free()
	for frame in 3:
		await process_frame
	print("Budget runtime vérifié : %d objets déplaçables, %d actifs au repos, %d candidats proches." % [target_count, idle_processing, nearby_count])
	quit()


func _count_nodes(node: Node) -> int:
	var total := 1
	for child in node.get_children():
		total += _count_nodes(child)
	return total
