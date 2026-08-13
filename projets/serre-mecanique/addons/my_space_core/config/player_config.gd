class_name PlayerConfig
extends Resource

@export_group("Déplacement")
## Vitesse horizontale maximale au sol, en pixels par seconde.
@export var speed := 230.0
## Rapidité avec laquelle le joueur atteint ou quitte sa vitesse maximale au sol, en pixels par seconde carrée.
@export var acceleration := 1500.0
## Contrôle horizontal disponible en l'air. Une valeur faible rend les sauts plus engagés.
@export var air_acceleration := 900.0
## Impulsion verticale du saut en pixels par seconde. Dans Godot, une valeur plus négative fait sauter plus haut.
@export var jump_velocity := -440.0
## Accélération vers le bas en pixels par seconde carrée. Augmenter rend les chutes plus rapides et lourdes.
@export var gravity := 1250.0
## Vitesse verticale sur les objets `climbable`, en pixels par seconde.
@export var climb_speed := 150.0

@export_group("Tolérance")
## Temps en secondes pendant lequel un saut reste possible après avoir quitté le bord d'une plateforme.
@export var coyote_time := 0.11
## Temps en secondes pendant lequel un appui anticipé sur saut est mémorisé avant de toucher le sol.
@export var jump_buffer := 0.12
## Vitesse verticale appliquée lorsque saut est relâché tôt. Une valeur proche de zéro raccourcit davantage le saut.
@export var short_jump_velocity := -170.0
