extends SceneTree

const REGISTRY = preload("res://game/serre/tiled/tiled_object_scene_registry.gd")
const LEVEL_2 := "res://scenes/levels/niveau-02-racines.tscn"

const EXPECTED_COUNTS := {
	"climbable": 2,
	"bounce": 1,
	"hazard": 3,
	"death_zone": 1,
	"checkpoint": 1,
	"collectible": 4,
	"interactable": 1,
	"exit": 1,
	"trigger": 1,
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures := 0
	var level := (load(LEVEL_2) as PackedScene).instantiate()
	root.add_child(level)
	await process_frame
	var counts := {}
	var registered_instances := 0
	for area in level.find_children("*", "Area2D", true, false):
		var kind := str(area.get_meta("kind", ""))
		if not REGISTRY.has_scene(kind):
			continue
		registered_instances += 1
		counts[kind] = int(counts.get(kind, 0)) + 1
		var expected_path := REGISTRY.scene_path(kind)
		if area.scene_file_path != expected_path:
			push_error("%s est aplati au lieu d'instancier %s." % [area.name, expected_path])
			failures += 1
		if str(area.get_meta("object_scene", "")) != expected_path:
			push_error("%s a perdu la trace de sa scène source." % area.name)
			failures += 1

	for kind in EXPECTED_COUNTS:
		if int(counts.get(kind, 0)) != int(EXPECTED_COUNTS[kind]):
			push_error("Type %s: %d instances au lieu de %d." % [kind, counts.get(kind, 0), EXPECTED_COUNTS[kind]])
			failures += 1
	if registered_instances != 15:
		push_error("Le niveau 2 doit contenir 15 instances de gameplay réutilisables.")
		failures += 1

	var lever := level.find_child("LevierSortie", true, false)
	var door := level.find_child("PorteSortie", true, false)
	if lever == null or lever.get_node_or_null("AnimationPlayer") == null:
		push_error("Le levier n'utilise pas sa scène animable.")
		failures += 1
	if door == null or door.get_node_or_null("AnimationPlayer") == null:
		push_error("La porte n'utilise pas sa scène animable.")
		failures += 1

	print("Architecture objets vérifiée: %d instances, erreurs: %d" % [registered_instances, failures])
	level.queue_free()
	quit(1 if failures > 0 else 0)
