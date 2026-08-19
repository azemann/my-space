extends Node2D

## Anime la profondeur du premier plan de la Plage du Réveil sans perturber les
## objets physiques psychokinétiques qu'il peut contenir.

## Proportion du déplacement de caméra appliquée au premier plan non physique.
@export_range(0.0, 0.15, 0.005) var foreground_parallax := 0.035
## Inclinaison maximale donnée aux éléments du premier plan par le vent.
@export_range(0.0, 2.0, 0.05, "suffix:deg") var foreground_sway_degrees := 0.45
## Centre de référence de la carte utilisé pour calculer le décalage de parallaxe.
@export var map_center := Vector2(640.0, 480.0)

var _foreground: Node2D
var _foreground_origin := Vector2.ZERO
var _child_rotations: Dictionary = {}
var _wind_time := 0.0


func _ready() -> void:
	var map := get_parent()
	_foreground = map.get_node_or_null("World/PlacedObjects/ForegroundObjects") as Node2D
	if _foreground != null:
		_foreground_origin = _foreground.position
		_foreground.modulate = Color(0.82, 0.87, 0.84, 0.96)
		for child in _foreground.get_children():
			if child is Node2D:
				_child_rotations[child] = child.rotation
	_create_wind_motes()


func _process(delta: float) -> void:
	_wind_time += delta
	if _foreground == null:
		return
	var camera := get_viewport().get_camera_2d()
	var contains_physics_bodies := _foreground.get_children().any(func(child): return child is PsychokineticBody2D)
	if camera != null and not contains_physics_bodies:
		var camera_delta := camera.global_position - map_center
		var desired_position := _foreground_origin + (camera_delta * foreground_parallax).round()
		if not _foreground.position.is_equal_approx(desired_position):
			_foreground.position = desired_position
	else:
		# Un RigidBody2D ne doit jamais être déplacé indirectement par le transform
		# animé de son parent : sa position appartient au serveur physique. Même
		# réassigner la même position invalide le transform physique de ses enfants.
		if not _foreground.position.is_equal_approx(_foreground_origin):
			_foreground.position = _foreground_origin
	var amplitude := deg_to_rad(foreground_sway_degrees)
	var index := 0
	for child in _child_rotations:
		if is_instance_valid(child) and not child is PsychokineticBody2D:
			child.rotation = float(_child_rotations[child]) + sin(_wind_time * 1.25 + index * 0.9) * amplitude
		index += 1


func _create_wind_motes() -> void:
	var particles := CPUParticles2D.new()
	particles.name = "WindMotes"
	add_child(particles)
	particles.position = Vector2(640.0, 410.0)
	particles.z_index = 55
	particles.amount = 24
	particles.lifetime = 6.0
	particles.preprocess = 6.0
	particles.fixed_fps = 12
	particles.local_coords = false
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(620.0, 250.0)
	particles.direction = Vector2(1.0, -0.08)
	particles.spread = 9.0
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 11.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 0.45
	particles.scale_amount_max = 0.9
	particles.color = Color(1.0, 0.88, 0.58, 0.22)
	particles.emitting = true
