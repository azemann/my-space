extends SceneTree

const Converter = preload("res://editor/tiled/tiled_converter.gd")
const Registry = preload("res://game/systems/environment_animation/environment_animation_registry.gd")
const BEACH_SCENE := "res://game/world/maps/plage-du-reveil/plage-du-reveil.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for profile_id in [&"water_calm", &"water_flow", &"shoreline_foam", &"lava_flow", &"poison_swamp", &"magic_surface"]:
		assert(Registry.has_profile(profile_id), "Profil générique absent : %s" % profile_id)
		var profile := Registry.profile(profile_id)
		assert(profile != null and profile.shader != null)
		var material := Registry.create_material(profile_id)
		assert(material != null and material.shader == profile.shader)
		assert(float(material.get_shader_parameter(&"animation_fps")) >= 1.0)

	var tile_set := load("res://game/world/tileset/world_tileset.tres") as TileSet
	assert(tile_set != null)
	for source_id in [13, 14]:
		var water_source := tile_set.get_source(source_id) as TileSetAtlasSource
		for column in range(4):
			_assert_real_tile_animation(water_source, Vector2i(column, 0), 4)
		assert(water_source.get_tile_animation_mode(Vector2i.ZERO) == TileSetAtlasSource.TILE_ANIMATION_MODE_RANDOM_START_TIMES)
	for source_id in [15, 16]:
		var shore_source := tile_set.get_source(source_id) as TileSetAtlasSource
		_assert_real_tile_animation(shore_source, Vector2i.ZERO, 4)

	var parsed := Converter._parse_tmx("res://maps/source/plage-du-reveil.tmx")
	var layer_profiles := {}
	for layer in parsed.layers:
		if layer.properties.has("environment_animation_profile"):
			layer_profiles[str(layer.name)] = str(layer.properties.environment_animation_profile)
	assert(layer_profiles.WaterBase == "water_calm")
	assert(layer_profiles.WaterBanks == "shoreline_foam")
	assert(layer_profiles.WaterEffects == "shoreline_foam")
	for layer_name in ["WaterBase", "WaterBanks", "WaterEffects"]:
		var animated_layer: Dictionary = _parsed_layer(parsed, layer_name)
		assert(float(animated_layer.properties.environment_animation_direction_x) == 0.0)
		assert(float(animated_layer.properties.environment_animation_direction_y) == -1.0)

	var level := (load(BEACH_SCENE) as PackedScene).instantiate()
	var water_base := level.get_node("World/Water/WaterBase") as TileMapLayer
	var water_banks := level.get_node("World/Water/WaterBanks") as TileMapLayer
	var water_effects := level.get_node("World/Water/WaterEffects") as TileMapLayer
	for layer in [water_base, water_banks, water_effects]:
		assert(layer.material is ShaderMaterial, "%s doit recevoir son matériau depuis le profil Tiled" % layer.name)
		assert(layer.get_meta("environment_animation_pipeline") == "profile_v1")
	assert(StringName(water_base.get_meta("environment_animation_profile")) == &"water_calm")
	assert(StringName(water_banks.get_meta("environment_animation_profile")) == &"shoreline_foam")
	assert(StringName(water_effects.get_meta("environment_animation_profile")) == &"shoreline_foam")
	assert(not water_base.collision_enabled, "L'eau peinte reste visuelle ; CollisionOverrides porte sa traversabilité")
	assert(water_base.get_meta("collision_policy") == "visual_layer_collision_disabled")
	level.free()
	print("Animations environnementales vérifiées : vraies frames TileSet, aperçu Tiled et géométrie autoritaire indépendante.")
	quit()


func _assert_real_tile_animation(source: TileSetAtlasSource, coordinates: Vector2i, frames: int) -> void:
	assert(source != null and source.has_tile(coordinates))
	assert(source.get_tile_animation_frames_count(coordinates) == frames, "La tuile %s doit être réellement animée image par image" % coordinates)
	assert(source.get_tile_animation_total_duration(coordinates) > 0.0)
	assert(source.get_runtime_tile_texture_region(coordinates, 0) != source.get_runtime_tile_texture_region(coordinates, frames - 1))


func _parsed_layer(parsed: Dictionary, layer_name: String) -> Dictionary:
	for layer: Dictionary in parsed.layers:
		if str(layer.name) == layer_name:
			return layer
	return {}
