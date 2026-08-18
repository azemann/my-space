@tool
class_name RpgTiledConverter
extends RefCounted

const FLIP_H := 0x80000000
const FLIP_V := 0x40000000
const FLIP_D := 0x20000000
const GID_MASK := 0x0fffffff
const EnvironmentAnimations = preload("res://game/systems/environment_animation/environment_animation_registry.gd")


static func convert_all(profile) -> Error:
	var tile_set := load(profile.TILESET_PATH) as TileSet
	if tile_set == null:
		push_error("TileSet canonique introuvable : %s" % profile.TILESET_PATH)
		return ERR_CANT_OPEN
	var jobs: Array[Dictionary] = []
	for file_name in DirAccess.get_files_at(profile.MAPS_DIRECTORY):
		if file_name.get_extension().to_lower() != "tmx":
			continue
		var source_path: String = profile.MAPS_DIRECTORY.path_join(file_name)
		var parsed := _parse_tmx(source_path)
		if parsed.is_empty():
			return ERR_PARSE_ERROR
		var bind_error := _bind_canonical_tile_set(source_path, parsed, tile_set)
		if bind_error != OK:
			return bind_error
		var validation_error := _validate_map(source_path, parsed, tile_set)
		if validation_error != OK:
			return validation_error
		jobs.append({"source_path": source_path, "parsed": parsed})
	_ensure_directory(profile.GENERATED_SCENES_DIRECTORY)
	for job in jobs:
		var level_id := str(job.parsed.properties.get("level_id", str(job.source_path).get_file().get_basename()))
		var error := _build_scene(str(job.source_path), job.parsed, tile_set, profile, profile.level_scene_path(level_id))
		if error != OK:
			return error
	return OK


static func convert_map(source_path: String, profile) -> Error:
	var parsed := _parse_tmx(source_path)
	if parsed.is_empty():
		return ERR_PARSE_ERROR
	var tile_set := load(profile.TILESET_PATH) as TileSet
	if tile_set == null:
		push_error("TileSet canonique introuvable : %s" % profile.TILESET_PATH)
		return ERR_CANT_OPEN
	var bind_error := _bind_canonical_tile_set(source_path, parsed, tile_set)
	if bind_error != OK:
		return bind_error
	var validation_error := _validate_map(source_path, parsed, tile_set)
	if validation_error != OK:
		return validation_error
	_ensure_directory(profile.GENERATED_SCENES_DIRECTORY)
	var level_id := str(parsed.properties.get("level_id", source_path.get_file().get_basename()))
	return _build_scene(source_path, parsed, tile_set, profile, profile.level_scene_path(level_id))


static func _ensure_directory(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


static func _bind_canonical_tile_set(source_path: String, parsed: Dictionary, tile_set: TileSet) -> Error:
	var runtime: Array[Dictionary] = []
	for definition in parsed.tilesets:
		var tsx_path := source_path.get_base_dir().path_join(str(definition.source)).simplify_path()
		var info := _parse_tsx(tsx_path)
		if info.is_empty():
			push_error("TSX RPG illisible : %s" % tsx_path)
			return ERR_PARSE_ERROR
		var source_id := int(info.godot_source_id)
		if source_id < 0 or not tile_set.has_source(source_id):
			push_error("Le TSX %s vise une source Godot absente : %d" % [tsx_path, source_id])
			return ERR_INVALID_DATA
		var first_gid := int(definition.first_gid)
		var last_gid := first_gid + int(info.tile_count) - 1
		runtime.append({
			"first_gid": first_gid,
			"last_gid": last_gid,
			"columns": int(info.columns),
			"source_id": source_id,
			"atlas_coordinates": info.atlas_coordinates,
			"tile_metadata": info.tile_metadata,
			"tsx_path": tsx_path,
		})
	parsed["runtime_tilesets"] = runtime
	return OK


static func _validate_map(source_path: String, parsed: Dictionary, tile_set: TileSet) -> Error:
	if tile_set.tile_size != Vector2i(int(parsed.tile_width), int(parsed.tile_height)):
		push_error("Grille Tiled incompatible avec le TileSet dans %s." % source_path)
		return ERR_INVALID_DATA
	var names := {}
	for layer in parsed.layers:
		var layer_name := str(layer.name)
		if names.has(layer_name):
			push_error("Calque de tuiles dupliqué '%s' dans %s." % [layer_name, source_path])
			return ERR_INVALID_DATA
		names[layer_name] = true
		if layer.data.size() != int(layer.width) * int(layer.height):
			push_error("Taille CSV incorrecte pour le calque '%s'." % layer_name)
			return ERR_INVALID_DATA
		for raw_gid in layer.data:
			var gid := int(raw_gid)
			if _base_gid(gid) == 0:
				continue
			var resolved := _resolve_gid(gid, parsed.runtime_tilesets)
			if resolved.is_empty():
				push_error("GID %d sans correspondance dans '%s'." % [_base_gid(gid), layer_name])
				return ERR_INVALID_DATA
			var atlas := tile_set.get_source(int(resolved.source_id)) as TileSetAtlasSource
			if atlas == null or not atlas.has_tile(resolved.atlas_coords):
				push_error("Tuile Godot absente pour le GID %d dans '%s'." % [_base_gid(gid), layer_name])
				return ERR_INVALID_DATA
		var animation_profile := StringName(str(layer.properties.get(
			"environment_animation_profile",
			EnvironmentAnimations.default_profile_for_layer(layer_name)
		)))
		if not animation_profile.is_empty() and not EnvironmentAnimations.has_profile(animation_profile):
			push_error("Profil d'animation environnementale inconnu '%s' dans le calque '%s' de %s." % [animation_profile, layer_name, source_path])
			return ERR_INVALID_DATA
	for object_group in parsed.object_groups:
		for object in object_group.objects:
			var object_gid := int(object.get("gid", 0))
			if object_gid == 0:
				continue
			var resolved := _resolve_gid(object_gid, parsed.runtime_tilesets)
			if resolved.is_empty():
				push_error("Objet GID %d sans correspondance dans '%s'." % [_base_gid(object_gid), object_group.name])
				return ERR_INVALID_DATA
			var atlas := tile_set.get_source(int(resolved.source_id)) as TileSetAtlasSource
			if atlas == null or not atlas.has_tile(resolved.atlas_coords):
				push_error("Objet Godot absent pour le GID %d dans '%s'." % [_base_gid(object_gid), object_group.name])
				return ERR_INVALID_DATA
			var metadata: Dictionary = resolved.get("metadata", {})
			var expected_width := float(metadata.get("tiled_image_width", object.get("width", 0.0)))
			var expected_height := float(metadata.get("tiled_image_height", object.get("height", 0.0)))
			if absf(float(object.get("width", expected_width)) - expected_width) > 0.01 or absf(float(object.get("height", expected_height)) - expected_height) > 0.01:
				push_error("L'objet '%s' est redimensionné dans Tiled ; le pipeline interdit l'échelle par instance." % object.get("name", metadata.get("object_id", object_gid)))
				return ERR_INVALID_DATA
	return _validate_gameplay_contract(source_path, parsed)


static func _validate_gameplay_contract(source_path: String, parsed: Dictionary) -> Error:
	for property_name in ["level_id", "traversal_contract_version", "camera_contract_version"]:
		if not parsed.properties.has(property_name):
			push_error("Contrat RPG incomplet dans %s : propriété '%s' absente." % [source_path, property_name])
			return ERR_INVALID_DATA
	var groups := {}
	for object_group in parsed.object_groups:
		groups[str(object_group.name)] = object_group
	for group_name in ["HeightZones", "ElevationTransitions", "CollisionOverrides", "Entrances", "Exits", "Interactions", "SpawnPoints", "CameraZones"]:
		if not groups.has(group_name):
			push_error("Contrat RPG incomplet dans %s : calque '%s' absent." % [source_path, group_name])
			return ERR_INVALID_DATA
	var collision_names := {}
	for object in groups.CollisionOverrides.objects:
		collision_names[str(object.get("name", ""))] = true
	for boundary in ["WorldBoundaryNorth", "WorldBoundarySouth", "WorldBoundaryWest", "WorldBoundaryEast"]:
		if not collision_names.has(boundary):
			push_error("Carte ouverte dans %s : bord physique '%s' absent." % [source_path, boundary])
			return ERR_INVALID_DATA
	var spawn_ids := {}
	for object in groups.SpawnPoints.objects:
		var spawn_id := str(object.properties.get("spawn_id", ""))
		if spawn_id.is_empty() or spawn_ids.has(spawn_id):
			push_error("spawn_id absent ou dupliqué dans %s." % source_path)
			return ERR_INVALID_DATA
		spawn_ids[spawn_id] = true
	if spawn_ids.is_empty():
		push_error("Aucun point d'apparition dans %s." % source_path)
		return ERR_INVALID_DATA
	if groups.CameraZones.objects.is_empty():
		push_error("Aucune zone caméra dans %s." % source_path)
		return ERR_INVALID_DATA
	for object in groups.CameraZones.objects:
		for property_name in ["limit_left", "limit_top", "limit_right", "limit_bottom", "zoom"]:
			if not object.properties.has(property_name):
				push_error("Zone caméra '%s' sans '%s' dans %s." % [object.get("name", ""), property_name, source_path])
				return ERR_INVALID_DATA
	for object in groups.ElevationTransitions.objects:
		if not object.properties.has("from_height") or not object.properties.has("to_height"):
			push_error("Transition de hauteur '%s' incomplète dans %s." % [object.get("name", ""), source_path])
			return ERR_INVALID_DATA
	return OK


static func _build_scene(source_path: String, parsed: Dictionary, tile_set: TileSet, profile, target_path: String) -> Error:
	var root := Node2D.new()
	var level_id := str(parsed.properties.get("level_id", source_path.get_file().get_basename()))
	root.name = _safe_name(level_id)
	root.editor_description = "Niveau généré depuis %s. Modifier le TMX, pas cette scène." % source_path
	root.set_meta("source_tmx", source_path)
	root.set_meta("generated_by", "rpg_tiled_converter")
	root.set_meta("level_name", str(parsed.properties.get("level_name", "")))
	var groups := {}
	for layer in parsed.layers:
		var parent := _group_parent(root, groups, layer.group_path, profile)
		var node := TileMapLayer.new()
		node.name = str(layer.name)
		node.tile_set = tile_set
		node.z_index = int(layer.properties.get("z_index", 0))
		node.y_sort_enabled = bool(layer.properties.get("y_sort", false))
		node.visible = bool(layer.visible)
		node.modulate.a = float(layer.opacity)
		node.position = Vector2(float(layer.offset_x), float(layer.offset_y))
		# Un calque peint décrit l'image, jamais la traversabilité. Les formes
		# géographiques de la carte vivent exclusivement dans
		# Gameplay/CollisionOverrides ; les objets placés conservent leurs corps
		# physiques propres dans _convert_tile_object().
		node.collision_enabled = false
		node.editor_description = profile.description(str(layer.name))
		node.set_meta("source_tiled_layer", str(layer.name))
		node.set_meta("source_tiled_group", "/".join(layer.group_path))
		node.set_meta("collision_policy", "visual_layer_collision_disabled")
		_copy_meta(node, layer.properties)
		var animation_profile := StringName(str(layer.properties.get(
			"environment_animation_profile",
			EnvironmentAnimations.default_profile_for_layer(str(layer.name))
		)))
		if not animation_profile.is_empty():
			node.material = EnvironmentAnimations.create_material(animation_profile, layer.properties)
			node.set_meta("environment_animation_profile", animation_profile)
			node.set_meta("environment_animation_pipeline", "profile_v1")
		_add_owned(parent, node, root)
		for index in layer.data.size():
			var gid := int(layer.data[index])
			if _base_gid(gid) == 0:
				continue
			var resolved := _resolve_gid(gid, parsed.runtime_tilesets)
			if resolved.is_empty():
				root.free()
				push_error("GID %d sans TSX dans %s/%s" % [_base_gid(gid), "/".join(layer.group_path), layer.name])
				return ERR_INVALID_DATA
			var cell := Vector2i(index % int(layer.width), index / int(layer.width))
			node.set_cell(cell, int(resolved.source_id), resolved.atlas_coords, _alternative(gid))
	for object_group in parsed.object_groups:
		var parent := _group_parent(root, groups, object_group.group_path, profile)
		var group_node := Node2D.new()
		group_node.name = str(object_group.name)
		group_node.editor_description = profile.description(str(object_group.name))
		group_node.visible = bool(object_group.visible)
		group_node.z_index = int(object_group.properties.get("z_index", 0))
		group_node.y_sort_enabled = bool(object_group.properties.get("y_sort", false))
		group_node.set_meta("source_tiled_layer", str(object_group.name))
		group_node.set_meta("godot_role", str(object_group.properties.get("godot_role", profile.object_role(str(object_group.name)))))
		_copy_meta(group_node, object_group.properties)
		_add_owned(parent, group_node, root)
		for object in object_group.objects:
			_convert_object(object, group_node, root, str(group_node.get_meta("godot_role")), profile, tile_set, parsed.runtime_tilesets)
	var packed := PackedScene.new()
	var pack_error := packed.pack(root)
	if pack_error != OK:
		root.free()
		return pack_error
	var save_error := ResourceSaver.save(packed, target_path)
	root.free()
	return save_error


static func _group_parent(root: Node, groups: Dictionary, path: Array, profile) -> Node:
	var parent := root
	var key := ""
	for part in path:
		key = "%s/%s" % [key, str(part)]
		if groups.has(key):
			parent = groups[key]
			continue
		var group := Node2D.new()
		group.name = str(part)
		group.editor_description = profile.description(str(part))
		group.set_meta("source_tiled_group", key.trim_prefix("/"))
		_add_owned(parent, group, root)
		groups[key] = group
		parent = group
	return parent


static func _convert_object(object: Dictionary, parent: Node, owner: Node, role: String, profile, tile_set: TileSet, definitions: Array) -> void:
	if int(object.get("gid", 0)) != 0:
		_convert_tile_object(object, parent, owner, profile, tile_set, definitions)
		return
	var kind := str(object.get("class", object.get("type", "")))
	if role == "collision" or kind == "solid":
		var body := StaticBody2D.new()
		_configure_node(body, object, profile)
		body.collision_layer = int(object.properties.get("collision_layer", 1))
		body.collision_mask = int(object.properties.get("collision_mask", 1))
		_add_owned(parent, body, owner)
		_add_rectangle_shape(body, object, owner)
	elif role == "navigation":
		var region := NavigationRegion2D.new()
		_configure_node(region, object, profile)
		var width := float(object.get("width", 0.0))
		var height := float(object.get("height", 0.0))
		var polygon := NavigationPolygon.new()
		polygon.vertices = PackedVector2Array([Vector2.ZERO, Vector2(width, 0), Vector2(width, height), Vector2(0, height)])
		polygon.add_polygon(PackedInt32Array([0, 1, 2, 3]))
		region.navigation_polygon = polygon
		_add_owned(parent, region, owner)
	elif role == "spawn" or str(object.get("shape", "rectangle")) == "point":
		var marker := Marker2D.new()
		_configure_node(marker, object, profile)
		_add_owned(parent, marker, owner)
	else:
		var area := Area2D.new()
		_configure_node(area, object, profile)
		area.collision_layer = int(object.properties.get("collision_layer", 4))
		# Les volumes gameplay (portes, hauteurs, caméra, interactions) doivent
		# détecter les acteurs, couche 2. Un override Tiled reste possible.
		area.collision_mask = int(object.properties.get("collision_mask", 2))
		_add_owned(parent, area, owner)
		_add_collision_geometry(area, object, owner)


static func _convert_tile_object(object: Dictionary, parent: Node, owner: Node, profile, tile_set: TileSet, definitions: Array) -> void:
	var gid := int(object.get("gid", 0))
	var resolved := _resolve_gid(gid, definitions)
	if resolved.is_empty():
		push_error("Objet Tiled avec GID sans correspondance : %d" % _base_gid(gid))
		return
	var metadata: Dictionary = resolved.get("metadata", {})
	if str(metadata.get("psychokinesis_response", "anchored")) == "movable":
		_convert_psychokinetic_tile_object(object, parent, owner, profile, tile_set, resolved)
		return
	var tile_object := TileMapLayer.new()
	var fallback_name := str(metadata.get("object_id", "TiledTileObject"))
	var configured := object.duplicate(true)
	if str(configured.get("name", "")).is_empty():
		configured.name = fallback_name
	if str(configured.get("class", configured.get("type", ""))).is_empty():
		configured["class"] = str(metadata.get("default_role", "visual_object"))
	_configure_node(tile_object, configured, profile)
	tile_object.tile_set = tile_set
	var source_layer := str(parent.get_meta("source_tiled_layer", parent.name))
	var layer_has_collision := source_layer not in ["GroundObjects", "WaterObjects", "ForegroundObjects"]
	tile_object.collision_enabled = bool(object.properties.get("collision_enabled", layer_has_collision))
	tile_object.set_meta("collision_policy", "enabled_by_layer" if tile_object.collision_enabled else "disabled_by_layer")
	tile_object.position -= Vector2(tile_set.tile_size) * 0.5
	tile_object.z_index = int(object.properties.get("z_index", 0))
	tile_object.set_cell(Vector2i.ZERO, int(resolved.source_id), resolved.atlas_coords, _alternative(gid))
	for key in metadata:
		tile_object.set_meta(str(key), metadata[key])
	_add_owned(parent, tile_object, owner)


static func _convert_psychokinetic_tile_object(object: Dictionary, parent: Node, owner: Node, profile, tile_set: TileSet, resolved: Dictionary) -> void:
	var metadata: Dictionary = resolved.get("metadata", {})
	var configured := object.duplicate(true)
	if str(configured.get("name", "")).is_empty():
		# Plusieurs exemplaires du même asset doivent rester reconnaissables et
		# uniques dans l'arbre Godot, même s'ils n'ont pas été nommés dans Tiled.
		configured.name = "%s_%s" % [
			str(metadata.get("object_id", "PsychokineticObject")),
			int(object.get("id", 0)),
		]
	if str(configured.get("class", configured.get("type", ""))).is_empty():
		configured["class"] = str(metadata.get("default_role", "interactable"))
	var role := str(configured.get("class", configured.get("type", "interactable")))
	var mass_name := str(metadata.get("psychokinesis_mass", "light"))

	var scene_kind := &"psychokinetic_prop"
	var body := profile.instantiate_object(scene_kind) as PsychokineticBody2D
	if body == null:
		push_error("Impossible d'instancier la scène Godot '%s'." % scene_kind)
		return
	_configure_node(body, configured, profile)
	body.collision_layer = 5 if _role_blocks_actors(role) else 4
	body.collision_mask = 1
	body.blocks_actors_when_grounded = _role_blocks_actors(role)
	body.mass = _mass_value(mass_name)
	body.selection_radius = _selection_radius(role, mass_name)
	body.default_hold_height = _hold_height(mass_name)
	body.maximum_height = _maximum_height(mass_name)
	body.visual_focus_offset = _visual_focus_offset(metadata, body.selection_radius)
	body.profile = _psychokinesis_profile(metadata)
	body.z_index = int(object.properties.get("z_index", 0))
	for key in metadata:
		body.set_meta(str(key), metadata[key])
	body.set_meta("collision_policy", "dynamic_psychokinetic_body")
	body.set_meta("object_scene", profile.object_scene_path(scene_kind))
	body.editor_description += "\nScène Godot : %s\nAutorité : Godot pour le comportement ; Tiled pour le placement et les surcharges d'instance." % profile.object_scene_path(scene_kind)
	if parent.has_node(NodePath(str(body.name))):
		body.name = "%s_%d" % [body.name, int(object.get("id", 0))]
	_add_owned(parent, body, owner)
	# Les composants restent hérités de la PackedScene, mais leurs paramètres
	# propres au placement doivent être sérialisés comme surcharges d'instance.
	# Sans ce drapeau Godot conserve le lien de scène mais ignore les changements
	# apportés à Visual, Persistence, CollisionShape2D et Shadow.
	owner.set_editable_instance(body, true)

	var persistence := body.get_node("Persistence") as PersistentWorldInstance
	persistence.persistent_id = StringName(object.properties.get(
		"persistent_id", "tiled.%d" % int(object.get("id", 0))))

	var visual := body.get_node("Visual") as TileMapLayer
	visual.tile_set = tile_set
	visual.clear()
	visual.collision_enabled = false
	visual.position = -Vector2(tile_set.tile_size) * 0.5
	visual.set_cell(Vector2i.ZERO, int(resolved.source_id), resolved.atlas_coords, _alternative(int(object.get("gid", 0))))

	var selection_ghost := body.get_node("SelectionGhost") as TileMapLayer
	selection_ghost.tile_set = tile_set
	selection_ghost.clear()
	selection_ghost.collision_enabled = false
	selection_ghost.position = visual.position
	selection_ghost.visible = false
	selection_ghost.set_cell(Vector2i.ZERO, int(resolved.source_id), resolved.atlas_coords, _alternative(int(object.get("gid", 0))))

	var selection_area := body.get_node("SelectionArea") as Area2D
	selection_area.position = body.visual_focus_offset
	var selection_shape := RectangleShape2D.new()
	selection_shape.resource_local_to_scene = true
	selection_shape.size = Vector2(
		maxf(float(metadata.get("content_width", body.selection_radius * 2.0)), 8.0),
		maxf(float(metadata.get("content_height", body.selection_radius * 2.0)), 8.0)
	)
	(selection_area.get_node("HoverShape") as CollisionShape2D).shape = selection_shape

	var footprint := _footprint_size(role, mass_name)
	var shape := CapsuleShape2D.new()
	shape.resource_local_to_scene = true
	shape.radius = minf(footprint.x, footprint.y) * 0.5
	shape.height = maxf(footprint.x, footprint.y)
	var collision := body.get_node("PhysicsFootprint") as CollisionShape2D
	collision.rotation = PI * 0.5 if footprint.x > footprint.y else 0.0
	collision.shape = shape

	var shadow := body.get_node("Shadow") as Polygon2D
	shadow.polygon = PackedVector2Array([
		Vector2(-footprint.x * 0.48, -footprint.y * 0.18),
		Vector2(footprint.x * 0.48, -footprint.y * 0.18),
		Vector2(footprint.x * 0.58, footprint.y * 0.12),
		Vector2(footprint.x * 0.38, footprint.y * 0.28),
		Vector2(-footprint.x * 0.38, footprint.y * 0.28),
		Vector2(-footprint.x * 0.58, footprint.y * 0.12),
	])
	shadow.color = Color(0.05, 0.06, 0.07, 0.26)
	shadow.z_index = -1


static func _psychokinesis_profile(metadata: Dictionary) -> PsychokinesisProfile:
	var result := PsychokinesisProfile.new()
	result.response = PsychokinesisProfile.Response.MOVABLE
	match str(metadata.get("psychokinesis_mass", "light")):
		"medium": result.mass_class = PsychokinesisProfile.MassClass.MEDIUM
		"heavy": result.mass_class = PsychokinesisProfile.MassClass.HEAVY
		"immense": result.mass_class = PsychokinesisProfile.MassClass.IMMENSE
		_: result.mass_class = PsychokinesisProfile.MassClass.LIGHT
	result.material = StringName(str(metadata.get("psychokinesis_material", "mixed")))
	result.breakable = bool(metadata.get("psychokinesis_breakable", false))
	result.required_power = int(metadata.get("psychokinesis_required_power", 0))
	return result


static func _role_blocks_actors(role: String) -> bool:
	return role in ["solid_interactable", "solid_footprint", "small_obstacle", "tree_trunk_obstacle"]


static func _mass_value(mass_name: String) -> float:
	match mass_name:
		"medium": return 1.25
		"heavy": return 3.5
		"immense": return 8.0
		_: return 0.4


static func _selection_radius(role: String, mass_name: String) -> float:
	if mass_name in ["heavy", "immense"]:
		return 40.0
	return 32.0 if _role_blocks_actors(role) else 24.0


static func _visual_focus_offset(metadata: Dictionary, fallback_radius: float) -> Vector2:
	if not metadata.has("content_offset_x") or not metadata.has("content_offset_y"):
		return Vector2(0.0, -fallback_radius * 0.72)
	var foot_anchor := Vector2(
		float(metadata.get("foot_anchor_x", 0.0)),
		float(metadata.get("foot_anchor_y", metadata.get("tiled_image_height", 0.0)))
	)
	var content_center := Vector2(
		float(metadata.content_offset_x) + float(metadata.get("content_width", 0.0)) * 0.5,
		float(metadata.content_offset_y) + float(metadata.get("content_height", 0.0)) * 0.5
	)
	return content_center - foot_anchor


static func _hold_height(mass_name: String) -> float:
	return 10.0 if mass_name in ["heavy", "immense"] else 15.0 if mass_name == "medium" else 20.0


static func _maximum_height(mass_name: String) -> float:
	return 26.0 if mass_name in ["heavy", "immense"] else 38.0 if mass_name == "medium" else 48.0


static func _footprint_size(role: String, mass_name: String) -> Vector2:
	if mass_name in ["heavy", "immense"]:
		return Vector2(42.0, 20.0)
	if _role_blocks_actors(role):
		return Vector2(30.0, 16.0)
	return Vector2(14.0, 10.0)


static func _configure_node(node: Node2D, object: Dictionary, profile) -> void:
	var fallback := str(object.get("class", "TiledObject"))
	node.name = _safe_name(str(object.get("name", fallback)))
	node.position = Vector2(float(object.get("x", 0.0)), float(object.get("y", 0.0)))
	node.rotation_degrees = float(object.get("rotation", 0.0))
	node.visible = bool(object.get("visible", true))
	var kind := str(object.get("class", object.get("type", "object")))
	node.editor_description = "%s\nType Tiled : %s\nID Tiled : %s" % [profile.description(kind), kind, object.get("id", 0)]
	node.set_meta("tiled_id", int(object.get("id", 0)))
	node.set_meta("tiled_class", kind)
	_copy_meta(node, object.properties)


static func _add_rectangle_shape(parent: Node2D, object: Dictionary, owner: Node) -> void:
	_add_collision_geometry(parent, object, owner)


static func _add_collision_geometry(parent: Node2D, object: Dictionary, owner: Node) -> void:
	var shape_kind := str(object.get("shape", "rectangle"))
	var width := float(object.get("width", 0.0))
	var height := float(object.get("height", 0.0))
	if shape_kind == "polygon" or shape_kind == "ellipse":
		var polygon := CollisionPolygon2D.new()
		polygon.name = "CollisionPolygon2D"
		polygon.polygon = _object_polygon(object)
		_add_owned(parent, polygon, owner)
		return
	if shape_kind == "polyline":
		var points: PackedVector2Array = object.get("points", PackedVector2Array())
		for index in range(points.size() - 1):
			var segment_shape := SegmentShape2D.new()
			segment_shape.a = points[index]
			segment_shape.b = points[index + 1]
			var segment := CollisionShape2D.new()
			segment.name = "Segment%02d" % (index + 1)
			segment.shape = segment_shape
			_add_owned(parent, segment, owner)
		return
	width = maxf(width, float(object.properties.get("trigger_width", 16.0)))
	height = maxf(height, float(object.properties.get("trigger_height", 16.0)))
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = Vector2(width, height) * 0.5
	collision.shape = shape
	_add_owned(parent, collision, owner)


static func _object_polygon(object: Dictionary) -> PackedVector2Array:
	if str(object.get("shape", "")) == "polygon":
		return object.get("points", PackedVector2Array())
	var width := float(object.get("width", 0.0))
	var height := float(object.get("height", 0.0))
	var center := Vector2(width, height) * 0.5
	var points := PackedVector2Array()
	for index in range(16):
		var angle := TAU * float(index) / 16.0
		points.append(center + Vector2(cos(angle) * width * 0.5, sin(angle) * height * 0.5))
	return points


static func _add_owned(parent: Node, child: Node, owner: Node) -> void:
	parent.add_child(child)
	child.owner = owner


static func _copy_meta(node: Node, values: Dictionary) -> void:
	for key in values:
		node.set_meta(str(key), values[key])


static func _resolve_gid(gid: int, definitions: Array) -> Dictionary:
	var base := _base_gid(gid)
	for definition in definitions:
		if base < int(definition.first_gid) or base > int(definition.last_gid):
			continue
		var local_id := base - int(definition.first_gid)
		var atlas_coordinates: Dictionary = definition.get("atlas_coordinates", {})
		var columns := int(definition.columns)
		var atlas_coords := Vector2i.ZERO
		if columns > 0:
			atlas_coords = Vector2i(local_id % columns, local_id / columns)
		if atlas_coordinates.has(local_id):
			atlas_coords = atlas_coordinates[local_id]
		var tile_metadata: Dictionary = definition.get("tile_metadata", {})
		return {"source_id": int(definition.source_id), "atlas_coords": atlas_coords,
			"metadata": tile_metadata.get(local_id, {})}
	return {}


static func _base_gid(gid: int) -> int:
	return gid & GID_MASK


static func _alternative(gid: int) -> int:
	var alternative := 0
	if gid & FLIP_H:
		alternative |= TileSetAtlasSource.TRANSFORM_FLIP_H
	if gid & FLIP_V:
		alternative |= TileSetAtlasSource.TRANSFORM_FLIP_V
	if gid & FLIP_D:
		alternative |= TileSetAtlasSource.TRANSFORM_TRANSPOSE
	return alternative


static func _parse_tmx(path: String) -> Dictionary:
	var parser := XMLParser.new()
	if parser.open(path) != OK:
		return {}
	var result := {"width": 0, "height": 0, "tile_width": 32, "tile_height": 32,
		"properties": {}, "tilesets": [], "layers": [], "object_groups": []}
	var group_stack: Array[String] = []
	var current_layer := {}
	var current_object_group := {}
	var current_object := {}
	var reading_data := false
	var data_buffer := ""
	while parser.read() == OK:
		var node_type := parser.get_node_type()
		var node_name := parser.get_node_name() if node_type in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END] else ""
		if node_type == XMLParser.NODE_ELEMENT:
			var attrs := _attributes(parser)
			match node_name:
				"map":
					result.width = int(attrs.get("width", 0))
					result.height = int(attrs.get("height", 0))
					result.tile_width = int(attrs.get("tilewidth", 32))
					result.tile_height = int(attrs.get("tileheight", 32))
				"tileset":
					if attrs.has("source"):
						result.tilesets.append({"first_gid": int(attrs.get("firstgid", 1)), "source": str(attrs.source)})
				"group":
					group_stack.append(str(attrs.get("name", "Group")))
				"layer":
					current_layer = {"name": str(attrs.get("name", "Layer")), "width": int(attrs.get("width", result.width)),
						"height": int(attrs.get("height", result.height)), "visible": int(attrs.get("visible", 1)) != 0,
						"opacity": float(attrs.get("opacity", 1.0)), "offset_x": float(attrs.get("offsetx", 0.0)),
						"offset_y": float(attrs.get("offsety", 0.0)), "group_path": group_stack.duplicate(), "properties": {}, "data": []}
				"data":
					reading_data = true
					data_buffer = ""
				"objectgroup":
					current_object_group = {"name": str(attrs.get("name", "Objects")), "visible": int(attrs.get("visible", 1)) != 0,
						"group_path": group_stack.duplicate(), "properties": {}, "objects": []}
				"object":
					current_object = attrs
					current_object["properties"] = {}
					current_object["shape"] = "rectangle"
					if parser.is_empty():
						current_object_group.objects.append(current_object)
						current_object = {}
				"point", "ellipse":
					if not current_object.is_empty():
						current_object.shape = node_name
				"polygon", "polyline":
					if not current_object.is_empty():
						current_object.shape = node_name
						current_object.points = _parse_points(str(attrs.get("points", "")))
				"property":
					var key := str(attrs.get("name", "property"))
					var value = _property_value(attrs)
					if not current_object.is_empty(): current_object.properties[key] = value
					elif not current_object_group.is_empty(): current_object_group.properties[key] = value
					elif not current_layer.is_empty(): current_layer.properties[key] = value
					else: result.properties[key] = value
		elif node_type == XMLParser.NODE_TEXT and reading_data:
			data_buffer += parser.get_node_data()
		elif node_type == XMLParser.NODE_ELEMENT_END:
			match node_name:
				"data":
					reading_data = false
					# En CSV Tiled, un saut de ligne sépare aussi deux valeurs. Le supprimer
					# concaténerait la dernière cellule d'une ligne avec la première suivante.
					var normalized_csv := data_buffer.replace("\r", "").replace("\n", ",")
					for value in normalized_csv.split(",", false):
						current_layer.data.append(int(str(value).strip_edges()))
					result.layers.append(current_layer)
					current_layer = {}
				"object":
					if not current_object.is_empty():
						current_object_group.objects.append(current_object)
						current_object = {}
				"objectgroup":
					result.object_groups.append(current_object_group)
					current_object_group = {}
				"group":
					if not group_stack.is_empty(): group_stack.pop_back()
	return result


static func _parse_tsx(path: String) -> Dictionary:
	var parser := XMLParser.new()
	if parser.open(path) != OK:
		return {}
	var result := {"columns": 0, "tile_count": 0, "tile_width": 32, "tile_height": 32,
		"texture_path": "", "godot_source_id": -1, "atlas_coordinates": {}, "tile_metadata": {}}
	var current_tile_id := -1
	var current_tile_metadata := {}
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "tile" and current_tile_id >= 0:
				if current_tile_metadata.has("godot_atlas_x") and current_tile_metadata.has("godot_atlas_y"):
					result.atlas_coordinates[current_tile_id] = Vector2i(
						int(current_tile_metadata.godot_atlas_x), int(current_tile_metadata.godot_atlas_y))
				result.tile_metadata[current_tile_id] = current_tile_metadata.duplicate(true)
				current_tile_id = -1
				current_tile_metadata = {}
			continue
		if parser.get_node_type() != XMLParser.NODE_ELEMENT:
			continue
		var attrs := _attributes(parser)
		match parser.get_node_name():
			"tileset":
				result.columns = int(attrs.get("columns", 0))
				result.tile_count = int(attrs.get("tilecount", 0))
				result.tile_width = int(attrs.get("tilewidth", 32))
				result.tile_height = int(attrs.get("tileheight", 32))
			"image":
				result.texture_path = path.get_base_dir().path_join(str(attrs.get("source", ""))).simplify_path()
			"tile":
				current_tile_id = int(attrs.get("id", -1))
				current_tile_metadata = {}
				if attrs.has("class"):
					current_tile_metadata["default_role"] = str(attrs["class"])
			"property":
				var property_name := str(attrs.get("name", ""))
				if current_tile_id >= 0:
					current_tile_metadata[property_name] = _property_value(attrs)
				elif property_name == "godot_source_id":
					result.godot_source_id = int(attrs.get("value", -1))
	var has_mapping: bool = int(result.columns) > 0 or not result.atlas_coordinates.is_empty()
	return result if has_mapping and int(result.tile_count) > 0 and int(result.godot_source_id) >= 0 else {}


static func _attributes(parser: XMLParser) -> Dictionary:
	var result := {}
	for index in parser.get_attribute_count():
		result[parser.get_attribute_name(index)] = parser.get_attribute_value(index)
	return result


static func _property_value(attrs: Dictionary) -> Variant:
	var value = attrs.get("value", "")
	match str(attrs.get("type", "string")):
		"bool": return str(value) == "true"
		"int": return int(value)
		"float": return float(value)
		_: return str(value)


static func _parse_points(value: String) -> PackedVector2Array:
	var points := PackedVector2Array()
	for pair in value.split(" ", false):
		var components := pair.split(",", false)
		if components.size() == 2:
			points.append(Vector2(float(components[0]), float(components[1])))
	return points


static func _safe_name(value: String) -> String:
	return value.replace("/", "-").replace(":", "-").strip_edges().to_pascal_case()
