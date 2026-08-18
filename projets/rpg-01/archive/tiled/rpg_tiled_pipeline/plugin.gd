@tool
extends EditorPlugin

const Converter = preload("res://addons/rpg_tiled_pipeline/tiled_converter.gd")
const Profile = preload("res://game/rpg/tiled/rpg_tiled_profile.gd")
const TMX_PATH := "res://maps/world-01.tmx"
const GENERATED_SCENE := "res://scenes/levels/generated/world-01.tscn"
const GENERATED_TILESET := "res://resources/tilesets/generated/world-01.tres"
const PIPELINE_INPUTS := [
	TMX_PATH,
	"res://maps/tilesets/world-terrain.tsx",
	"res://maps/tilesets/world-objects.tsx",
	"res://assets/tilesets/world-terrain.png",
	"res://assets/tilesets/world-objects.png",
]

var _dock: VBoxContainer
var _status: Label
var _tree: Tree


func _enter_tree() -> void:
	_dock = VBoxContainer.new()
	_dock.name = "Pipeline RPG"
	_dock.tooltip_text = "Pilote les correspondances entre la carte Tiled et les nœuds Godot générés."
	var title := Label.new()
	title.text = "Tiled ↔ Godot"
	title.tooltip_text = "Tiled compose l'espace ; Godot reste le cockpit du jeu et du pipeline."
	_dock.add_child(title)
	var help := Label.new()
	help.text = "Survolez une ligne pour connaître son contrat."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.tooltip_text = "Chaque correspondance possède une description issue du profil RPG."
	_dock.add_child(help)
	var entry := Label.new()
	entry.text = "FONDATION VIDE — aucune scène de jeu"
	entry.tooltip_text = "Le prototype a été retiré. Le pipeline est conservé comme méthode avant le premier vrai contrat jouable."
	_dock.add_child(entry)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dock.add_child(_status)
	var actions := HBoxContainer.new()
	_dock.add_child(actions)
	var regenerate_button := _add_button(actions, "Régénérer", "Disponible lorsqu'une première source TMX aura été créée.", _regenerate)
	var tiled_button := _add_button(actions, "Tiled", "Disponible lorsqu'une première source TMX aura été créée.", _open_tiled)
	var derived_button := _add_button(actions, "Dérivé", "Disponible après la première génération réussie.", _open_generated_scene)
	regenerate_button.disabled = not FileAccess.file_exists(TMX_PATH)
	tiled_button.disabled = not FileAccess.file_exists(TMX_PATH)
	derived_button.disabled = not FileAccess.file_exists(GENERATED_SCENE)
	_tree = Tree.new()
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.columns = 5
	_tree.hide_root = true
	_tree.column_titles_visible = true
	_tree.set_column_title(0, "Groupe")
	_tree.set_column_title(1, "Tiled")
	_tree.set_column_title(2, "Godot")
	_tree.set_column_title(3, "Rôle")
	_tree.set_column_title(4, "État")
	_dock.add_child(_tree)
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _dock)
	_refresh()


func _exit_tree() -> void:
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()


func _add_button(parent: Control, label: String, tooltip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.tooltip_text = tooltip
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _refresh() -> void:
	if not is_instance_valid(_tree):
		return
	_tree.clear()
	var root := _tree.create_item()
	for group_name in ["Terrain", "Water", "Relief", "Architecture", "Decoration"]:
		for layer_name in Profile.TILE_GROUPS:
			if str(Profile.TILE_GROUPS[layer_name]) == group_name:
				_add_mapping(root, group_name, str(layer_name), "TileMapLayer", "visuel")
	for layer_name in Profile.OBJECT_GROUPS:
		_add_mapping(root, "Gameplay", str(layer_name), _godot_type(str(Profile.OBJECT_GROUPS[layer_name])), str(Profile.OBJECT_GROUPS[layer_name]))
	var source_ok := FileAccess.file_exists(TMX_PATH)
	var generated_ok := FileAccess.file_exists(GENERATED_SCENE)
	_status.text = "Source TMX : %s\nScène générée : %s\nPipeline : %s" % ["prête" if source_ok else "absente", "prête" if generated_ok else "absente", _pipeline_state()]
	_status.tooltip_text = "Source : %s\nDérivé : %s" % [TMX_PATH, GENERATED_SCENE]


func _add_mapping(root: TreeItem, group_name: String, tiled_name: String, godot_type: String, role: String) -> void:
	var item := _tree.create_item(root)
	item.set_text(0, group_name)
	item.set_text(1, tiled_name)
	item.set_text(2, godot_type)
	item.set_text(3, role)
	item.set_text(4, _pipeline_state())
	var description := Profile.description(tiled_name)
	for column in range(5):
		item.set_tooltip_text(column, "%s\n\nTiled : %s/%s\nGodot : %s\nÉtat : %s" % [description, group_name, tiled_name, godot_type, _pipeline_state()])
	if _pipeline_state() == "à régénérer":
		item.set_custom_color(4, Color(1.0, 0.68, 0.2))
	elif _pipeline_state() == "à jour":
		item.set_custom_color(4, Color(0.45, 0.9, 0.55))


func _pipeline_state() -> String:
	if not FileAccess.file_exists(TMX_PATH):
		return "source absente"
	if not FileAccess.file_exists(GENERATED_SCENE) or not FileAccess.file_exists(GENERATED_TILESET):
		return "dérivé absent"
	var source_time := 0
	for path in PIPELINE_INPUTS:
		if not FileAccess.file_exists(path):
			return "entrée absente"
		source_time = maxi(source_time, FileAccess.get_modified_time(path))
	var generated_time := mini(FileAccess.get_modified_time(GENERATED_SCENE), FileAccess.get_modified_time(GENERATED_TILESET))
	return "à régénérer" if source_time > generated_time else "à jour"


func _godot_type(role: String) -> String:
	match role:
		"collision": return "StaticBody2D"
		"navigation": return "NavigationRegion2D"
		"spawn": return "Marker2D"
		_: return "Area2D / scène"


func _regenerate() -> void:
	if not FileAccess.file_exists(TMX_PATH):
		_status.text = "Aucune source TMX : le projet est volontairement vide."
		return
	_status.text = "Conversion en cours…"
	var error := Converter.convert_map(TMX_PATH, Profile)
	if error != OK:
		_status.text = "Échec : %s" % error_string(error)
		push_error("Pipeline RPG : %s" % error_string(error))
		return
	get_editor_interface().get_resource_filesystem().scan()
	_status.text = "Conversion terminée. Les dérivés Godot sont à jour."
	_refresh.call_deferred()


func _open_tiled() -> void:
	if not FileAccess.file_exists(TMX_PATH):
		_status.text = "Aucune carte à ouvrir : définir d'abord le premier contrat jouable."
		return
	var absolute_tmx := ProjectSettings.globalize_path(TMX_PATH)
	var pid := OS.create_process("/usr/bin/flatpak", ["run", "org.mapeditor.Tiled", absolute_tmx])
	if pid <= 0:
		_status.text = "Impossible d'ouvrir Tiled. Source : %s" % absolute_tmx


func _open_generated_scene() -> void:
	if not FileAccess.file_exists(GENERATED_SCENE):
		_status.text = "La scène doit d'abord être régénérée."
		return
	get_editor_interface().open_scene_from_path(GENERATED_SCENE)
