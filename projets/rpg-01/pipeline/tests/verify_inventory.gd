extends SceneTree

## Vérifie le contrat atomique, sérialisable et persistant de l'inventaire.

const MAIN_SCENE := "res://game/core/main.tscn"
const BEACH_SCENE := "res://game/world/maps/plage-du-reveil/plage-du-reveil.tscn"
const CATALOG_PATH := "res://game/content/items/catalog.tres"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog := load(CATALOG_PATH) as ItemCatalog
	var metal := catalog.get_item(&"material.metal_fragment")
	var bottle := catalog.get_item(&"story.corked_bottle")
	assert(metal != null and metal.max_stack == 20)
	assert(bottle != null and bottle.max_stack == 1 and not bottle.can_drop)

	var inventory := InventoryComponent.new()
	inventory.capacity = 2
	inventory.catalog = catalog
	root.add_child(inventory)
	assert(inventory.slots.size() == 2)
	assert(inventory.add(metal, 25).succeeded())
	assert(inventory.get_slot(0).quantity == 20)
	assert(inventory.get_slot(1).quantity == 5)

	var before_rejection := inventory.capture_state()
	var rejected := inventory.add(metal, 16)
	assert(rejected.code == InventoryTransaction.Code.INSUFFICIENT_SPACE)
	assert(inventory.capture_state() == before_rejection, "Un refus ne doit jamais modifier le sac")

	assert(inventory.remove(metal.item_id, 6).succeeded())
	assert(inventory.amount_of(metal.item_id) == 19)
	assert(inventory.get_slot(0).quantity == 19 and inventory.get_slot(1) == null)
	assert(inventory.add(bottle, 1, &"bottle.beach.001").succeeded())
	assert(inventory.get_slot(1).instance_id == &"bottle.beach.001")
	assert(inventory.add(bottle, 1, &"bottle.beach.001").code == InventoryTransaction.Code.DUPLICATE_INSTANCE)

	var saved := inventory.capture_state()
	var restored := InventoryComponent.new()
	restored.capacity = 2
	restored.catalog = catalog
	root.add_child(restored)
	assert(restored.restore_state(saved))
	assert(restored.amount_of(metal.item_id) == 19)
	assert(restored.get_slot(1).instance_id == &"bottle.beach.001")

	var game := (load(MAIN_SCENE) as PackedScene).instantiate() as GameRoot
	root.add_child(game)
	await process_frame
	await physics_frame
	assert(game.player.inventory != null and game.player.inventory.capacity == 20)
	assert(game.inventory_panel.inventory == game.player.inventory)
	assert(game.player.inventory.add(metal, 3).succeeded())
	game._input(_action(&"inventory"))
	assert(game.inventory_panel.is_open())
	assert(game.inventory_panel.position == Vector2.ZERO,
		"Le panneau d'inventaire doit rester ancré en haut à gauche du viewport")
	assert(game.inventory_panel.size == game.inventory_panel.get_viewport_rect().size,
		"Le panneau d'inventaire doit couvrir exactement le viewport")
	assert(game.inventory_panel.panel_background.texture == game.inventory_panel.config.panel_texture,
		"Le fond visuel doit venir de la ressource de configuration de l'inventaire")
	game.inventory_panel.config.columns = 4
	game.inventory_panel.config.outer_margin_horizontal = 200
	game.inventory_panel.config.emit_changed()
	assert(game.inventory_panel.grid.columns == 4, "Les colonnes doivent suivre la ressource UI")
	var configured_margin := game.inventory_panel.get_node("Margin") as MarginContainer
	assert(configured_margin.offset_left >= 0.0)
	assert(configured_margin.offset_left - configured_margin.offset_right < game.inventory_panel.size.x,
		"Une marge configurable ne doit jamais rogner tout le panneau")
	assert(not game.player.controls_enabled and not game.psychokinesis.controls_enabled)
	game._unhandled_input(_action(&"pause"))
	assert(not game.inventory_panel.is_open())
	assert(game.player.controls_enabled and game.psychokinesis.controls_enabled)

	var persistent_inventory := game.player.inventory
	# Ce test isole la persistance de l'acteur ; l'état des objets de carte est
	# couvert séparément par verify_world_state.gd.
	game.world_state.enabled = false
	await game.change_map(load(BEACH_SCENE) as PackedScene, &"beach-awakening")
	assert(game.player.inventory == persistent_inventory)
	assert(game.player.inventory.amount_of(metal.item_id) == 3)

	inventory.free()
	restored.free()
	game.free()
	await process_frame
	print("Inventaire vérifié : transactions atomiques, objet unique, UI et persistance de carte.")
	call_deferred("_finish")


func _finish() -> void:
	await process_frame
	await process_frame
	quit()


func _action(action: StringName) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event
