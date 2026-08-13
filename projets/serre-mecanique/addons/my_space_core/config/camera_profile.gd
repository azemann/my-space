class_name CameraProfile
extends Resource

## Décalage de cadrage par rapport au joueur. Un Y négatif montre davantage la zone au-dessus.
@export var offset := Vector2(0, -80)
## Active une interpolation douce au lieu de coller instantanément au joueur.
@export var smoothing_enabled := true
## Vitesse de rattrapage de la caméra. Une valeur élevée répond plus vite mais paraît moins souple.
@export var smoothing_speed := 7.0
## Rectangle mondial que la caméra ne peut pas dépasser : position puis largeur/hauteur.
@export var limits := Rect2i(0, 0, 1600, 768)
