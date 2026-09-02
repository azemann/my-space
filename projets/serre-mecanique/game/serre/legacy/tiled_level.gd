extends Node2D

@export_file("*.tmx") var tmx_path := "res://maps/niveau-01-serre.tmx"

var player_spawn := Vector2(64, 640)
var player: CharacterBody2D
var _tileset_texture: Texture2D
var _columns := 16
var _tile_size := Vector2i(32, 32)
var _current_group := ""
var _layer_counter := 0


func _ready() -> void:
	_tileset_texture = load("res://assets/tilesets/serre-mecanique-32x32.png")
	_load_tmx(tmx_path)


func _load_tmx(path: String) -> void:
	var parser := XMLParser.new()
	var error := parser.open(path)
	if error != OK:
		push_error("Impossible d'ouvrir la carte Tiled: %s" % path)
		return

	var current_layer: Dictionary = {}
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
				_tile_size = Vector2i(int(attrs.get("tilewidth", 32)), int(attrs.get("tileheight", 32)))
			elif node_name == "layer":
				current_layer = attrs
				_layer_counter += 1
			elif node_name == "data":
				reading_data = true
				data_buffer = ""
			elif node_name == "objectgroup":
				_current_group = str(attrs.get("name", ""))
			elif node_name == "object":
				_process_object(attrs)
		elif node_type == XMLParser.NODE_TEXT and reading_data:
			data_buffer += parser.get_node_data()
		elif node_type == XMLParser.NODE_ELEMENT_END:
			if node_name == "data":
				reading_data = false
				_render_layer(current_layer, data_buffer, _layer_counter)
			elif node_name == "objectgroup":
				_current_group = ""


func _attributes(parser: XMLParser) -> Dictionary:
	var result := {}
	for index in parser.get_attribute_count():
		result[parser.get_attribute_name(index)] = parser.get_attribute_value(index)
	return result


func _render_layer(layer: Dictionary, csv: String, order: int) -> void:
	var width := int(layer.get("width", 0))
	if width <= 0:
		return
	var opacity := float(layer.get("opacity", 1.0))
	var container := Node2D.new()
	container.name = str(layer.get("name", "Calque_%d" % order)).replace("/", "_")
	container.z_index = order
	container.modulate.a = opacity
	add_child(container)

	var values := csv.replace("\n", "").split(",", false)
	for index in values.size():
		var gid := int(values[index].strip_edges())
		if gid <= 0:
			continue
		var tile_id := gid - 1
		var atlas := AtlasTexture.new()
		atlas.atlas = _tileset_texture
		atlas.region = Rect2(
			(tile_id % _columns) * _tile_size.x,
			floori(tile_id / float(_columns)) * _tile_size.y,
			_tile_size.x,
			_tile_size.y
		)
		var sprite := Sprite2D.new()
		sprite.texture = atlas
		sprite.position = Vector2(
			(index % width) * _tile_size.x + _tile_size.x * 0.5,
			floori(index / float(width)) * _tile_size.y + _tile_size.y * 0.5
		)
		container.add_child(sprite)


func _process_object(attrs: Dictionary) -> void:
	var kind := str(attrs.get("type", ""))
	var name := str(attrs.get("name", kind))
	var x := float(attrs.get("x", 0.0))
	var y := float(attrs.get("y", 0.0))
	var width := float(attrs.get("width", 0.0))
	var height := float(attrs.get("height", 0.0))

	if _current_group == "Collisions":
		if kind in ["solid", "one_way"]:
			_add_static_collision(name, kind, Rect2(x, y, width, height))
		elif kind in ["hazard", "bounce"]:
			_add_gameplay_area(name, kind, Rect2(x, y, width, height))
	elif _current_group == "Entités et interactions":
		if kind == "player_spawn":
			player_spawn = Vector2(x, y)
		elif kind == "checkpoint":
			_add_gameplay_area(name, kind, Rect2(x - 12, y - 24, 24, 24))
		elif kind == "exit":
			_add_gameplay_area(name, kind, Rect2(x, y, width, height))


func _add_static_collision(node_name: String, kind: String, area: Rect2) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = area.position + area.size * 0.5
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = area.size
	collision.shape = shape
	if kind == "one_way":
		collision.one_way_collision = true
		collision.one_way_collision_margin = 3.0
	body.add_child(collision)
	add_child(body)


func _add_gameplay_area(node_name: String, kind: String, area_rect: Rect2) -> void:
	var area := Area2D.new()
	area.name = node_name
	area.collision_layer = 2 if kind == "hazard" else 4
	area.collision_mask = 1
	area.position = area_rect.position + area_rect.size * 0.5
	area.set_meta("kind", kind)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = area_rect.size
	collision.shape = shape
	area.add_child(collision)
	area.body_entered.connect(_on_area_entered.bind(area))
	add_child(area)


func _on_area_entered(body: Node2D, area: Area2D) -> void:
	if body != player:
		return
	match str(area.get_meta("kind")):
		"hazard":
			player.respawn()
		"bounce":
			player.bounce()
		"checkpoint":
			player.spawn_point = area.global_position + Vector2(0, -24)
		"exit":
			print("Niveau terminé — sortie de la serre atteinte.")
