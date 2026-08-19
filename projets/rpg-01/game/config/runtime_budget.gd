@tool
class_name RuntimeBudget
extends Resource

## Budget de conception global visible dans l'Inspecteur. Ces limites ne
## retirent aucune capacité de gameplay : elles empêchent seulement une carte
## ou un système de devenir coûteux sans que cela soit détecté.

@export_category("Fluidité cible")
## Nombre d'images par seconde visé par le jeu et utilisé par les contrôles de performance.
@export_range(30, 240, 1, "suffix:FPS") var target_fps := 60
## Temps maximal souhaité pour calculer une image. À 60 FPS, il vaut environ 16,67 ms.
@export_range(1.0, 33.4, 0.01, "suffix:ms") var frame_budget_ms := 16.67

@export_category("Complexité d'une carte")
## Nombre maximal conseillé de nœuds présents à l'exécution dans une carte.
@export_range(100, 5000, 10) var maximum_runtime_nodes := 500
## Nombre maximal d'objets pouvant être déclarés comme cibles de psychokinésie.
@export_range(1, 512, 1) var maximum_psychokinetic_targets := 128
## Nombre maximal de cibles inactives autorisées à exécuter du traitement chaque image.
@export_range(0, 64, 1) var maximum_idle_targets_processing := 4

@export_category("Effets temporaires")
## Nombre maximal d'empreintes conservées simultanément avant de recycler les plus anciennes.
@export_range(1, 256, 1) var maximum_visible_footprints := 48
