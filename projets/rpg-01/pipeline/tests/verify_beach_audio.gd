extends SceneTree

const MAIN_SCENE := "res://game/core/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame

	var ambience := game.current_map.get_node("Runtime/Ambience")
	var expected_regions := {
		"ShoreCenter": Rect2(480, 580, 320, 220),
		"RockyCoastWest": Rect2(0, 500, 240, 300),
		"RockyCoastEast": Rect2(1040, 500, 240, 300),
		"UpperBeachGulls": Rect2(480, 80, 320, 300),
	}
	for node_name in expected_regions:
		var player := ambience.get_node(node_name) as AudioStreamPlayer2D
		assert(player != null and player.stream != null, "%s doit avoir son flux audio" % node_name)
		assert((expected_regions[node_name] as Rect2).has_point(player.position),
			"%s doit rester dans sa zone spatiale de game design" % node_name)
		assert(player.autoplay and player.playing)
		assert(player.bus == &"Ambience")
		assert(bool(player.stream.get("loop")), "%s doit jouer en boucle" % node_name)
	var ambience_bus := AudioServer.get_bus_index(&"Ambience")
	assert(ambience_bus >= 0)
	assert(AudioServer.get_bus_send(ambience_bus) == &"Master")
	assert(AudioServer.get_bus_send(0) == &"", "Master ne doit pas envoyer vers un bus fantôme")
	var listener := game.player.get_node("AudioListener") as AudioListener2D
	assert(listener != null and listener.is_current(), "Le joueur doit être le point d'écoute spatial")

	for child in ambience.get_children():
		if child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
	game.free()
	await process_frame
	print("Ambiance de plage vérifiée : rivage, rochers latéraux, mouettes et écoute joueur.")
	quit()
