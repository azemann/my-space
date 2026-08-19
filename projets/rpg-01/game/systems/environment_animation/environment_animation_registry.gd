@tool
class_name EnvironmentAnimationRegistry
extends RefCounted

## Catalogue central des animations de surface disponibles. Il permet aux
## cartes et au convertisseur Tiled de travailler avec des identifiants stables.

const PROFILES := {
	&"water_calm": preload("res://game/systems/environment_animation/profiles/water_calm.tres"),
	&"water_flow": preload("res://game/systems/environment_animation/profiles/water_flow.tres"),
	&"shoreline_foam": preload("res://game/systems/environment_animation/profiles/shoreline_foam.tres"),
	&"lava_flow": preload("res://game/systems/environment_animation/profiles/lava_flow.tres"),
	&"poison_swamp": preload("res://game/systems/environment_animation/profiles/poison_swamp.tres"),
	&"magic_surface": preload("res://game/systems/environment_animation/profiles/magic_surface.tres"),
}


## Indique si un identifiant correspond à un profil enregistré.
static func has_profile(profile_id: StringName) -> bool:
	return PROFILES.has(profile_id)


## Renvoie le profil associé à l'identifiant, ou null s'il est inconnu.
static func profile(profile_id: StringName) -> EnvironmentAnimationProfile:
	return PROFILES.get(profile_id) as EnvironmentAnimationProfile


## Construit un matériau à partir d'un profil nommé et de surcharges optionnelles.
static func create_material(profile_id: StringName, overrides: Dictionary = {}) -> ShaderMaterial:
	var selected := profile(profile_id)
	return selected.create_material(overrides) if selected != null else null


## Choisit le profil par défaut correspondant au nom d'un calque de carte.
static func default_profile_for_layer(layer_name: String) -> StringName:
	match layer_name:
		"WaterBase": return &"water_calm"
		"WaterBanks": return &"shoreline_foam"
		"Waterfalls": return &"water_flow"
		"WaterEffects": return &"water_flow"
		_: return &""
