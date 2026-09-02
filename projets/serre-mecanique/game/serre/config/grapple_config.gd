class_name GrappleConfig
extends Resource

@export_group("Corde")
## Portée maximale du tir et longueur maximale de la corde, en pixels.
@export var max_distance := 480.0
## Longueur minimale autorisée. Empêche le joueur de remonter exactement dans le point d'ancrage.
@export var min_length := 42.0
## Nombre de pixels de corde ajoutés ou retirés par seconde avec les commandes Z/S.
@export var reel_speed := 170.0

@export_group("Sensations")
## Force tangentielle donnée par gauche/droite pendant le balancement. Augmenter facilite la prise d'élan.
@export var swing_acceleration := 920.0
## Limite de vitesse totale pendant l'utilisation du grappin, en pixels par seconde.
@export var maximum_speed := 760.0
## Angle de tir de secours en degrés lorsque la souris ne fournit aucune direction valide.
@export var launch_fallback_angle := -35.0

@export_group("Affichage")
## Couleur de la corde dessinée par le Player.
@export var rope_color := Color("#c89748")
## Épaisseur visuelle de la corde en pixels. Ne modifie pas sa physique.
@export var rope_width := 2.0
