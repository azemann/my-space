extends SceneTree

const BEACH_SCENE := "res://game/world/maps/plage-du-reveil/plage-du-reveil.tscn"
const PLAYER_SCENE := "res://game/actors/player/player.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var level := (load(BEACH_SCENE) as PackedScene).instantiate()
	root.add_child(level)
	await process_frame

	var layer := level.get_node("World/Terrain/GroundVariations") as TileMapLayer
	var trail := level.get_node("Runtime/Footprints") as FootprintTrail2D
	assert(layer != null and trail != null)
	assert(trail.profile != null and trail.profile.footprint_scene != null)
	assert(trail.surface_layer_path == NodePath("../../World/Terrain/GroundVariations"))
	assert(trail.profile.required_surface == &"wet_sand")
	assert(trail.z_index == layer.z_index, "Les empreintes doivent être au-dessus du sol et sous GroundObjects")

	var edge_rows: Dictionary = {}
	var edge_variants: Dictionary = {}
	for x in range(40):
		var first_wet_row := -1
		for y in range(19):
			var tile_data := layer.get_cell_tile_data(Vector2i(x, y))
			if tile_data != null and str(tile_data.get_custom_data(&"terrain_kind")) == "wet_sand":
				first_wet_row = y
				break
		assert(first_wet_row >= 0, "Chaque colonne doit rejoindre le sable humide")
		edge_rows[first_wet_row] = true
		edge_variants[layer.get_cell_atlas_coords(Vector2i(x, first_wet_row)).x] = true
	assert(edge_rows.size() >= 4, "La lisière humide doit avoir un contour organique sur au moins quatre hauteurs")
	assert(edge_variants.size() >= 3, "La lisière doit employer les transitions droites et diagonales du TileSet")

	var wet_position := layer.to_global(layer.map_to_local(Vector2i(14, 14)))
	var dry_position := layer.to_global(layer.map_to_local(Vector2i(20, 10)))
	assert(trail.is_required_surface_at(wet_position))
	assert(not trail.is_required_surface_at(dry_position))

	var player := (load(PLAYER_SCENE) as PackedScene).instantiate() as CharacterBody2D
	level.add_child(player)
	player.set_physics_process(false)
	assert(player.is_in_group(&"player_actor"))
	player.global_position = wet_position
	player.velocity = Vector2.DOWN * 100.0
	trail._physics_process(0.0)
	player.global_position += Vector2.DOWN * (trail.profile.step_distance + 1.0)
	trail._physics_process(0.0)
	assert(trail.get_child_count() == 1)
	var footprint := trail.get_child(0) as FootprintDecal2D
	assert(footprint != null)
	var animation := footprint.get_node("AnimationPlayer") as AnimationPlayer
	assert(animation.has_animation(&"fade_out"))
	assert(is_equal_approx(animation.get_animation(&"fade_out").length, 7.0))

	level.free()
	await process_frame
	print("Sable humide et empreintes vérifiés : contour organique, profil Godot, surface et disparition.")
	quit()
