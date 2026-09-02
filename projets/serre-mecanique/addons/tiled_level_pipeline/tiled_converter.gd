@tool
extends RefCounted

static func convert_all(profile) -> Error:
	_ensure_directory(profile.tile_sets_directory())
	_ensure_directory(profile.level_resources_directory())
	_ensure_directory(profile.level_scenes_directory())

	var maps_directory: String = profile.maps_directory()
	var map_files := DirAccess.get_files_at(maps_directory)
	var jobs: Array[Dictionary] = []
	# Première passe sans écriture : un TMX ou TSX invalide ne doit jamais
	# laisser seulement une partie des niveaux régénérée.
	for file_name in map_files:
		if file_name.get_extension().to_lower() != "tmx":
			continue
		var level_id := file_name.get_basename()
		if profile.is_level_frozen(level_id):
			print("Niveau figé ignoré par l'import Tiled: %s" % level_id)
			continue
		var source_path: String = maps_directory.path_join(file_name)
		var parsed := _parse_tmx(source_path)
		if parsed.is_empty():
			return ERR_PARSE_ERROR
		var tile_set := _build_map_tile_set(source_path, parsed, profile)
		if tile_set == null:
			return ERR_CANT_OPEN
		var validation_error := _validate_parsed_map(source_path, parsed)
		if validation_error != OK:
			return validation_error
		jobs.append({
			"level_id": level_id,
			"source_path": source_path,
			"parsed": parsed,
			"tile_set": tile_set,
		})

	# Deuxième passe : tous les fichiers d'entrée sont désormais validés.
	for job in jobs:
		var level_id := str(job.level_id)
		var source_path := str(job.source_path)
		var parsed: Dictionary = job.parsed
		var tile_set: TileSet = job.tile_set
		var tile_set_path: String = profile.tile_set_path(level_id)
		var save_error := ResourceSaver.save(tile_set, tile_set_path)
		if save_error != OK:
			return save_error
		tile_set = ResourceLoader.load(tile_set_path, "TileSet", ResourceLoader.CACHE_MODE_IGNORE)
		var target_path: String = profile.level_scene_path(level_id)
		var result := _convert_map(source_path, target_path, tile_set, parsed, profile)
		if result != OK:
			return result
	return OK


static func _ensure_directory(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


static func _build_tile_set(texture_path: String, columns: int, rows: int, tile_size: Vector2i) -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = tile_size
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(texture_path)
	if atlas.texture == null:
		return null
	atlas.texture_region_size = tile_size
	for y in range(rows):
		for x in range(columns):
			atlas.create_tile(Vector2i(x, y))
	tile_set.add_source(atlas, 0)
	return tile_set


static func _build_map_tile_set(source_path: String, parsed: Dictionary, profile) -> TileSet:
	var definitions: Array = parsed.get("tilesets", [])
	if definitions.is_empty():
		var fallback := _build_tile_set(
			profile.fallback_tileset_texture(),
			profile.fallback_tileset_columns(),
			profile.fallback_tileset_rows(),
			profile.fallback_tile_size()
		)
		parsed.tilesets_runtime = [{
			"first_gid": 1,
			"last_gid": profile.fallback_tileset_columns() * profile.fallback_tileset_rows(),
			"source_id": 0,
			"columns": profile.fallback_tileset_columns(),
			"tile_count": profile.fallback_tileset_columns() * profile.fallback_tileset_rows(),
			"texture_path": profile.fallback_tileset_texture(),
		}]
		return fallback

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(int(parsed.tile_width), int(parsed.tile_height))
	var runtime_definitions: Array[Dictionary] = []
	for definition in definitions:
		var tsx_source := str(definition.get("source", ""))
		var tsx_path := source_path.get_base_dir().path_join(tsx_source).simplify_path()
		var info := _parse_external_tileset(tsx_path)
		if info.is_empty():
			push_error("Impossible de lire le tileset externe: %s" % tsx_path)
			return null
		var texture := load(str(info.texture_path)) as Texture2D
		if texture == null:
			push_error("Impossible de charger l'image du tileset: %s" % str(info.texture_path))
			return null
		var atlas := TileSetAtlasSource.new()
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(int(info.tile_width), int(info.tile_height))
		for tile_index in int(info.tile_count):
			atlas.create_tile(Vector2i(tile_index % int(info.columns), tile_index / int(info.columns)))
		var source_id := tile_set.get_next_source_id()
		tile_set.add_source(atlas, source_id)
		var first_gid := int(definition.get("first_gid", 1))
		runtime_definitions.append({
			"first_gid": first_gid,
			"last_gid": first_gid + int(info.tile_count) - 1,
			"source_id": source_id,
			"columns": int(info.columns),
			"tile_count": int(info.tile_count),
			"tsx_path": tsx_path,
			"texture_path": str(info.texture_path),
		})
	parsed.tilesets_runtime = runtime_definitions
	return tile_set


static func _convert_map(
	source_path: String,
	target_path: String,
	tile_set: TileSet,
	parsed: Dictionary,
	profile
) -> Error:
	var validation_error := _validate_parsed_map(source_path, parsed)
	if validation_error != OK:
		return validation_error

	var root := Node2D.new()
	root.name = _pascal_name(source_path.get_file().get_basename())
	root.set_script(profile.level_script())

	var definition = profile.create_level_definition()
	definition.level_id = source_path.get_file().get_basename()
	definition.display_name = str(parsed.get("level_name", ""))
	if definition.display_name.is_empty():
		definition.display_name = root.name
	definition.source_tmx = source_path
	definition.map_size_tiles = Vector2i(parsed.width, parsed.height)
	definition.tile_size = Vector2i(parsed.tile_width, parsed.tile_height)
	definition.camera_limits = Rect2i(0, 0, parsed.width * parsed.tile_width, parsed.height * parsed.tile_height)
	root.set("definition", definition)
	_copy_properties_to_meta(root, parsed.properties)

	var layers_root := Node2D.new()
	layers_root.name = "CalquesTuiles"
	_add_owned(root, layers_root, root)
	var layer_order := 0
	for layer in parsed.layers:
		layer_order += 1
		var tile_layer := TileMapLayer.new()
		tile_layer.name = _safe_node_name(str(layer.name))
		tile_layer.tile_set = tile_set
		tile_layer.position = Vector2(float(layer.offset_x), float(layer.offset_y))
		tile_layer.z_index = int(layer.properties.get("z_index", layer_order))
		tile_layer.y_sort_enabled = bool(layer.properties.get("y_sort", false))
		tile_layer.visible = bool(layer.visible)
		tile_layer.modulate.a = float(layer.opacity)
		tile_layer.set_meta("source_tiled_layer", str(layer.name))
		tile_layer.set_meta("parallax", Vector2(float(layer.parallax_x), float(layer.parallax_y)))
		_copy_properties_to_meta(tile_layer, layer.properties)
		_add_owned(layers_root, tile_layer, root)
		for index in layer.data.size():
			var gid := int(layer.data[index])
			if gid <= 0:
				continue
			var resolved := _resolve_gid(gid, parsed)
			if resolved.is_empty():
				push_error(
					"GID Tiled %d introuvable dans le calque '%s' de %s."
					% [_base_gid(gid), str(layer.name), source_path]
				)
				root.free()
				return ERR_INVALID_DATA
			var coords := Vector2i(index % int(layer.width), floori(index / float(layer.width)))
			tile_layer.set_cell(
				coords,
				int(resolved.source_id),
				resolved.atlas_coords,
				_tiled_alternative_tile(gid)
			)

	var object_layers_root := Node2D.new()
	object_layers_root.name = "CalquesObjets"
	_add_owned(root, object_layers_root, root)
	for group in parsed.object_groups:
		var group_node := Node2D.new()
		group_node.name = _safe_node_name(str(group.name))
		group_node.position = Vector2(float(group.offset_x), float(group.offset_y))
		group_node.visible = bool(group.visible)
		group_node.modulate.a = float(group.opacity)
		group_node.z_index = int(group.properties.get("z_index", 0))
		group_node.y_sort_enabled = bool(group.properties.get("y_sort", false))
		group_node.set_meta("source_tiled_layer", str(group.name))
		group_node.set_meta("color", str(group.color))
		_copy_properties_to_meta(group_node, group.properties)
		_add_owned(object_layers_root, group_node, root)
		var role := _object_group_role(group)
		for object in group.objects:
			_convert_object(object, group_node, root, role, definition, profile)

	var definition_path: String = profile.level_resource_path(source_path.get_file().get_basename())
	var definition_error := ResourceSaver.save(definition, definition_path)
	if definition_error != OK:
		root.free()
		return definition_error
	root.set("definition", load(definition_path))

	var packed := PackedScene.new()
	var pack_error := packed.pack(root)
	if pack_error != OK:
		root.free()
		return pack_error
	var scene_error := ResourceSaver.save(packed, target_path)
	root.free()
	return scene_error


static func _convert_object(
	object: Dictionary,
	parent: Node,
	owner: Node,
	group_role: String,
	definition,
	profile
) -> void:
	var kind := _object_kind(object)
	var has_registered_scene: bool = profile.has_object_scene(kind)
	if kind in ["solid", "one_way", "slope", "wall", "grapple_surface"]:
		_create_static_collision(object, parent, owner, kind == "one_way", profile)
	elif group_role == "collision" and not has_registered_scene:
		_create_static_collision(object, parent, owner, false, profile)
	elif kind == "player_spawn":
		var marker := Marker2D.new()
		_configure_object_node(marker, object)
		marker.name = "PlayerSpawn"
		marker.set_meta("kind", "player_spawn")
		definition.player_spawn = marker.position
		_add_owned(parent, marker, owner)
	elif has_registered_scene:
		_create_registered_object(object, parent, owner, kind, profile)
	elif group_role in ["zone", "camera", "audio"]:
		_convert_zone_object(object, parent, owner)
	else:
		_create_marker_or_area(object, parent, owner, kind)


static func _create_registered_object(
	object: Dictionary,
	parent: Node,
	owner: Node,
	kind: String,
	profile
) -> Node2D:
	var instance := profile.instantiate_object(kind) as Node2D
	if instance == null:
		return null
	_configure_object_node(instance, object)
	instance.set_meta("kind", kind)
	instance.set_meta("object_scene", profile.object_scene_path(kind))
	_add_owned(parent, instance, owner)
	if instance is Area2D:
		var area := instance as Area2D
		area.collision_layer = int(object.properties.get("collision_layer", area.collision_layer))
		area.collision_mask = int(object.properties.get("collision_mask", area.collision_mask))
		_add_collision_geometry(area, object, owner)
		profile.postprocess_registered_object(kind, area)
	return instance


static func _create_static_collision(object: Dictionary, parent: Node, owner: Node, one_way: bool, profile) -> void:
	var body := StaticBody2D.new()
	_configure_object_node(body, object)
	body.collision_layer = int(object.properties.get("collision_layer", 1))
	body.collision_mask = int(object.properties.get("collision_mask", 1))
	body.physics_material_override = profile.ground_material()
	_add_owned(parent, body, owner)
	var collisions := _add_collision_geometry(body, object, owner)
	for collision in collisions:
		if "one_way_collision" in collision:
			collision.one_way_collision = one_way
			collision.one_way_collision_margin = float(object.properties.get("one_way_margin", 3.0))


static func _convert_zone_object(object: Dictionary, parent: Node, owner: Node) -> void:
	var area := _create_plain_area(object, parent, owner)
	area.monitoring = bool(object.properties.get("monitoring", false))
	area.monitorable = bool(object.properties.get("monitorable", false))
	area.set_meta("kind", _object_kind(object))


static func _create_plain_area(object: Dictionary, parent: Node, owner: Node) -> Area2D:
	var area := Area2D.new()
	_configure_object_node(area, object)
	area.collision_layer = int(object.properties.get("collision_layer", 4))
	area.collision_mask = int(object.properties.get("collision_mask", 1))
	_add_owned(parent, area, owner)
	_add_collision_geometry(area, object, owner)
	return area


static func _create_marker_or_area(
	object: Dictionary,
	parent: Node,
	owner: Node,
	kind: String
) -> void:
	if str(object.get("shape", "rectangle")) == "point":
		var marker := Marker2D.new()
		_configure_object_node(marker, object)
		marker.set_meta("kind", kind)
		_add_owned(parent, marker, owner)
		return
	var area := _create_plain_area(object, parent, owner)
	area.set_meta("kind", kind)


static func _configure_object_node(node: Node2D, object: Dictionary) -> void:
	node.name = _safe_node_name(str(object.get("name", _object_kind(object))))
	node.position = Vector2(float(object.get("x", 0.0)), float(object.get("y", 0.0)))
	node.rotation_degrees = float(object.get("rotation", 0.0))
	node.visible = int(object.get("visible", 1)) != 0
	node.z_index = int(object.properties.get("z_index", 0))
	node.set_meta("tiled_id", int(object.get("id", 0)))
	node.set_meta("tiled_type", _object_kind(object))
	node.set_meta("tiled_shape", str(object.get("shape", "rectangle")))
	_copy_properties_to_meta(node, object.properties)


static func _add_collision_geometry(parent: Node2D, object: Dictionary, owner: Node) -> Array[Node]:
	var result: Array[Node] = []
	var shape_kind := str(object.get("shape", "rectangle"))
	var width := float(object.get("width", 0.0))
	var height := float(object.get("height", 0.0))
	if shape_kind == "polygon" or shape_kind == "ellipse":
		var polygon := CollisionPolygon2D.new()
		polygon.name = "CollisionPolygon2D"
		polygon.polygon = _object_polygon(object)
		_add_owned(parent, polygon, owner)
		result.append(polygon)
	elif shape_kind == "polyline":
		var points: PackedVector2Array = object.get("points", PackedVector2Array())
		for index in range(points.size() - 1):
			var segment_shape := SegmentShape2D.new()
			segment_shape.a = points[index]
			segment_shape.b = points[index + 1]
			var segment := CollisionShape2D.new()
			segment.name = "Segment%02d" % (index + 1)
			segment.shape = segment_shape
			_add_owned(parent, segment, owner)
			result.append(segment)
	elif shape_kind == "point" or width <= 0.0 or height <= 0.0:
		width = float(object.properties.get("trigger_width", 20.0))
		height = float(object.properties.get("trigger_height", 20.0))
		var point_collision := _rectangle_shape(Vector2(width, height))
		point_collision.position = Vector2(0, -height * 0.5)
		_add_owned(parent, point_collision, owner)
		result.append(point_collision)
	else:
		var collision := _rectangle_shape(Vector2(width, height))
		collision.position = Vector2(width, height) * 0.5
		collision.disabled = not bool(object.properties.get("enabled", true))
		_add_owned(parent, collision, owner)
		result.append(collision)
	return result


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


static func _rectangle_shape(size: Vector2) -> CollisionShape2D:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = shape
	return collision


static func _add_owned(parent: Node, child: Node, owner: Node) -> void:
	parent.add_child(child)
	child.owner = owner


static func _copy_properties_to_meta(node: Node, values: Dictionary) -> void:
	for key in values:
		node.set_meta(str(key), values[key])


static func _object_kind(object: Dictionary) -> String:
	return str(object.get("class", object.get("type", "")))


static func _object_rect(object: Dictionary) -> Rect2:
	return Rect2(
		float(object.get("x", 0.0)),
		float(object.get("y", 0.0)),
		float(object.get("width", 0.0)),
		float(object.get("height", 0.0))
	)


static func _object_group_role(group: Dictionary) -> String:
	var configured := str(group.properties.get("godot_role", "")).to_lower()
	if not configured.is_empty():
		return configured
	var normalized := str(group.name).to_lower()
	if "collision" in normalized:
		return "collision"
	if "zone" in normalized or "déclencheur" in normalized or "trigger" in normalized:
		return "zone"
	if "camera" in normalized or "caméra" in normalized:
		return "camera"
	if "audio" in normalized or "ambiance" in normalized:
		return "audio"
	if "entit" in normalized or "interaction" in normalized or "gameplay" in normalized:
		return "gameplay"
	return "object"


static func _base_gid(gid: int) -> int:
	# Tiled réserve les quatre bits hauts aux transformations de la tuile.
	return gid & 0x0fffffff


static func _resolve_gid(gid: int, parsed: Dictionary) -> Dictionary:
	var base_gid := _base_gid(gid)
	for definition in parsed.get("tilesets_runtime", []):
		if base_gid < int(definition.first_gid) or base_gid > int(definition.last_gid):
			continue
		var local_id := base_gid - int(definition.first_gid)
		var columns := int(definition.columns)
		return {
			"source_id": int(definition.source_id),
			"local_id": local_id,
			"atlas_coords": Vector2i(local_id % columns, floori(float(local_id) / columns)),
		}
	return {}


static func _tiled_alternative_tile(gid: int) -> int:
	var alternative := 0
	if (gid & 0x80000000) != 0:
		alternative |= TileSetAtlasSource.TRANSFORM_FLIP_H
	if (gid & 0x40000000) != 0:
		alternative |= TileSetAtlasSource.TRANSFORM_FLIP_V
	if (gid & 0x20000000) != 0:
		alternative |= TileSetAtlasSource.TRANSFORM_TRANSPOSE
	return alternative


static func _validate_parsed_map(source_path: String, parsed: Dictionary) -> Error:
	var layer_names := {}
	var layer_ids := {}
	for layer in parsed.get("layers", []):
		var layer_name := str(layer.name)
		var layer_id := int(layer.get("id", 0))
		if layer_names.has(layer_name):
			push_error("Deux calques de tuiles portent le nom '%s' dans %s." % [layer_name, source_path])
			return ERR_INVALID_DATA
		if layer_id > 0 and layer_ids.has(layer_id):
			push_error("L'identifiant de calque Tiled %d est dupliqué dans %s." % [layer_id, source_path])
			return ERR_INVALID_DATA
		layer_names[layer_name] = true
		layer_ids[layer_id] = true
		for gid in layer.data:
			if int(gid) > 0 and _resolve_gid(int(gid), parsed).is_empty():
				push_error(
					"Le GID %d du calque '%s' ne correspond à aucun tileset dans %s."
					% [_base_gid(int(gid)), layer_name, source_path]
				)
				return ERR_INVALID_DATA
	return OK


static func _parse_tmx(path: String) -> Dictionary:
	var parser := XMLParser.new()
	if parser.open(path) != OK:
		return {}
	var result := {
		"layers": [],
		"object_groups": [],
		"properties": {},
		"width": 0,
		"height": 0,
		"tile_width": 32,
		"tile_height": 32,
		"tileset_source": "",
		"tilesets": [],
	}
	var current_layer: Dictionary = {}
	var current_group: Dictionary = {}
	var current_object: Dictionary = {}
	var data_buffer := ""
	var reading_data := false
	while parser.read() == OK:
		var node_type := parser.get_node_type()
		var node_name := ""
		if node_type in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END]:
			node_name = parser.get_node_name()
		if node_type == XMLParser.NODE_ELEMENT:
			var attrs := _attributes(parser)
			if node_name == "map":
				result.width = int(attrs.get("width", 0))
				result.height = int(attrs.get("height", 0))
				result.tile_width = int(attrs.get("tilewidth", 32))
				result.tile_height = int(attrs.get("tileheight", 32))
			elif node_name == "tileset" and attrs.has("source"):
				var tileset_definition := {
					"first_gid": int(attrs.get("firstgid", 1)),
					"source": str(attrs.source),
				}
				result.tilesets.append(tileset_definition)
				# Compatibilité avec les profils et contrôles historiques : cette
				# valeur désigne le tileset principal, donc le premier du TMX.
				if str(result.tileset_source).is_empty():
					result.tileset_source = str(attrs.source)
			elif node_name == "layer":
				current_layer = {
					"id": int(attrs.get("id", 0)),
					"name": attrs.get("name", "Calque"),
					"width": int(attrs.get("width", result.width)),
					"height": int(attrs.get("height", result.height)),
					"opacity": float(attrs.get("opacity", 1.0)),
					"visible": int(attrs.get("visible", 1)) != 0,
					"parallax_x": float(attrs.get("parallaxx", 1.0)),
					"parallax_y": float(attrs.get("parallaxy", 1.0)),
					"offset_x": float(attrs.get("offsetx", 0.0)),
					"offset_y": float(attrs.get("offsety", 0.0)),
					"properties": {},
					"data": [],
				}
			elif node_name == "data":
				reading_data = true
				data_buffer = ""
			elif node_name == "objectgroup":
				current_group = {
					"name": str(attrs.get("name", "Objets")),
					"visible": int(attrs.get("visible", 1)) != 0,
					"opacity": float(attrs.get("opacity", 1.0)),
					"offset_x": float(attrs.get("offsetx", 0.0)),
					"offset_y": float(attrs.get("offsety", 0.0)),
					"color": str(attrs.get("color", "")),
					"properties": {},
					"objects": [],
				}
			elif node_name == "object":
				current_object = attrs
				current_object["properties"] = {}
				current_object["shape"] = "rectangle"
				current_object["points"] = PackedVector2Array()
				if parser.is_empty():
					current_group.objects.append(current_object)
					current_object = {}
			elif node_name in ["point", "ellipse"] and not current_object.is_empty():
				current_object.shape = node_name
			elif node_name in ["polygon", "polyline"] and not current_object.is_empty():
				current_object.shape = node_name
				current_object.points = _parse_points(str(attrs.get("points", "")))
			elif node_name == "property":
				var property_name := str(attrs.get("name", "property"))
				var property_value := _property_value(attrs)
				if not current_object.is_empty():
					current_object.properties[property_name] = property_value
				elif not current_group.is_empty():
					current_group.properties[property_name] = property_value
				elif not current_layer.is_empty():
					current_layer.properties[property_name] = property_value
				else:
					result.properties[property_name] = property_value
		elif node_type == XMLParser.NODE_TEXT and reading_data:
			data_buffer += parser.get_node_data()
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if node_name == "data":
				reading_data = false
				var clean := data_buffer.replace("\n", "").replace("\r", "")
				var values := clean.split(",", false)
				current_layer.data = Array(values).map(func(value): return int(str(value).strip_edges()))
				result.layers.append(current_layer)
				current_layer = {}
			elif node_name == "object" and not current_object.is_empty():
				current_group.objects.append(current_object)
				current_object = {}
			elif node_name == "objectgroup":
				result.object_groups.append(current_group)
				current_group = {}
	result.level_name = str(result.properties.get("level_name", ""))
	return result


static func _parse_points(value: String) -> PackedVector2Array:
	var result := PackedVector2Array()
	for pair in value.split(" ", false):
		var coordinates := pair.split(",", false)
		if coordinates.size() == 2:
			result.append(Vector2(float(coordinates[0]), float(coordinates[1])))
	return result


static func _parse_external_tileset(path: String) -> Dictionary:
	var parser := XMLParser.new()
	if parser.open(path) != OK:
		return {}
	var result := {
		"columns": 0,
		"tile_count": 0,
		"tile_width": 32,
		"tile_height": 32,
		"texture_path": "",
	}
	while parser.read() == OK:
		if parser.get_node_type() != XMLParser.NODE_ELEMENT:
			continue
		var node_name := parser.get_node_name()
		var attrs := _attributes(parser)
		if node_name == "tileset":
			result.columns = int(attrs.get("columns", 0))
			result.tile_count = int(attrs.get("tilecount", 0))
			result.tile_width = int(attrs.get("tilewidth", 32))
			result.tile_height = int(attrs.get("tileheight", 32))
		elif node_name == "image":
			var image_source := str(attrs.get("source", ""))
			result.texture_path = path.get_base_dir().path_join(image_source).simplify_path()
	if int(result.columns) <= 0 or str(result.texture_path).is_empty():
		return {}
	result.rows = ceili(float(result.tile_count) / float(result.columns))
	return result


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


static func _safe_node_name(value: String) -> String:
	return value.replace("/", "-").replace(":", "-").strip_edges().to_pascal_case()


static func _pascal_name(value: String) -> String:
	return _safe_node_name(value.replace("-", " "))
