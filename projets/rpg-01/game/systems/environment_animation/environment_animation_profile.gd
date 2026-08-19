@tool
class_name EnvironmentAnimationProfile
extends Resource

## Décrit l'animation visuelle d'une surface telle que l'eau, la lave, le
## poison, l'écume ou une zone magique.

## Identifiant technique utilisé pour retrouver ce profil depuis les cartes et les scripts.
@export var profile_id: StringName
## Résumé lisible de l'effet et du type de surface auquel il est destiné.
@export_multiline var description := ""
## Shader Godot qui réalise l'animation. Ses paramètres sont remplis par ce profil.
@export var shader: Shader
## Vitesse globale du déplacement ou de la pulsation dans le shader.
@export_range(0.0, 8.0, 0.05) var speed := 1.0
## Force de la déformation et des variations lumineuses appliquées à la surface.
@export_range(0.0, 0.5, 0.005) var intensity := 0.08
## Densité spatiale du motif : une valeur haute produit des détails plus rapprochés.
@export_range(0.001, 0.25, 0.001) var spatial_frequency := 0.05
## Fréquence visuelle de l'animation, volontairement limitée pour conserver le rendu pixel art.
@export_range(1.0, 30.0, 1.0, "suffix:fps") var animation_fps := 8.0
## Direction du courant ou du déplacement du motif sur les axes X et Y.
@export var flow_direction := Vector2(1.0, 0.25)
## Couleur ajoutée aux reflets générés par le shader.
@export var tint_color := Color(0.35, 0.82, 1.0, 1.0)
## Seuil à partir duquel une zone du motif devient un reflet clair.
@export_range(0.0, 1.0, 0.01) var highlight_threshold := 0.72


## Crée un matériau indépendant et applique les valeurs du profil avec d'éventuelles surcharges de carte.
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
