@tool
class_name PlayerConfig
extends Resource

## Réglages centraux du déplacement, des commandes, des animations et de
## l'interaction du joueur. Les modifier ici affecte toutes les scènes qui
## utilisent cette ressource.

@export_group("Déplacement")
## Vitesse normale du joueur, en pixels parcourus par seconde.
@export_range(1.0, 400.0, 1.0, "suffix:px/s") var walk_speed := 92.0
## Multiplicateur appliqué à la vitesse normale lorsque l'action de course est tenue.
@export_range(1.0, 3.0, 0.05) var run_multiplier := 1.45
## Rapidité avec laquelle le joueur atteint sa vitesse demandée.
@export_range(1.0, 3000.0, 10.0, "suffix:px/s²") var acceleration := 900.0
## Rapidité avec laquelle le joueur s'arrête quand la direction est relâchée.
@export_range(1.0, 3000.0, 10.0, "suffix:px/s²") var deceleration := 1200.0
## Petite zone ignorée autour du centre d'un joystick pour éviter les mouvements involontaires.
@export_range(0.0, 0.9, 0.01) var input_deadzone := 0.18

@export_group("Actions Input Map")
## Nom de l'action Input Map utilisée pour aller à gauche.
@export var move_left_action: StringName = &"move_left"
## Nom de l'action Input Map utilisée pour aller à droite.
@export var move_right_action: StringName = &"move_right"
## Nom de l'action Input Map utilisée pour aller vers le haut.
@export var move_up_action: StringName = &"move_up"
## Nom de l'action Input Map utilisée pour aller vers le bas.
@export var move_down_action: StringName = &"move_down"
## Nom de l'action Input Map qui active la course.
@export var run_action: StringName = &"run"
## Nom de l'action Input Map utilisée pour interagir avec le monde.
@export var interact_action: StringName = &"interact"

@export_group("Animation")
## Préfixe des animations immobiles, complété par la direction regardée.
@export var idle_prefix: StringName = &"idle"
## Préfixe des animations de marche, complété par la direction regardée.
@export var walk_prefix: StringName = &"walk"
## Vitesse minimale nécessaire pour passer de l'animation immobile à la marche.
@export_range(0.0, 20.0, 0.1, "suffix:px/s") var animation_velocity_threshold := 2.0

@export_group("Interaction")
## Distance devant le joueur à laquelle une interaction peut détecter un objet.
@export_range(4.0, 64.0, 1.0, "suffix:px") var interaction_distance := 20.0
