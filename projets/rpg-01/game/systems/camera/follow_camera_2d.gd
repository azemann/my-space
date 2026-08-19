class_name FollowCamera2D
extends Camera2D

## Caméra persistante qui suit une cible avec anticipation, limites de carte,
## zones de zoom, arrondi pixel-perfect et secousses d'impact.

## Configuration partagée qui définit le cadrage et le comportement du suivi.
@export var config: CameraConfig

var target: Node2D
var base_bounds := Rect2(0, 0, 640, 360)
var desired_zoom := Vector2.ONE
var zone_offset := Vector2.ZERO
var look_ahead := Vector2.ZERO
var active_zones: Array[Area2D] = []
var _shake_remaining := 0.0
var _shake_strength := 0.0
var _shake_phase := 0.0
var _smoothed_position := Vector2.ZERO
var _has_smoothed_position := false


func _ready() -> void:
	_apply_config()


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var desired := target.global_position
	if config != null and config.use_player_camera_anchor:
		var anchor := target.get_node_or_null("CameraAnchor") as Node2D
		if anchor != null:
			desired = anchor.global_position
	if config != null:
		var target_look_ahead := Vector2.ZERO
		if target is CharacterBody2D and not target.velocity.is_zero_approx():
			target_look_ahead = target.velocity.normalized() * config.look_ahead_distance
		look_ahead = look_ahead.lerp(target_look_ahead, 1.0 - exp(-config.look_ahead_response * delta))
		desired += config.offset + zone_offset + look_ahead
		if config.pixel_snap_target:
			desired = desired.round()
		if _shake_remaining > 0.0:
			_shake_remaining = maxf(_shake_remaining - delta, 0.0)
			_shake_phase += delta * 52.0
			var fade := _shake_remaining / 0.16
			desired += Vector2(sin(_shake_phase * 1.7), cos(_shake_phase * 2.3)) * 2.5 * _shake_strength * fade
		if config.pixel_perfect_zoom:
			zoom = desired_zoom
		else:
			zoom = zoom.lerp(desired_zoom, 1.0 - exp(-config.zoom_transition_speed * delta))
	if config != null and config.pixel_perfect_motion:
		if not _has_smoothed_position:
			_smoothed_position = desired
			_has_smoothed_position = true
		elif config.position_smoothing_enabled:
			_smoothed_position = _smoothed_position.lerp(
				desired,
				1.0 - exp(-config.position_smoothing_speed * delta)
			)
		else:
			_smoothed_position = desired
		global_position = _smoothed_position.round()
	else:
		global_position = desired


## Ajoute une courte secousse dont l'intensité dépend de la force de l'impact.
func add_impact_shake(strength: float) -> void:
	_shake_strength = maxf(_shake_strength, clampf(strength, 0.0, 1.0))
	_shake_remaining = 0.16


## Choisit le nœud suivi et réinitialise immédiatement le lissage sur sa position.
func set_target(value: Node2D) -> void:
	target = value
	if target != null:
		global_position = target.global_position
		_smoothed_position = global_position
		_has_smoothed_position = true


## Définit le rectangle mondial que la caméra ne doit pas dépasser.
func set_world_bounds(bounds: Rect2) -> void:
	base_bounds = bounds
	_set_limits(bounds)


func _set_limits(bounds: Rect2) -> void:
	limit_left = roundi(bounds.position.x)
	limit_top = roundi(bounds.position.y)
	limit_right = roundi(bounds.end.x)
	limit_bottom = roundi(bounds.end.y)


## Lit les limites et zones caméra déclarées par une carte nouvellement chargée.
func configure_for_map(map: Node) -> void:
	active_zones.clear()
	zone_offset = Vector2.ZERO
	desired_zoom = _validated_zoom(config.zoom.x if config != null else 1.0)
	set_world_bounds(map.get_meta("camera_bounds", Rect2(0, 0, 640, 360)))
	var zones := map.get_node_or_null("World/Gameplay/CameraZones")
	if zones == null:
		return
	for child in zones.get_children():
		var area := child as Area2D
		if area == null:
			continue
		area.body_entered.connect(_on_camera_zone_body_entered.bind(area))
		area.body_exited.connect(_on_camera_zone_body_exited.bind(area))


func _on_camera_zone_body_entered(body: Node2D, zone: Area2D) -> void:
	if body != target or active_zones.has(zone):
		return
	active_zones.append(zone)
	_apply_best_zone()


func _on_camera_zone_body_exited(body: Node2D, zone: Area2D) -> void:
	if body != target:
		return
	active_zones.erase(zone)
	_apply_best_zone()


func _apply_best_zone() -> void:
	active_zones = active_zones.filter(func(zone: Area2D) -> bool: return is_instance_valid(zone))
	active_zones.sort_custom(func(a: Area2D, b: Area2D) -> bool: return int(a.get_meta("priority", 0)) > int(b.get_meta("priority", 0)))
	if active_zones.is_empty():
		zone_offset = Vector2.ZERO
		desired_zoom = _validated_zoom(config.zoom.x if config != null else 1.0)
		_set_limits(base_bounds)
		return
	var zone := active_zones[0]
	var zoom_value := float(zone.get_meta("zoom", config.zoom.x if config != null else 1.0))
	desired_zoom = _validated_zoom(zoom_value)
	zone_offset = Vector2(float(zone.get_meta("offset_x", 0.0)), float(zone.get_meta("offset_y", 0.0)))
	var zone_bounds := Rect2(
		float(zone.get_meta("limit_left", base_bounds.position.x)),
		float(zone.get_meta("limit_top", base_bounds.position.y)),
		float(zone.get_meta("limit_right", base_bounds.end.x)) - float(zone.get_meta("limit_left", base_bounds.position.x)),
		float(zone.get_meta("limit_bottom", base_bounds.end.y)) - float(zone.get_meta("limit_top", base_bounds.position.y))
	)
	_set_limits(zone_bounds)


func _apply_config() -> void:
	if config == null:
		return
	zoom = config.zoom
	desired_zoom = _validated_zoom(config.zoom.x)
	position_smoothing_enabled = config.position_smoothing_enabled and not config.pixel_perfect_motion
	position_smoothing_speed = config.position_smoothing_speed
	limit_smoothed = config.position_smoothing_enabled and not config.pixel_perfect_motion


func _validated_zoom(requested_zoom: float) -> Vector2:
	if config == null or not config.pixel_perfect_zoom or config.pixel_perfect_zoom_levels.is_empty():
		return Vector2.ONE * requested_zoom
	var closest := config.pixel_perfect_zoom_levels[0]
	var closest_distance := absf(requested_zoom - closest)
	for candidate in config.pixel_perfect_zoom_levels:
		var distance := absf(requested_zoom - candidate)
		if distance < closest_distance:
			closest = candidate
			closest_distance = distance
	return Vector2.ONE * closest
