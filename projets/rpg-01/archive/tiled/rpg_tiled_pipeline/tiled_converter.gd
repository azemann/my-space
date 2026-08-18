@tool
class_name RpgTiledConverter
extends RefCounted

const FLIP_H := 0x80000000
const FLIP_V := 0x40000000
const FLIP_D := 0x20000000
const GID_MASK := 0x0fffffff


static func convert_map(source_path: String, profile) -> Error:
	var parsed := _parse_tmx(source_path)
	if parsed.is_empty():
		return ERR_PARSE_ERROR
	var tile_set := _build_tile_set(source_path, parsed)
	if tile_set == null:
		return ERR_CANT_CREATE
	_ensure_directory(profile.GENERATED_TILESETS_DIRECTORY)
	_ensure_directory(profile.GENERATED_LEVELS_DIRECTORY)
	_ensure_directory(profile.GENERATED_SCENES_DIRECTORY)
	var level_id := str(parsed.properties.get("level_id", source_path.get_file().get_basename()))
	var tile_set_path: String = profile.tile_set_path(level_id)
	var save_error := ResourceSaver.save(tile_set, tile_set_path)
	if save_error != OK:
		return save_error
	tile_set = ResourceLoader.load(tile_set_path, "TileSet", ResourceLoader.CACHE_MODE_IGNORE)
	return _build_scene(source_path, parsed, tile_set, profile, profile.level_scene_path(level_id))


static func _ensure_directory(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


static func _build_tile_set(source_path: String, parsed: Dictionary) -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(int(parsed.tile_width), int(parsed.tile_height))
	var runtime: Array[Dictionary] = []
	for definition in parsed.tilesets:
		var tsx_path := source_path.get_base_dir().path_join(str(definition.source)).simplify_path()
		var info := _parse_tsx(tsx_path)
		if info.is_empty():
			push_error("TSX RPG illisible : %s" % tsx_path)
			return null
		var texture := load(str(info.texture_path)) as Texture2D
		if texture == null:
			push_error("Texture Tiled introuvable : %s" % str(info.texture_path))
			return null
		var atlas := TileSetAtlasSource.new()
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(int(info.tile_width), int(info.tile_height))
		# Le TSX d'objets expose toute la planche à Tiled, mais Godot ne crée que
		# les fragments réellement employés par la carte. Cela évite des milliers
		# de cellules transparentes dans la ressource générée.
		var first_gid := int(definition.first_gid)
		var last_gid := first_gid + int(info.tile_count) - 1
		var used_local_ids := {}
		for layer in parsed.layers:
			for raw_gid in layer.data:
				var base_gid := _base_gid(int(raw_gid))
				if base_gid >= first_gid and base_gid <= last_gid:
					used_local_ids[base_gid - first_gid] = true
		var sorted_ids: Array = used_local_ids.keys()
		sorted_ids.sort()
		for tile_id in sorted_ids:
			atlas.create_tile(Vector2i(int(tile_id) % int(info.columns), int(tile_id) / int(info.columns)))
		var source_id := tile_set.get_next_source_id()
		tile_set.add_source(atlas, source_id)
		runtime.append({
			"first_gid": first_gid,
			"last_gid": last_gid,
			"columns": int(info.columns),
			"source_id": source_id,
		})
	parsed["runtime_tilesets"] = runtime
	return tile_set


static func _build_scene(source_path: String, parsed: Dictionary, tile_set: TileSet, profile, target_path: String) -> Error:
	var root := Node2D.new()
	root.name = "World01Generated"
	root.editor_description = "Niveau généré depuis %s. Modifier le TMX, pas cette scène." % source_path
	root.set_meta("source_tmx", source_path)
	root.set_meta("generated_by", "rpg_tiled_pipeline")
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
		node.editor_description = profile.description(str(layer.name))
		node.set_meta("source_tiled_layer", str(layer.name))
		node.set_meta("source_tiled_group", "/".join(layer.group_path))
		_copy_meta(node, layer.properties)
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
		group_node.set_meta("source_tiled_layer", str(object_group.name))
		group_node.set_meta("godot_role", str(object_group.properties.get("godot_role", profile.object_role(str(object_group.name)))))
		_copy_meta(group_node, object_group.properties)
		_add_owned(parent, group_node, root)
		for object in object_group.objects:
			_convert_object(object, group_node, root, str(group_node.get_meta("godot_role")), profile)
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


static func _convert_object(object: Dictionary, parent: Node, owner: Node, role: String, profile) -> void:
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
	elif role == "spawn" or (float(object.get("width", 0.0)) == 0.0 and float(object.get("height", 0.0)) == 0.0):
		var marker := Marker2D.new()
		_configure_node(marker, object, profile)
		_add_owned(parent, marker, owner)
	else:
		var area := Area2D.new()
		_configure_node(area, object, profile)
		area.collision_layer = int(object.properties.get("collision_layer", 4))
		area.collision_mask = int(object.properties.get("collision_mask", 1))
		_add_owned(parent, area, owner)
		_add_rectangle_shape(area, object, owner)


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
	var width := maxf(float(object.get("width", 0.0)), 16.0)
	var height := maxf(float(object.get("height", 0.0)), 16.0)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = Vector2(width, height) * 0.5
	collision.shape = shape
	_add_owned(parent, collision, owner)


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
		return {"source_id": int(definition.source_id), "atlas_coords": Vector2i(local_id % int(definition.columns), local_id / int(definition.columns))}
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
					if parser.is_empty():
						current_object_group.objects.append(current_object)
						current_object = {}
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
	var result := {"columns": 0, "tile_count": 0, "tile_width": 32, "tile_height": 32, "texture_path": ""}
	while parser.read() == OK:
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
	return result if int(result.columns) > 0 and int(result.tile_count) > 0 and not str(result.texture_path).is_empty() else {}


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


static func _safe_name(value: String) -> String:
	return value.replace("/", "-").replace(":", "-").strip_edges().to_pascal_case()
