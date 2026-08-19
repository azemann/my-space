@tool
class_name InventoryPanel
extends Control

## Vue persistante du sac. Elle observe InventoryComponent, construit une grille
## navigable et ne modifie jamais directement les piles du modèle.

## Émis après l'ouverture ou la fermeture effective du panneau.
signal open_changed(is_open: bool)

## Ressource centrale des marges, colonnes, dimensions, couleurs et textes.
@export var config: InventoryUIConfig

@onready var grid: GridContainer = %SlotGrid
@onready var item_name_label: Label = %ItemName
@onready var description_label: Label = %Description
@onready var capacity_label: Label = %Capacity
@onready var dimmer: ColorRect = $Dimmer
@onready var margin: MarginContainer = $Margin
@onready var panel_background: TextureRect = $Margin/Background
@onready var content_margin: MarginContainer = $Margin/Panel/ContentMargin
@onready var rows: VBoxContainer = $Margin/Panel/ContentMargin/Rows
@onready var title_label: Label = $Margin/Panel/ContentMargin/Rows/Header/Title

var inventory: InventoryComponent
var selected_slot := -1
var _slot_buttons: Array[Button] = []


func _ready() -> void:
	get_viewport().size_changed.connect(_resize_to_viewport)
	if config != null and not config.changed.is_connected(_apply_config):
		config.changed.connect(_apply_config)
	_resize_to_viewport()
	_apply_config()
	if not Engine.is_editor_hint():
		hide()


## Branche la vue sur l'inventaire persistant à représenter.
func set_inventory(next_inventory: InventoryComponent) -> void:
	if inventory != null and inventory.changed.is_connected(_refresh):
		inventory.changed.disconnect(_refresh)
	inventory = next_inventory
	if inventory != null:
		inventory.changed.connect(_refresh)
	_refresh()


## Ouvre ou ferme le panneau et place le focus sur un emplacement accessible.
func set_open(open: bool) -> void:
	if visible == open:
		return
	visible = open
	if open:
		_refresh()
		_focus_preferred_slot()
	open_changed.emit(open)


## Bascule l'état d'ouverture du panneau.
func toggle() -> void:
	set_open(not visible)


## Indique si l'inventaire occupe actuellement l'interface.
func is_open() -> bool:
	return visible


func _refresh() -> void:
	if not is_node_ready():
		return
	for child in grid.get_children():
		child.free()
	_slot_buttons.clear()
	if inventory == null:
		capacity_label.text = "Aucun sac"
		_show_selection(-1)
		return
	capacity_label.text = "%d emplacements" % inventory.capacity
	for index in inventory.capacity:
		var button := Button.new()
		button.custom_minimum_size = _effective_slot_size()
		button.focus_mode = Control.FOCUS_ALL
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.pressed.connect(_select_slot.bind(index))
		var stack := inventory.get_slot(index)
		if stack == null:
			button.text = "%02d · —" % (index + 1)
			button.tooltip_text = "Emplacement vide"
		else:
			button.text = "%02d · %s%s" % [
				index + 1,
				stack.item.display_name,
				" ×%d" % stack.quantity if stack.quantity > 1 else "",
			]
			button.tooltip_text = stack.item.description
			button.icon = stack.item.icon
		grid.add_child(button)
		_slot_buttons.append(button)
	if selected_slot >= inventory.capacity:
		selected_slot = -1
	_show_selection(selected_slot)


func _select_slot(index: int) -> void:
	selected_slot = index
	_show_selection(index)


func _show_selection(index: int) -> void:
	if inventory == null or index < 0:
		item_name_label.text = "Sélectionnez un objet"
		description_label.text = "Les objets ramassés apparaîtront dans le premier emplacement compatible."
		return
	var stack := inventory.get_slot(index)
	if stack == null:
		item_name_label.text = "Emplacement vide"
		description_label.text = "Cet emplacement peut recevoir une pile ou un objet unique."
		return
	item_name_label.text = "%s%s" % [
		stack.item.display_name,
		" ×%d" % stack.quantity if stack.quantity > 1 else "",
	]
	description_label.text = stack.item.description


func _focus_preferred_slot() -> void:
	if _slot_buttons.is_empty():
		return
	var preferred := selected_slot if selected_slot >= 0 else 0
	preferred = mini(preferred, _slot_buttons.size() - 1)
	_slot_buttons[preferred].grab_focus()


func _resize_to_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size
	_apply_config()


func _apply_config() -> void:
	if not is_node_ready() or config == null:
		return
	var minimum_panel_width := float(config.columns * 40 + maxi(config.columns - 1, 0) * config.slot_gap_horizontal + config.content_margin_horizontal * 2)
	var safe_horizontal := mini(float(config.outer_margin_horizontal), maxf((size.x - minimum_panel_width) * 0.5, 0.0))
	var safe_vertical := mini(float(config.outer_margin_vertical), maxf((size.y - 180.0) * 0.5, 0.0))
	margin.offset_left = safe_horizontal
	margin.offset_right = -safe_horizontal
	margin.offset_top = safe_vertical
	margin.offset_bottom = -safe_vertical
	content_margin.add_theme_constant_override("margin_left", config.content_margin_horizontal)
	content_margin.add_theme_constant_override("margin_right", config.content_margin_horizontal)
	content_margin.add_theme_constant_override("margin_top", config.content_margin_vertical)
	content_margin.add_theme_constant_override("margin_bottom", config.content_margin_vertical)
	dimmer.color = config.backdrop_color
	panel_background.texture = config.panel_texture
	panel_background.modulate = config.panel_texture_modulate
	grid.columns = config.columns
	grid.add_theme_constant_override("h_separation", config.slot_gap_horizontal)
	grid.add_theme_constant_override("v_separation", config.slot_gap_vertical)
	rows.add_theme_constant_override("separation", config.section_spacing)
	title_label.add_theme_font_size_override("font_size", config.title_font_size)
	item_name_label.add_theme_font_size_override("font_size", config.item_name_font_size)
	for button in _slot_buttons:
		button.custom_minimum_size = _effective_slot_size()


func _effective_slot_size() -> Vector2:
	if config == null:
		return Vector2(88.0, 30.0)
	var available_width := size.x - margin.offset_left + margin.offset_right \
		- float(config.content_margin_horizontal * 2) \
		- float(maxi(config.columns - 1, 0) * config.slot_gap_horizontal)
	var fitting_width := floorf(available_width / float(config.columns))
	return Vector2(minf(float(config.slot_width), maxf(fitting_width, 40.0)), float(config.slot_height))
