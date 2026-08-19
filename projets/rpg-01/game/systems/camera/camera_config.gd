@tool
class_name CameraConfig
extends Resource

## Réglages partagés de la caméra du joueur : cadrage, suivi, anticipation et
## contraintes pixel-perfect.

@export_group("Cadrage de base")
## Agrandissement de base de la caméra sur les axes horizontal et vertical.
@export var zoom := Vector2.ONE
## Décalage visuel fixe ajouté au centre de la caméra.
@export var offset := Vector2.ZERO
## Suit le point d'ancrage CameraAnchor du joueur plutôt que son origine physique.
@export var use_player_camera_anchor := true

@export_group("Suivi")
## Active une transition progressive au lieu de coller instantanément à la cible.
@export var position_smoothing_enabled := true
## Vitesse avec laquelle la caméra rattrape sa cible lorsque le lissage est actif.
@export_range(0.1, 20.0, 0.1) var position_smoothing_speed := 7.0
## Arrondit la position de la cible au pixel logique avant de la suivre.
@export var pixel_snap_target := true
## Arrondit la position finale après le lissage. Le suivi reste doux, mais la
## caméra ne termine jamais entre deux pixels du viewport logique.
@export var pixel_perfect_motion := true
## Distance maximale regardée en avance dans la direction du déplacement.
@export_range(0.0, 96.0, 1.0, "suffix:px") var look_ahead_distance := 18.0
## Rapidité avec laquelle l'anticipation apparaît et revient au centre.
@export_range(0.1, 20.0, 0.1) var look_ahead_response := 5.0

@export_group("Zones caméra")
## Vitesse de transition vers le zoom demandé par une zone caméra.
@export_range(0.1, 20.0, 0.1) var zoom_transition_speed := 5.0
## Refuse les zooms fractionnaires non prévus par la direction artistique.
## En mode pixel-perfect, le zoom change directement entre les niveaux permis.
@export var pixel_perfect_zoom := true
## Niveaux de zoom autorisés quand le zoom pixel-perfect est actif.
@export var pixel_perfect_zoom_levels: Array[float] = [0.5, 1.0, 2.0]
