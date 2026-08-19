extends SceneTree

## Vérifie le transfert monde-vers-sac, le refus sans disparition et l'état collecté persistant.

const MAIN_SCENE := "res://game/core/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame
	var shard_body := game.current_map.get_node("World/PlacedObjects/GroundObjects/EclatMetallique") as PsychokineticBody2D
	var pickup := shard_body.get_node("Pickup") as InventoryPickup
	var persistence := shard_body.get_node("Persistence") as PersistentWorldInstance
	assert(pickup != null and pickup.item.item_id == &"story.metallic_shard")
	assert(not pickup.is_collected and shard_body.visible)

	game.player.interaction_requested.emit(pickup.interaction_position(), Vector2.RIGHT)
	assert(pickup.is_collected, "L'interaction doit collecter l'éclat")
	assert(not shard_body.visible and not shard_body.is_in_group(&"psychokinetic_targets"))
	assert(game.player.inventory.amount_of(&"story.metallic_shard") == 1)

	var saved_state := persistence.capture_instance_state(game.current_map)
	pickup.restore_persistent_state_fragment({"collected": false})
	assert(shard_body.visible and shard_body.is_in_group(&"psychokinetic_targets"))
	persistence.restore_instance_state(game.current_map, saved_state)
	assert(pickup.is_collected and not shard_body.visible,
		"La restauration doit conserver la disparition de l'instance collectée")

	var catalog := load("res://game/content/items/catalog.tres") as ItemCatalog
	var metal := catalog.get_item(&"material.metal_fragment")
	assert(game.player.inventory.add(metal, 380).succeeded())
	var rejected_body := Node2D.new()
	game.current_map.add_child(rejected_body)
	var rejected_pickup := InventoryPickup.new()
	rejected_pickup.item = catalog.get_item(&"story.corked_bottle")
	rejected_pickup.instance_id = &"test.full_bag"
	rejected_body.add_child(rejected_pickup)
	assert(not rejected_pickup.try_interact(game.player))
	assert(not rejected_pickup.is_collected and rejected_body.visible,
		"Un sac plein ne doit jamais faire disparaître l'objet du monde")

	game.free()
	await process_frame
	print("Ramassage vérifié : transfert atomique, refus sac plein et persistance collectée.")
	quit()
