class_name PsychokinesisPresentation2D
extends Node2D

## Regroupe tous les effets visuels et sonores d'un objet psychokinétique :
## surbrillance, fantôme, ombre, lévitation, particules et sons d'action.

const GHOST_SHADER := preload("res://game/systems/psychokinesis/psychokinesis_ghost.gdshader")

var body: PsychokineticBody2D
var visual: Node2D
var ghost: Node2D
var shadow: Node2D
var interaction: PsychokinesisInteractionArea2D
var lift_audio: AudioStreamPlayer2D
var hold_audio: AudioStreamPlayer2D
var throw_audio: AudioStreamPlayer2D
var impact_audio: AudioStreamPlayer2D

var visual_origin := Vector2.ZERO
var visual_rotation := 0.0
var shadow_origin_scale := Vector2.ONE
var shadow_origin_color := Color.WHITE
var shadow_ground_offset := Vector2.ZERO

var _highlight_blend := 0.0
var _ghost_material: ShaderMaterial
var _float_time := 0.0


## Découvre les nœuds visuels et audio facultatifs appartenant au corps donné.
func setup(owner_body: PsychokineticBody2D) -> void:
	body = owner_body
	visual = body.get_node_or_null("Visual") as Node2D
	ghost = body.get_node_or_null("SelectionGhost") as Node2D
	shadow = body.get_node_or_null("Shadow") as Node2D
	interaction = body.get_node_or_null("SelectionArea") as PsychokinesisInteractionArea2D
	lift_audio = body.get_node_or_null("LiftAudio") as AudioStreamPlayer2D
	hold_audio = body.get_node_or_null("HoldAudio") as AudioStreamPlayer2D
	throw_audio = body.get_node_or_null("ThrowAudio") as AudioStreamPlayer2D
	impact_audio = body.get_node_or_null("ImpactAudio") as AudioStreamPlayer2D
	if visual != null:
		visual_origin = visual.position
		visual_rotation = visual.rotation
	_setup_ghost()
	if shadow != null:
		shadow_origin_scale = shadow.scale
		shadow_origin_color = shadow.modulate
		shadow_ground_offset = shadow.position
		shadow.top_level = true
	if hold_audio != null:
		hold_audio.finished.connect(_on_hold_audio_finished)
	sync_shadow_to_ground()


## Remet immédiatement tous les effets dans leur état visuel initial.
func reset() -> void:
	_highlight_blend = 0.0
	if visual != null:
		visual.modulate = Color.WHITE
	if ghost != null:
		ghost.visible = false
	if _ghost_material != null:
		_ghost_material.set_shader_parameter(&"opacity", 0.0)
	if hold_audio != null:
		hold_audio.stop()
	queue_redraw()


## Retire progressivement l'indication de cible sans toucher aux autres effets.
func clear_target_highlight() -> void:
	_highlight_blend = 0.0
	if ghost != null:
		ghost.visible = false
	if _ghost_material != null:
		_ghost_material.set_shader_parameter(&"opacity", 0.0)


## Met à jour la surbrillance, la pulsation et le fantôme à chaque image utile.
func tick(delta: float, float_time: float) -> void:
	_float_time = float_time
	sync_shadow_to_ground()
	_update_ghost(delta)
	queue_redraw()


## Décale le visuel, adapte l'ombre et anime la prise selon la hauteur abstraite.
func apply_elevation(height: float, bob: float, grab_elapsed: float) -> void:
	if body == null:
		return
	var height_ratio := height / body.maximum_height if body.maximum_height > 0.0 else 0.0
	if visual != null:
		var tremor_fade := clampf(1.0 - grab_elapsed / 0.18, 0.0, 1.0) if body.is_held else 0.0
		var tremor := sin(grab_elapsed * 115.0) * 1.6 * tremor_fade
		visual.position = visual_origin + Vector2(tremor, -height - bob)
		visual.rotation = visual_rotation + sin(_float_time * 2.3) * 0.035 * height_ratio
	if interaction != null:
		interaction.follow_lift(body.visual_focus_offset, height, bob)
	if shadow != null:
		shadow.scale = shadow_origin_scale * lerpf(1.0, 0.55, height_ratio)
		var shadow_color := shadow_origin_color
		shadow_color.a *= lerpf(1.0, 0.35, height_ratio)
		shadow.modulate = shadow_color
		sync_shadow_to_ground()


## Joue les effets déclenchés au début d'une prise psychokinétique.
func on_hold_started() -> void:
	if visual != null:
		visual.modulate = Color(1.08, 1.04, 1.16)
	if lift_audio != null:
		lift_audio.play()
	if hold_audio != null:
		hold_audio.play()
	emit_motes(Color(0.73, 0.58, 0.38, 0.9), 9, 24.0)


## Arrête les effets de maintien lorsque l'objet est simplement relâché.
func on_released() -> void:
	if visual != null:
		visual.modulate = Color.WHITE
	if hold_audio != null:
		hold_audio.stop()


## Joue les effets visuels et sonores propres à une projection.
func on_thrown() -> void:
	on_released()
	if throw_audio != null:
		throw_audio.play()


## Joue les effets d'atterrissage et rétablit la présentation au sol.
func on_landed() -> void:
	emit_motes(Color(0.72, 0.57, 0.38, 0.95), 13, 42.0)
	if impact_audio != null:
		impact_audio.play()


## Maintient l'ombre sur l'ancre physique au sol malgré l'élévation du visuel.
func sync_shadow_to_ground() -> void:
	if shadow == null or body == null:
		return
	shadow.global_position = body.global_position + shadow_ground_offset
	shadow.global_rotation = 0.0


## Émet un petit groupe de particules de la couleur et de la vitesse demandées.
func emit_motes(color: Color, count: int, speed: float) -> void:
	if body == null or not body.effects_enabled or not body.is_inside_tree() or body.get_parent() == null:
		return
	var particles := CPUParticles2D.new()
	body.get_parent().add_child(particles)
	particles.global_position = body.global_position + Vector2(0.0, -4.0)
	particles.z_index = 2
	particles.one_shot = true
	particles.amount = count
	particles.lifetime = 0.42
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 155.0
	particles.initial_velocity_min = speed * 0.45
	particles.initial_velocity_max = speed
	particles.gravity = Vector2(0.0, 70.0)
	particles.scale_amount_min = 0.7
	particles.scale_amount_max = 1.4
	particles.color = color
	body.get_tree().create_timer(particles.lifetime + 0.08).timeout.connect(particles.queue_free)
	particles.emitting = true


func _setup_ghost() -> void:
	if visual == null:
		return
	if ghost == null:
		ghost = visual.duplicate() as Node2D
		ghost.name = "SelectionGhost"
		body.add_child(ghost)
	if ghost == null:
		return
	if ghost is TileMapLayer:
		(ghost as TileMapLayer).collision_enabled = false
	ghost.z_as_relative = false
	ghost.z_index = 99
	ghost.visible = false
	_ghost_material = ShaderMaterial.new()
	_ghost_material.shader = GHOST_SHADER
	ghost.material = _ghost_material


func _update_ghost(delta: float) -> void:
	if ghost == null or visual == null or _ghost_material == null or body == null:
		return
	var active := body.is_targeted or body.is_held
	var fade_speed := 36.0 if active else 28.0
	_highlight_blend = move_toward(_highlight_blend, 1.0 if active else 0.0, fade_speed * delta)
	ghost.visible = _highlight_blend > 0.01
	if not ghost.visible:
		return
	var pulse := 0.5 + 0.5 * sin(_float_time * 4.6)
	var state_opacity := 0.9 + pulse * 0.08 if body.is_held else 0.84 + pulse * 0.08
	var ghost_color := Color(0.24, 0.88, 1.0, 0.98)
	if body.is_held:
		ghost_color = ghost_color.lerp(Color(0.86, 0.43, 1.0, 0.98), 0.45 + body.charge_ratio * 0.55)
	_ghost_material.set_shader_parameter(&"ghost_color", ghost_color)
	_ghost_material.set_shader_parameter(&"opacity", _highlight_blend * state_opacity)
	_ghost_material.set_shader_parameter(&"fill_strength", 0.14 + body.charge_ratio * 0.1 if body.is_held else 0.075)
	_ghost_material.set_shader_parameter(&"outline_strength", 1.0)
	_ghost_material.set_shader_parameter(&"outer_outline_strength", 0.72 if body.is_held else 0.58)
	ghost.transform = visual.transform


func _draw() -> void:
	if body == null or not body.is_held:
		return
	var center := body.visual_focus_offset + Vector2(0.0, -body.height)
	var pulse := sin(_float_time * 5.5) * 1.5
	var energy := Color(0.47, 0.78, 1.0, 0.78).lerp(Color(0.92, 0.48, 1.0, 0.95), body.charge_ratio)
	draw_arc(center, 19.0 + pulse + body.charge_ratio * 3.0, 0.0, TAU, 28, energy, 1.25)
	for index in 4:
		var angle := _float_time * (1.4 + body.charge_ratio) + float(index) * TAU / 4.0
		var mote_position := center + Vector2.from_angle(angle) * (14.0 + pulse)
		draw_circle(mote_position.round(), 1.2 + body.charge_ratio, energy)


func _on_hold_audio_finished() -> void:
	if body != null and body.is_held and hold_audio != null:
		hold_audio.play()
