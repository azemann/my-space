class_name InteractionConfig
extends Resource

## Aptitude de la zone : danger, ressort, checkpoint, sortie, objet à collecter ou interaction.
@export_enum("hazard", "bounce", "checkpoint", "exit", "collectible", "interactable") var kind := "interactable"
## Points de vie retirés par une zone de danger.
@export var damage := 0
## Impulsion verticale d'un ressort. Une valeur plus négative projette plus haut.
@export var impulse_y := -620.0
## Si vrai, un danger replace immédiatement le joueur à son point d'apparition.
@export var respawn := false
## Identifiant de l'objet ou de l'événement visé par une interaction.
@export var target := ""
## Identifiant ou chemin du niveau demandé par une sortie.
@export var next_level := ""
## Quantité ou score accordé par un objet à collecter.
@export var value := 0
