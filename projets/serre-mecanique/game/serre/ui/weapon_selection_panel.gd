class_name WeaponSelectionPanel
extends Control

const Actions = preload("res://game/serre/contracts/input_actions.gd")

signal opened
signal closed
signal weapon_selected(definition: Resource)

## Chemin vers le WeaponController dont la roue doit afficher l'inventaire.
@export var equipment_path := NodePath("../../Player/Equipment")
## Action InputMap ouvrant ou refermant la roue. Sa touche peut être reconfigurée sans modifier ce script.
@export var toggle_action := &"weapon_menu"
## Action InputMap fermant la roue sans changer l'arme.
@export var cancel_action := &"weapon_cancel"
## Nombre de secteurs réservés dans la roue. Les secteurs sans arme apparaissent comme emplacements vides.
@export_range(4, 12) var wheel_slots := 8

var equipment: WeaponController
@onready var wheel: WeaponWheel = %WeaponWheel
@onready var selected_label: Label = %SelectedWeapon


func _ready() -> void:
	set_process_input(true)
	equipment = get_node_or_null(equipment_path) as WeaponController
	if equipment:
		equipment.equipped_changed.connect(_on_equipped_changed)
		equipment.holstered_changed.connect(_on_holstered_changed)
	if wheel:
		wheel.slot_count = wheel_slots
		wheel.weapon_chosen.connect(_select_weapon)
		wheel.weapon_highlighted.connect(_on_weapon_highlighted)
	_rebuild_inventory()
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(toggle_action, false):
		toggle_menu()
		get_viewport().set_input_as_handled()
		return
	if not visible:
		return
	if event.is_action_pressed(cancel_action, false):
		close_menu()
		get_viewport().set_input_as_handled()
		return
	for index in 9:
		if event.is_action_pressed(Actions.weapon_slot(index), false):
			if equipment and index < equipment.inventory.size():
				_select_weapon(index)
			get_viewport().set_input_as_handled()
			return


func toggle_menu() -> void:
	if visible:
		close_menu()
	else:
		open_menu()


func open_menu() -> void:
	if equipment == null:
		return
	_rebuild_inventory()
	visible = true
	equipment.set_input_enabled(false)
	wheel.set_highlighted_index(equipment.equipped_index)
	wheel.grab_focus()
	opened.emit()


func close_menu() -> void:
	visible = false
	if equipment:
		equipment.set_input_enabled(true)
	closed.emit()


func _rebuild_inventory() -> void:
	if wheel == null:
		return
	var inventory: Array[Resource] = equipment.inventory if equipment else []
	wheel.set_inventory(inventory, equipment.equipped_index if equipment else -1)
	_refresh_selection()


func _select_weapon(index: int) -> void:
	if equipment and equipment.equip(index):
		weapon_selected.emit(equipment.equipped_weapon)
		close_menu()


func _on_equipped_changed(_definition: Resource) -> void:
	_refresh_selection()


func _on_holstered_changed(_holstered: bool, _definition: Resource) -> void:
	_refresh_selection()


func _on_weapon_highlighted(index: int) -> void:
	if equipment == null or index < 0 or index >= equipment.inventory.size():
		selected_label.text = "Emplacement vide"
		return
	var definition := equipment.inventory[index]
	var ammo := int(definition.get("ammo_count"))
	var amount := "∞" if ammo < 0 else str(ammo)
	selected_label.text = "%s  ·  quantité %s" % [str(definition.get("display_name")), amount]


func _refresh_selection() -> void:
	if selected_label == null:
		return
	if equipment == null or equipment.equipped_weapon == null:
		selected_label.text = "Aucun équipement"
		return
	var state := "Rangé" if equipment.is_holstered else "Équipé"
	selected_label.text = "%s : %s" % [state, str(equipment.equipped_weapon.get("display_name"))]
	if wheel:
		wheel.set_equipped_index(equipment.equipped_index)
