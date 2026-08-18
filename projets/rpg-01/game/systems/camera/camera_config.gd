@tool
class_name CameraConfig
extends Resource

@export_group("Cadrage de base")
@export var zoom := Vector2.ONE
@export var offset := Vector2.ZERO
@export var use_player_camera_anchor := true

@export_group("Suivi")
@export var position_smoothing_enabled := true
@export_range(0.1, 20.0, 0.1) var position_smoothing_speed := 7.0
@export var pixel_snap_target := true
## Arrondit la position finale après le lissage. Le suivi reste doux, mais la
## caméra ne termine jamais entre deux pixels du viewport logique.
@export var pixel_perfect_motion := true
@export_range(0.0, 96.0, 1.0, "suffix:px") var look_ahead_distance := 18.0
@export_range(0.1, 20.0, 0.1) var look_ahead_response := 5.0

@export_group("Zones caméra")
@export_range(0.1, 20.0, 0.1) var zoom_transition_speed := 5.0
## Refuse les zooms fractionnaires non prévus par la direction artistique.
## En mode pixel-perfect, le zoom change directement entre les niveaux permis.
@export var pixel_perfect_zoom := true
@export var pixel_perfect_zoom_levels: Array[float] = [0.5, 1.0, 2.0]
