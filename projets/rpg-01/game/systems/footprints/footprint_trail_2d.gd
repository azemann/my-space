class_name FootprintTrail2D
extends Node2D

## Composant de carte qui dépose des scènes d'empreinte lorsque le joueur
## marche sur la surface configurée. Les choix artistiques vivent dans le
## FootprintTrailProfile et dans la scène d'empreinte, tous deux éditables.

@export_category("Références Godot")
## Profil qui décrit la surface, l'espacement et la scène des empreintes.
@export var profile: FootprintTrailProfile
## Chemin du TileMapLayer interrogé pour connaître le terrain sous les pas.
@export_node_path("TileMapLayer") var surface_layer_path: NodePath
## Groupe Godot utilisé pour retrouver automatiquement le personnage suivi.
@export var player_group: StringName = &"player_actor"

@export_category("Activation")
## Active ou suspend la création de nouvelles empreintes.
@export var enabled := true

var _player: CharacterBody2D
var _last_sample_position := Vector2.ZERO
var _has_sample := false
var _next_foot_is_left := true


func _physics_process(_delta: float) -> void:
	if not enabled or profile == null or profile.footprint_scene == null:
		return
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(player_group) as CharacterBody2D
	if _player == null:
		return
	if _player.velocity.length() < profile.minimum_speed:
		_has_sample = false
		return

	var current_position := _player.global_position
	if not _has_sample:
		_last_sample_position = current_position
		_has_sample = true
		return
	if current_position.distance_to(_last_sample_position) < profile.step_distance:
		return

	var travel_direction := (_player.global_position - _last_sample_position).normalized()
	_last_sample_position = current_position
	if not is_required_surface_at(current_position):
		return
	_spawn_footprint(current_position, travel_direction)


## Vérifie si la position mondiale correspond au terrain demandé par le profil.
func is_required_surface_at(world_position: Vector2) -> bool:
	if profile == null:
		return false
	var surface_layer := get_node_or_null(surface_layer_path) as TileMapLayer
	if surface_layer == null:
		return false
	var cell := surface_layer.local_to_map(surface_layer.to_local(world_position))
	var tile_data := surface_layer.get_cell_tile_data(cell)
	if tile_data == null:
		return false
	return StringName(str(tile_data.get_custom_data(profile.custom_data_name))) == profile.required_surface


func _spawn_footprint(world_position: Vector2, travel_direction: Vector2) -> void:
	var footprint := profile.footprint_scene.instantiate() as FootprintDecal2D
	if footprint == null:
		push_error("La scène du FootprintTrailProfile doit avoir FootprintDecal2D pour racine.")
		return
	add_child(footprint)
	var side := -1.0 if _next_foot_is_left else 1.0
	footprint.global_position = world_position + travel_direction.orthogonal() * profile.lateral_foot_offset * side
	footprint.global_rotation = travel_direction.angle() + PI / 2.0
	footprint.set_left_foot(_next_foot_is_left)
	_next_foot_is_left = not _next_foot_is_left

	var surplus := get_child_count() - profile.maximum_visible_footprints
	for index in range(maxi(0, surplus)):
		get_child(index).queue_free()
