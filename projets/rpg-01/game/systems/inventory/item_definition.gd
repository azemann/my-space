class_name ItemDefinition
extends Resource

## Décrit un type d'objet immuable partagé par le monde, l'inventaire et l'UI.
## Les quantités et états propres à une instance ne vivent jamais ici.

@export_category("Identité")
## Identifiant stable utilisé dans les sauvegardes ; ne doit jamais dépendre du nom affiché.
@export var item_id: StringName
## Nom présenté au joueur.
@export var display_name := "Objet"
## Description courte présentée dans les menus.
@export_multiline var description := ""
## Icône facultative affichée dans les emplacements d'inventaire.
@export var icon: Texture2D

@export_category("Règles d'inventaire")
## Famille fonctionnelle servant au tri et au filtrage de l'interface.
@export var category: StringName = &"misc"
## Quantité maximale regroupée dans un même emplacement.
@export_range(1, 999, 1) var max_stack := 1
## Étiquettes extensibles telles que consumable, material, quest ou equipment.
@export var tags: Array[StringName] = []
## Autorise la création future d'une instance de monde depuis cet objet.
@export var can_drop := true


## Vérifie les invariants qui rendent cette définition sûre à sérialiser.
func is_valid() -> bool:
	return not str(item_id).is_empty() and not display_name.strip_edges().is_empty() and max_stack >= 1
