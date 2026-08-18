@tool
class_name RuntimeBudget
extends Resource

## Budget de conception global visible dans l'Inspecteur. Ces limites ne
## retirent aucune capacité de gameplay : elles empêchent seulement une carte
## ou un système de devenir coûteux sans que cela soit détecté.

@export_category("Fluidité cible")
@export_range(30, 240, 1, "suffix:FPS") var target_fps := 60
@export_range(1.0, 33.4, 0.01, "suffix:ms") var frame_budget_ms := 16.67

@export_category("Complexité d'une carte")
@export_range(100, 5000, 10) var maximum_runtime_nodes := 500
@export_range(1, 512, 1) var maximum_psychokinetic_targets := 128
@export_range(0, 64, 1) var maximum_idle_targets_processing := 4

@export_category("Effets temporaires")
@export_range(1, 256, 1) var maximum_visible_footprints := 48
