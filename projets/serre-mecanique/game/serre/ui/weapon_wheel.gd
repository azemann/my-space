class_name WeaponWheel
extends Control

signal weapon_chosen(index: int)
signal weapon_highlighted(index: int)

## Nombre de secteurs visibles. Augmenter offre plus de places mais réduit l'espace disponible pour chaque icône.
@export_range(4, 12) var slot_count := 8
## Rayon du trou central en pixels. Augmenter éloigne les secteurs du centre et réduit leur surface utile.
@export var inner_radius := 82.0
## Rayon extérieur de la roue en pixels. Il doit rester inférieur à la moitié de la taille du contrôle.
@export var outer_radius := 222.0
## Distance entre le centre et les icônes. À régler entre Inner Radius et Outer Radius.
@export var icon_radius := 153.0
## Taille d'affichage des icônes. Elle ne modifie pas le visuel de l'arme tenue par le personnage.
@export var icon_size := Vector2(54, 54)

var inventory: Array[Resource] = []
var equipped_index := -1
var highlighted_index := -1

const COLOR_EMPTY := Color(0.055, 0.105, 0.106, 0.96)
const COLOR_AVAILABLE := Color(0.09, 0.18, 0.17, 0.98)
const COLOR_HOVER := Color(0.18, 0.34, 0.29, 1.0)
const COLOR_EQUIPPED := Color(0.49, 0.31, 0.13, 1.0)
const COLOR_HOVER_EQUIPPED := Color(0.76, 0.5, 0.2, 1.0)
const COLOR_BORDER := Color(0.69, 0.49, 0.24, 1.0)
const COLOR_EMPTY_MARK := Color(0.29, 0.39, 0.37, 0.8)
const COLOR_TEXT := Color(0.88, 0.76, 0.5, 1.0)


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false
	queue_redraw()


func set_inventory(definitions: Array[Resource], selected_index: int) -> void:
	inventory = definitions.duplicate()
	slot_count = maxi(slot_count, inventory.size())
	equipped_index = selected_index if selected_index < inventory.size() else -1
	set_highlighted_index(equipped_index)
	queue_redraw()


func set_equipped_index(index: int) -> void:
	equipped_index = index if index >= 0 and index < inventory.size() else -1
	queue_redraw()


func set_highlighted_index(index: int) -> void:
	var next_index := index if index >= 0 and index < slot_count else -1
	if highlighted_index == next_index:
		return
	highlighted_index = next_index
	weapon_highlighted.emit(highlighted_index)
	queue_redraw()


func highlighted_definition() -> Resource:
	if highlighted_index < 0 or highlighted_index >= inventory.size():
		return null
	return inventory[highlighted_index]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		set_highlighted_index(_slot_at_position(event.position))
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		set_highlighted_index(_slot_at_position(event.position))
		if event.pressed and highlighted_index >= 0 and highlighted_index < inventory.size():
			weapon_chosen.emit(highlighted_index)
		accept_event()
	elif event.is_action_pressed(&"ui_left", false):
		_move_highlight(-1)
		accept_event()
	elif event.is_action_pressed(&"ui_right", false):
		_move_highlight(1)
		accept_event()
	elif event.is_action_pressed(&"ui_accept", false):
		if highlighted_index >= 0 and highlighted_index < inventory.size():
			weapon_chosen.emit(highlighted_index)
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		set_highlighted_index(equipped_index)


func _move_highlight(step: int) -> void:
	if inventory.is_empty():
		set_highlighted_index(-1)
		return
	var start := highlighted_index if highlighted_index >= 0 else equipped_index
	if start < 0:
		start = 0
	set_highlighted_index(posmod(start + step, inventory.size()))


func _slot_at_position(position: Vector2) -> int:
	var offset := position - size * 0.5
	var distance := offset.length()
	if distance < inner_radius or distance > outer_radius:
		return -1
	var sector_angle := TAU / float(slot_count)
	var normalized := fposmod(offset.angle() + PI * 0.5 + sector_angle * 0.5, TAU)
	return floori(normalized / sector_angle)


func _draw() -> void:
	var center := size * 0.5
	var sector_angle := TAU / float(slot_count)
	for slot in slot_count:
		var middle := -PI * 0.5 + slot * sector_angle
		var start := middle - sector_angle * 0.5
		var finish := middle + sector_angle * 0.5
		var color := _sector_color(slot)
		var polygon := _sector_polygon(center, start, finish)
		draw_colored_polygon(polygon, color)
		var outline := polygon.duplicate()
		outline.append(polygon[0])
		draw_polyline(outline, COLOR_BORDER, 2.0, true)
		var marker_position := center + Vector2.from_angle(middle) * icon_radius
		_draw_slot_content(slot, marker_position)

	draw_circle(center, inner_radius - 5.0, Color(0.025, 0.065, 0.067, 1.0))
	draw_arc(center, inner_radius - 5.0, 0.0, TAU, 64, COLOR_BORDER, 3.0, true)
	draw_circle(center, 8.0, COLOR_EQUIPPED)


func _sector_polygon(center: Vector2, start: float, finish: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	const STEPS := 8
	for step in STEPS + 1:
		var angle := lerpf(start, finish, float(step) / STEPS)
		points.append(center + Vector2.from_angle(angle) * outer_radius)
	for step in STEPS + 1:
		var angle := lerpf(finish, start, float(step) / STEPS)
		points.append(center + Vector2.from_angle(angle) * inner_radius)
	return points


func _sector_color(slot: int) -> Color:
	var available := slot < inventory.size()
	var hovered := slot == highlighted_index
	var equipped := slot == equipped_index
	if hovered and equipped:
		return COLOR_HOVER_EQUIPPED
	if equipped:
		return COLOR_EQUIPPED
	if hovered and available:
		return COLOR_HOVER
	return COLOR_AVAILABLE if available else COLOR_EMPTY


func _draw_slot_content(slot: int, position: Vector2) -> void:
	if slot < inventory.size():
		var definition := inventory[slot]
		var icon := definition.get("selection_icon") as Texture2D
		if icon == null:
			icon = definition.get("texture") as Texture2D
		if icon:
			var rect := Rect2(position - icon_size * 0.5, icon_size)
			draw_texture_rect(icon, rect, false)
		var ammo := int(definition.get("ammo_count"))
		var amount := "∞" if ammo < 0 else str(ammo)
		draw_string(
			ThemeDB.fallback_font,
			position + Vector2(-8, icon_size.y * 0.5 + 17),
			amount,
			HORIZONTAL_ALIGNMENT_CENTER,
			16,
			14,
			COLOR_TEXT
		)
	else:
		draw_circle(position, 17.0, COLOR_EMPTY_MARK, false, 2.0, true)
		draw_line(position + Vector2(-7, 0), position + Vector2(7, 0), COLOR_EMPTY_MARK, 2.0, true)
	draw_string(
		ThemeDB.fallback_font,
		position + Vector2(-6, -icon_size.y * 0.5 - 8),
		str(slot + 1),
		HORIZONTAL_ALIGNMENT_CENTER,
		12,
		12,
		COLOR_TEXT
	)
