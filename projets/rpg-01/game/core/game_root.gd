class_name GameRoot
extends Node

## Racine persistante d'une partie. Elle conserve le joueur et les systèmes
## globaux pendant les changements de carte.

## Émis après l'installation et la restauration d'une nouvelle carte.
signal map_changed(map_id: StringName)
## Émis après le placement du joueur sur un point d'apparition.
signal player_spawned(spawn_id: StringName, position: Vector2)

## Identifiant du point où placer le joueur lors du premier chargement.
@export var initial_spawn_id: StringName = &"village-arrival"

@onready var world_container: Node = $WorldContainer
@onready var world_state: WorldStateStore = $WorldState
@onready var persistent_actors: Node2D = $PersistentActors
@onready var player: PlayerController = $PersistentActors/Player
@onready var psychokinesis: PsychokinesisController = $Psychokinesis
@onready var camera: FollowCamera2D = $Camera
@onready var inventory_panel: InventoryPanel = $Interface/InventoryPanel

var current_map: Node2D


func _ready() -> void:
	current_map = world_container.get_child(0) as Node2D
	if current_map == null:
		push_error("GameRoot nécessite une carte initiale dans WorldContainer.")
		return
	_attach_persistent_player(current_map, initial_spawn_id)
	world_state.restore_map_state(current_map)
	camera.set_target(player)
	inventory_panel.set_inventory(player.inventory)
	_apply_map_camera_bounds(current_map)
	map_changed.emit(StringName(current_map.get_meta("level_id", current_map.name)))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"inventory"):
		_set_inventory_open(not inventory_panel.is_open())
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and inventory_panel.is_open():
		_set_inventory_open(false)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"pause"):
		get_tree().paused = not get_tree().paused
		get_viewport().set_input_as_handled()


## Remplace la carte active, restaure son état et place le joueur au point demandé.
func change_map(next_map_scene: PackedScene, spawn_id: StringName) -> void:
	if next_map_scene == null:
		push_error("Impossible de changer vers une carte vide.")
		return
	player.set_controls_enabled(false)
	psychokinesis.cancel_manipulation()
	world_state.capture_map_state(current_map)
	player.reparent(persistent_actors, true)
	if current_map != null:
		current_map.queue_free()
		await current_map.tree_exited
	current_map = next_map_scene.instantiate() as Node2D
	world_container.add_child(current_map)
	if not current_map.is_node_ready():
		await current_map.ready
	_attach_persistent_player(current_map, spawn_id)
	# Les RigidBody2D reçoivent leur transformation auteur lors de leur premier
	# tick physique. Restaurer ensuite empêche cette initialisation d'écraser
	# l'état d'instance mémorisé.
	await get_tree().physics_frame
	world_state.restore_map_state(current_map)
	_apply_map_camera_bounds(current_map)
	player.set_controls_enabled(true)
	map_changed.emit(StringName(current_map.get_meta("level_id", current_map.name)))


func _attach_persistent_player(map: Node2D, spawn_id: StringName) -> void:
	var actor_parent_path: NodePath = map.get_meta("actor_parent_path", NodePath("World/PlacedObjects/YSortedObjects"))
	var actor_parent := map.get_node_or_null(actor_parent_path)
	if actor_parent == null:
		push_error("Point de tri des acteurs absent dans %s : %s" % [map.name, actor_parent_path])
		actor_parent = persistent_actors
	player.reparent(actor_parent, false)
	var spawn := _find_spawn(map, spawn_id)
	if spawn == null:
		push_warning("Spawn '%s' absent dans %s ; position (0,0) utilisée." % [spawn_id, map.name])
		player.position = Vector2.ZERO
	else:
		player.global_position = spawn.global_position
	player_spawned.emit(spawn_id, player.global_position)


func _find_spawn(map: Node, spawn_id: StringName) -> Marker2D:
	var spawn_root := map.get_node_or_null("World/Gameplay/SpawnPoints")
	if spawn_root == null:
		return null
	for child in spawn_root.get_children():
		if child is Marker2D and StringName(child.get_meta("spawn_id", child.name)) == spawn_id:
			return child
	return null


func _apply_map_camera_bounds(map: Node) -> void:
	camera.configure_for_map(map)


func _set_inventory_open(open: bool) -> void:
	if open:
		psychokinesis.cancel_manipulation()
	inventory_panel.set_open(open)
	player.set_controls_enabled(not open)
	psychokinesis.set_controls_enabled(not open)
