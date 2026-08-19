@tool
class_name PsychokinesisProfile
extends Resource

## Profil de gameplay partagé par les objets psychokinétiques. Il décrit leur
## réaction au pouvoir indépendamment de leur scène, collision et apparence.

## Types de réaction possibles : aucune prise, réaction seule ou déplacement complet.
enum Response { ANCHORED, REACTIVE, MOVABLE }
## Classes logiques utilisées pour comparer le poids d'un objet à la puissance acquise.
enum MassClass { LIGHT, MEDIUM, HEAVY, IMMENSE }

@export_category("Réponse psychokinétique")
## Définit si l'objet ignore le pouvoir, réagit seulement, ou peut être saisi et projeté.
@export var response := Response.ANCHORED
## Classe de masse utilisée par le contrôle, les effets et la progression du pouvoir.
@export var mass_class := MassClass.IMMENSE
## Matière logique de l'objet (bois, pierre, métal…), utilisable plus tard par les impacts et les sons.
@export var material: StringName = &"unknown"
## Autorise un futur système de dégâts à briser cet objet.
@export var breakable := false
## Niveau minimal du pouvoir nécessaire pour déplacer l'objet.
@export_range(0, 10, 1) var required_power := 0


## Indique si le niveau fourni autorise une prise et un déplacement complets.
func can_be_moved(power_level: int) -> bool:
	return response == Response.MOVABLE and power_level >= required_power


## Indique si l'objet doit au minimum réagir visuellement au pouvoir.
func can_react() -> bool:
	return response != Response.ANCHORED
