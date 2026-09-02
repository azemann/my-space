extends SceneTree

const REGISTRY = preload("res://game/serre/tiled/tiled_object_scene_registry.gd")
const REFERENCE := "res://sources/migrations/niveau-01-serre-avant-scenes-objets.tscn"
const DEFAULT_LEVEL := "res://scenes/levels/niveau-01-serre.tscn"
const CORRECTED_COLLISIONS := ["Gameplay/Graine04", "Gameplay/Graine05"]

const OBJECTS := {
	"Collisions/FosseToxique": "hazard",
	"Collisions/Pics": "hazard",
	"Collisions/Echelle": "climbable",
	"Collisions/Chaine": "climbable",
	"Collisions/Ressort": "bounce",
	"Gameplay/Checkpoint01": "checkpoint",
	"Gameplay/LevierIrrigation": "interactable",
	"Gameplay/SortieSerre": "exit",
	"Gameplay/Graine01": "collectible",
	"Gameplay/Graine02": "collectible",
	"Gameplay/Graine03": "collectible",
	"Gameplay/Graine04": "collectible",
	"Gameplay/Graine05": "collectible",
	"Zones/ZoneMort": "death_zone",
	"Zones/DeclencheurSortie": "trigger",
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var level_path := str(args[0]) if not args.is_empty() else DEFAULT_LEVEL
	var reference := (load(REFERENCE) as PackedScene).instantiate()
	var level := (load(level_path) as PackedScene).instantiate()
	root.add_child(reference)
	root.add_child(level)
	await process_frame

	var failures := 0
	for object_path in OBJECTS:
		var before := reference.get_node_or_null(object_path) as Area2D
		var after := level.get_node_or_null(object_path) as Area2D
		var kind := str(OBJECTS[object_path])
		if before == null or after == null:
			push_error("Objet absent après migration: %s." % object_path)
			failures += 1
			continue
		if after.scene_file_path != REGISTRY.scene_path(kind):
			push_error("%s n'est pas une instance de %s." % [object_path, REGISTRY.scene_path(kind)])
			failures += 1
		if str(after.get_meta("object_scene", "")) != REGISTRY.scene_path(kind):
			push_error("%s a perdu la référence object_scene." % object_path)
			failures += 1
		failures += _compare_area(object_path, before, after)

	for technical_path in ["Zones/LimitesCamera", "Zones/ZoneAmbianceVerriere"]:
		var technical := level.get_node_or_null(technical_path) as Area2D
		if technical == null or not technical.scene_file_path.is_empty():
			push_error("La zone technique %s ne doit pas devenir un objet de gameplay." % technical_path)
			failures += 1

	var static_count := 0
	var one_way_count := 0
	for body in level.find_children("*", "StaticBody2D", true, false):
		static_count += 1
		if not body.get_meta("grapple_enabled", false):
			push_error("%s n'est pas marqué comme agrippable." % body.name)
			failures += 1
		if str(body.get_meta("tiled_type", "")) == "one_way":
			one_way_count += 1
	if static_count != 8 or one_way_count != 6:
		push_error("Géométrie niveau 1: %d corps statiques et %d one-way, attendu 8 et 6." % [static_count, one_way_count])
		failures += 1

	var ladder := level.get_node("Collisions/Echelle")
	var ladder_shapes := ladder.find_children("*", "CollisionShape2D", false, false)
	if ladder_shapes.size() != 3:
		push_error("Les 3 collisions manuelles de l'échelle n'ont pas toutes été conservées.")
		failures += 1
	elif ladder_shapes[1].shape == ladder_shapes[2].shape:
		push_error("Les collisions dupliquées de l'échelle partagent encore la même ressource Shape2D.")
		failures += 1

	for seed_path in CORRECTED_COLLISIONS:
		var seed_collision := level.get_node(seed_path + "/CollisionShape2D") as CollisionShape2D
		var seed_shape := seed_collision.shape as RectangleShape2D
		if seed_collision.position != Vector2.ZERO or seed_shape == null or seed_shape.size != Vector2(20, 20):
			push_error("%s doit avoir une zone de collecte centrée de 20 × 20 px." % seed_path)
			failures += 1

	print("Niveau 1 vérifié: %d objets réutilisables, %d statiques, %d one-way, erreurs: %d" % [OBJECTS.size(), static_count, one_way_count, failures])
	reference.queue_free()
	level.queue_free()
	quit(1 if failures > 0 else 0)


func _compare_area(label: String, before: Area2D, after: Area2D) -> int:
	var failures := 0
	var before_values := [before.transform, before.visible, before.collision_layer, before.collision_mask, before.monitoring, before.monitorable]
	var after_values := [after.transform, after.visible, after.collision_layer, after.collision_mask, after.monitoring, after.monitorable]
	if before_values != after_values:
		push_error("Les propriétés de %s ont changé pendant la migration." % label)
		failures += 1
	for key in before.get_meta_list():
		if after.get_meta(key, null) != before.get_meta(key):
			push_error("Métadonnée %s différente sur %s." % [key, label])
			failures += 1

	var before_shapes := before.find_children("*", "CollisionShape2D", false, false)
	var after_shapes := after.find_children("*", "CollisionShape2D", false, false)
	if before_shapes.size() != after_shapes.size():
		push_error("Nombre de collisions différent sur %s." % label)
		return failures + 1
	if label in CORRECTED_COLLISIONS:
		return failures
	for index in before_shapes.size():
		var old_shape := before_shapes[index] as CollisionShape2D
		var new_shape := after_shapes[index] as CollisionShape2D
		var old_values := [old_shape.name, old_shape.transform, old_shape.disabled, old_shape.one_way_collision, old_shape.one_way_collision_margin]
		var new_values := [new_shape.name, new_shape.transform, new_shape.disabled, new_shape.one_way_collision, new_shape.one_way_collision_margin]
		if old_values != new_values or not _same_shape(old_shape.shape, new_shape.shape):
			push_error("Collision %d différente sur %s." % [index, label])
			failures += 1
	return failures


func _same_shape(before: Shape2D, after: Shape2D) -> bool:
	if before == null or after == null or before.get_class() != after.get_class():
		return before == after
	if before is RectangleShape2D:
		return before.size == after.size
	if before is CircleShape2D:
		return is_equal_approx(before.radius, after.radius)
	if before is CapsuleShape2D:
		return is_equal_approx(before.radius, after.radius) and is_equal_approx(before.height, after.height)
	return true
