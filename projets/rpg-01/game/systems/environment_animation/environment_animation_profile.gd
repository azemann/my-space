@tool
class_name EnvironmentAnimationProfile
extends Resource

@export var profile_id: StringName
@export_multiline var description := ""
@export var shader: Shader
@export_range(0.0, 8.0, 0.05) var speed := 1.0
@export_range(0.0, 0.5, 0.005) var intensity := 0.08
@export_range(0.001, 0.25, 0.001) var spatial_frequency := 0.05
@export_range(1.0, 30.0, 1.0, "suffix:fps") var animation_fps := 8.0
@export var flow_direction := Vector2(1.0, 0.25)
@export var tint_color := Color(0.35, 0.82, 1.0, 1.0)
@export_range(0.0, 1.0, 0.01) var highlight_threshold := 0.72


func create_material(overrides: Dictionary = {}) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = shader
	var speed_scale := float(overrides.get("environment_animation_speed_scale", 1.0))
	var intensity_scale := float(overrides.get("environment_animation_intensity_scale", 1.0))
	var direction := Vector2(
		float(overrides.get("environment_animation_direction_x", flow_direction.x)),
		float(overrides.get("environment_animation_direction_y", flow_direction.y))
	)
	result.set_shader_parameter(&"speed", speed * speed_scale)
	result.set_shader_parameter(&"intensity", intensity * intensity_scale)
	result.set_shader_parameter(&"spatial_frequency", spatial_frequency)
	result.set_shader_parameter(&"animation_fps", float(overrides.get("environment_animation_fps", animation_fps)))
	result.set_shader_parameter(&"flow_direction", direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT)
	result.set_shader_parameter(&"tint_color", tint_color)
	result.set_shader_parameter(&"highlight_threshold", highlight_threshold)
	result.set_shader_parameter(&"phase_offset", float(overrides.get("environment_animation_phase", 0.0)))
	return result
