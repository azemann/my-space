extends SceneTree

const REGISTRY = preload("res://game/serre/tiled/tiled_object_scene_registry.gd")
const SOURCE := "res://scenes/levels/niveau-01-serre.tscn"
const TARGET := "res://scenes/levels/niveau-01-serre-architecture-preview.tscn"

const NAME_KINDS := {
	"FosseToxique": "hazard",
	"Pics": "hazard",
	"Echelle": "climbable",
	"Chaine": "climbable",
	"Ressort": "bounce",
	"Checkpoint01": "checkpoint",
	"LevierIrrigation": "interactable",
	"SortieSerre": "exit",
	"Graine01": "collectible",
	"Graine02": "collectible",
	"Graine03": "collectible",
	"Graine04": "collectible",
	"Graine05": "collectible",
	"ZoneMort": "death_zone",
	"DeclencheurSortie": "trigger",
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed := load(SOURCE) as PackedScene
	if packed == null:
		push_error("Impossible de charger %s." % SOURCE)
		quit(1)
		return

	var level := packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var areas: Array[Area2D] = []
	for node in level.find_children("*", "Area2D", true, false):
		areas.append(node as Area2D)

	var registered := 0
	for area in areas:
		var kind := _infer_kind(area)
		if not REGISTRY.has_scene(kind):
			continue
		if area.scene_file_path == REGISTRY.scene_path(kind):
			registered += 1
			continue
		if not _replace_area(level, area, kind):
			level.free()
			quit(1)
			return
		registered += 1

	var tagged_bodies := _tag_static_geometry(level)
	var result := PackedScene.new()
	var pack_error := result.pack(level)
	if pack_error != OK:
		push_error("Impossible d'empaqueter le niveau 1: erreur %d." % pack_error)
		level.free()
		quit(1)
		return
	var save_error := ResourceSaver.save(result, TARGET)
	level.free()
	if save_error != OK:
		push_error("Impossible d'enregistrer %s: erreur %d." % [TARGET, save_error])
		quit(1)
		return

	print("Migration niveau 1 préparée: %d objets réutilisables, %d corps statiques typés." % [registered, tagged_bodies])
	quit(0 if registered == NAME_KINDS.size() else 1)


func _infer_kind(area: Area2D) -> String:
	var explicit_kind := str(area.get_meta("kind", ""))
	if not explicit_kind.is_empty():
		return explicit_kind
	if NAME_KINDS.has(area.name):
		return str(NAME_KINDS[area.name])
	return ""


func _replace_area(level: Node, source: Area2D, kind: String) -> bool:
	var parent := source.get_parent()
	var sibling_index := source.get_index()
	var source_name := source.name
	var object_scene := load(REGISTRY.scene_path(kind)) as PackedScene
	var instance := object_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Area2D
	if instance == null:
		push_error("La scène du type %s n'a pas une racine Area2D." % kind)
		return false

	instance.transform = source.transform
	instance.visible = source.visible
	instance.modulate = source.modulate
	instance.self_modulate = source.self_modulate
	instance.z_index = source.z_index
	instance.z_as_relative = source.z_as_relative
	instance.y_sort_enabled = source.y_sort_enabled
	instance.collision_layer = source.collision_layer
	instance.collision_mask = source.collision_mask
	instance.monitoring = source.monitoring
	instance.monitorable = source.monitorable
	instance.input_pickable = source.input_pickable
	instance.priority = source.priority
	for group in source.get_groups():
		instance.add_to_group(group, true)
	for key in source.get_meta_list():
		instance.set_meta(key, source.get_meta(key))
	instance.set_meta("kind", kind)
	instance.set_meta("object_scene", REGISTRY.scene_path(kind))
	_copy_optional_property(source, instance, "config")

	parent.add_child(instance)
	parent.move_child(instance, sibling_index)
	instance.owner = level

	for child in source.get_children():
		child.owner = null
		child.reparent(instance, false)
		_make_owned(child, level)
		if child is CollisionShape2D and child.shape != null:
			child.shape = child.shape.duplicate(true)

	source.free()
	instance.name = source_name
	return true


func _copy_optional_property(source: Object, target: Object, property_name: StringName) -> void:
	if _has_property(source, property_name) and _has_property(target, property_name):
		target.set(property_name, source.get(property_name))


func _has_property(object: Object, property_name: StringName) -> bool:
	for property in object.get_property_list():
		if property.name == property_name:
			return true
	return false


func _make_owned(node: Node, owner: Node) -> void:
	node.owner = owner
	for child in node.get_children():
		_make_owned(child, owner)


func _tag_static_geometry(level: Node) -> int:
	var tagged := 0
	for body in level.find_children("*", "StaticBody2D", true, false):
		var one_way := false
		for child in body.get_children():
			if child is CollisionShape2D and child.one_way_collision:
				one_way = true
				break
		body.set_meta("tiled_type", "one_way" if one_way else "solid")
		body.set_meta("grapple_enabled", true)
		tagged += 1
	return tagged
