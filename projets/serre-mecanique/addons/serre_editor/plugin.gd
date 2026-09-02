@tool
extends EditorPlugin

const Converter = preload("res://addons/tiled_level_pipeline/tiled_converter.gd")
const Profile = preload("res://game/serre/tiled/serre_tiled_profile.gd")

const LEVELS := [
	{
		"title": "Niveau 1 — La galerie d'irrigation",
		"status": "FIGÉ · scène Godot conservée",
		"status_color": Color("#8fd6a9"),
		"source": "res://maps/niveau-01-serre.tmx",
		"scene": "res://scenes/levels/niveau-01-serre.tscn",
		"launcher": "res://scenes/launchers/niveau-01.tscn",
		"help": "Les changements enregistrés dans sa scène restent en place. La régénération l'ignore.",
	},
	{
		"title": "Niveau 2 — La chambre des racines",
		"status": "GÉNÉRÉ · source Tiled",
		"status_color": Color("#e3b966"),
		"source": "res://maps/niveau-02-racines.tmx",
		"scene": "res://scenes/levels/niveau-02-racines.tscn",
		"launcher": "res://scenes/launchers/niveau-02.tscn",
		"help": "Modifier le TMX, puis régénérer. Ne pas modifier directement la scène de niveau générée.",
	},
	{
		"title": "Niveau 3 — La nef des automates",
		"status": "GÉNÉRÉ · tileset dédié",
		"status_color": Color("#e3b966"),
		"source": "res://maps/niveau-03-automates.tmx",
		"scene": "res://scenes/levels/niveau-03-automates.tscn",
		"launcher": "res://scenes/launchers/niveau-03.tscn",
		"help": "Ce niveau utilise un atlas de production 16 × 5. Modifier son TMX, puis régénérer.",
	},
	{
		"title": "Niveau 4 — L'arène des semences",
		"status": "GÉNÉRÉ · arène Tiled · test solo",
		"status_color": Color("#e3b966"),
		"source": "res://maps/niveau-04-arene-parcours.tmx",
		"scene": "res://scenes/levels/niveau-04-arene-parcours.tscn",
		"launcher": "res://scenes/launchers/niveau-04.tscn",
		"help": "Le parkour et quatre apparitions sont préparés. Le bouton Tester utilise encore un seul joueur.",
	},
]

var manager_dock: VBoxContainer
var confirmation: ConfirmationDialog
var feedback_label: Label


func _enter_tree() -> void:
	add_tool_menu_item("Serre · Régénérer les niveaux Tiled…", _request_regeneration)
	_build_manager_dock()
	_build_confirmation_dialog()


func _exit_tree() -> void:
	remove_tool_menu_item("Serre · Régénérer les niveaux Tiled…")
	if is_instance_valid(manager_dock):
		remove_control_from_docks(manager_dock)
		manager_dock.queue_free()
	if is_instance_valid(confirmation):
		confirmation.queue_free()


func _build_manager_dock() -> void:
	manager_dock = VBoxContainer.new()
	manager_dock.name = "Serre"
	manager_dock.custom_minimum_size = Vector2(290, 0)

	var heading := Label.new()
	heading.text = "GESTION DES NIVEAUX"
	heading.add_theme_font_size_override("font_size", 16)
	manager_dock.add_child(heading)

	var rule := Label.new()
	rule.text = "Vert = conservé dans Godot\nOrange = régénéré depuis Tiled"
	rule.modulate = Color("#b8c7c0")
	manager_dock.add_child(rule)
	manager_dock.add_child(HSeparator.new())

	for level in LEVELS:
		_build_level_section(level)

	var regenerate := Button.new()
	regenerate.text = "Régénérer les niveaux Tiled…"
	regenerate.tooltip_text = "Une confirmation rappelle exactement quelles scènes seront remplacées."
	regenerate.pressed.connect(_request_regeneration)
	manager_dock.add_child(regenerate)

	feedback_label = Label.new()
	feedback_label.text = "Prêt. Le niveau 1 est protégé."
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.modulate = Color("#9fb3aa")
	manager_dock.add_child(feedback_label)

	add_control_to_dock(DOCK_SLOT_LEFT_BR, manager_dock)


func _build_level_section(level: Dictionary) -> void:
	var title := Label.new()
	title.text = str(level.title)
	title.add_theme_font_size_override("font_size", 14)
	manager_dock.add_child(title)

	var status := Label.new()
	status.text = str(level.status)
	status.modulate = level.status_color
	manager_dock.add_child(status)

	var help := Label.new()
	help.text = str(level.help)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.modulate = Color("#b8c7c0")
	manager_dock.add_child(help)

	var buttons := HBoxContainer.new()
	var test_button := Button.new()
	test_button.text = "Tester ▶"
	test_button.tooltip_text = "Lancer avec le joueur : %s" % str(level.launcher)
	test_button.pressed.connect(_play_scene.bind(str(level.launcher)))
	buttons.add_child(test_button)

	var scene_button := Button.new()
	scene_button.text = "Scène"
	scene_button.tooltip_text = str(level.scene)
	scene_button.pressed.connect(_open_scene.bind(str(level.scene)))
	buttons.add_child(scene_button)

	var source_button := Button.new()
	source_button.text = "Source"
	source_button.tooltip_text = str(level.source)
	source_button.pressed.connect(_show_source.bind(str(level.source)))
	buttons.add_child(source_button)
	manager_dock.add_child(buttons)
	manager_dock.add_child(HSeparator.new())


func _build_confirmation_dialog() -> void:
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Régénérer les niveaux Tiled"
	confirmation.ok_button_text = "Régénérer les niveaux 2, 3 et 4"
	confirmation.cancel_button_text = "Annuler"
	confirmation.dialog_text = (
		"Cette opération va remplacer :\n"
		+ "• scenes/levels/niveau-02-racines.tscn\n"
		+ "• resources/tilesets/niveau-02-racines.tres\n"
		+ "• resources/levels/niveau-02-racines-data.tres\n\n"
		+ "• scenes/levels/niveau-03-automates.tscn\n"
		+ "• resources/tilesets/niveau-03-automates.tres\n"
		+ "• resources/levels/niveau-03-automates-data.tres\n\n"
		+ "• scenes/levels/niveau-04-arene-parcours.tscn\n"
		+ "• resources/tilesets/niveau-04-arene-parcours.tres\n"
		+ "• resources/levels/niveau-04-arene-parcours-data.tres\n\n"
		+ "Le niveau 1 est figé et sera ignoré.\n"
		+ "Les modifications doivent être enregistrées dans le TMX avant de continuer."
	)
	confirmation.confirmed.connect(_regenerate_levels)
	EditorInterface.get_base_control().add_child(confirmation)


func _request_regeneration() -> void:
	confirmation.popup_centered(Vector2i(650, 300))


func _open_scene(path: String) -> void:
	if not FileAccess.file_exists(path):
		feedback_label.text = "Fichier introuvable : %s" % path
		feedback_label.modulate = Color("#ff7777")
		return
	EditorInterface.open_scene_from_path(path)
	feedback_label.text = "Scène ouverte : %s" % path.get_file()
	feedback_label.modulate = Color("#9fb3aa")


func _play_scene(path: String) -> void:
	if not FileAccess.file_exists(path):
		feedback_label.text = "Scène de test introuvable : %s" % path
		feedback_label.modulate = Color("#ff7777")
		return
	EditorInterface.play_custom_scene(path)
	feedback_label.text = "Test lancé avec le joueur : %s" % path.get_file()
	feedback_label.modulate = Color("#8fd6a9")


func _show_source(path: String) -> void:
	EditorInterface.get_file_system_dock().navigate_to_path(path)
	feedback_label.text = "Source sélectionnée : %s" % path.get_file()
	feedback_label.modulate = Color("#9fb3aa")


func _regenerate_levels() -> void:
	feedback_label.text = "Régénération en cours…"
	feedback_label.modulate = Color("#e3b966")
	var result := Converter.convert_all(Profile)
	EditorInterface.get_resource_filesystem().scan()
	if result == OK:
		for level in LEVELS:
			if str(level.status).begins_with("FIGÉ"):
				continue
			var scene_path := str(level.scene)
			# Remplace aussi les ressources déjà présentes dans le cache de
			# l'éditeur, notamment lorsqu'un lanceur de niveau est resté ouvert.
			ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
			EditorInterface.reload_scene_from_path(scene_path)
		feedback_label.text = "Niveaux 2, 3 et 4 régénérés. Niveau 1 inchangé."
		feedback_label.modulate = Color("#8fd6a9")
		print("Import Tiled terminé: scènes et ressources natives actualisées.")
	else:
		feedback_label.text = "Échec de la régénération : code %s" % result
		feedback_label.modulate = Color("#ff7777")
		push_error("L'import Tiled a échoué avec le code %s." % result)
