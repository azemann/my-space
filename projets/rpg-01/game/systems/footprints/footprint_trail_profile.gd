class_name FootprintTrailProfile
extends Resource

## Ressource éditable qui décrit une traînée d'empreintes sur un type de sol.
## Le contrôleur runtime ne porte aucune valeur visuelle en dur : changez ce
## profil dans l'Inspecteur pour réutiliser ou décliner l'effet.

@export_category("Scène d'empreinte")
@export var footprint_scene: PackedScene

@export_category("Surface")
@export var custom_data_name: StringName = &"terrain_kind"
@export var required_surface: StringName = &"wet_sand"

@export_category("Marche")
@export_range(4.0, 64.0, 1.0, "suffix:px") var step_distance := 18.0
@export_range(0.0, 100.0, 1.0, "suffix:px/s") var minimum_speed := 12.0
@export_range(0.0, 16.0, 0.5, "suffix:px") var lateral_foot_offset := 4.5
@export_range(1, 128, 1) var maximum_visible_footprints := 48
