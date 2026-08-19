class_name FootprintTrailProfile
extends Resource

## Ressource éditable qui décrit une traînée d'empreintes sur un type de sol.
## Le contrôleur runtime ne porte aucune valeur visuelle en dur : changez ce
## profil dans l'Inspecteur pour réutiliser ou décliner l'effet.

@export_category("Scène d'empreinte")
## Scène instanciée à chaque pas pour afficher une empreinte au sol.
@export var footprint_scene: PackedScene

@export_category("Surface")
## Nom de la donnée personnalisée du TileSet qui décrit la nature du terrain.
@export var custom_data_name: StringName = &"terrain_kind"
## Valeur que la donnée de terrain doit posséder pour autoriser une empreinte.
@export var required_surface: StringName = &"wet_sand"

@export_category("Marche")
## Distance parcourue entre la création de deux empreintes successives.
@export_range(4.0, 64.0, 1.0, "suffix:px") var step_distance := 18.0
## Vitesse minimale du personnage avant que les empreintes commencent à apparaître.
@export_range(0.0, 100.0, 1.0, "suffix:px/s") var minimum_speed := 12.0
## Décalage latéral alterné qui sépare visuellement le pied gauche du pied droit.
@export_range(0.0, 16.0, 0.5, "suffix:px") var lateral_foot_offset := 4.5
## Nombre maximal d'empreintes affichées avant de retirer les plus anciennes.
@export_range(1, 128, 1) var maximum_visible_footprints := 48
