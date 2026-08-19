class_name DisplayController
extends Node

## Contrôleur d'affichage persistant.
## La résolution logique reste définie dans project.godot ; ce nœud ne change
## que le mode de la fenêtre physique.

## Taille physique restaurée lorsque le joueur quitte le plein écran.
@export var windowed_size := Vector2i(1280, 720)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	var fullscreen_shortcut := key_event.keycode == KEY_F11
	var alternate_shortcut := key_event.alt_pressed and key_event.keycode == KEY_ENTER
	if fullscreen_shortcut or alternate_shortcut:
		toggle_fullscreen()
		get_viewport().set_input_as_handled()


## Bascule entre le plein écran et la taille de fenêtre configurée.
func toggle_fullscreen() -> void:
	var current_mode := DisplayServer.window_get_mode()
	var is_fullscreen := current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(windowed_size)
		_center_window()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _center_window() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var usable_rect := DisplayServer.screen_get_usable_rect(screen)
	var centered_position := usable_rect.position + (usable_rect.size - windowed_size) / 2
	DisplayServer.window_set_position(centered_position)
