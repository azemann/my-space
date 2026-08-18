class_name WorldObjectSceneRegistry
extends RefCounted

## Registre canonique des objets de gameplay plaçables dans les cartes.
##
## Tiled choisit un type et une position. Godot reste l'autorité sur l'arbre de
## nœuds, les scripts, la physique et les composants réutilisables.

const PSYCHOKINETIC_PROP := &"psychokinetic_prop"
const PSYCHOKINETIC_PROP_PATH := "res://game/world/objects/psychokinetic_prop.tscn"

const SCENES := {
	PSYCHOKINETIC_PROP: preload(PSYCHOKINETIC_PROP_PATH),
}


static func has_scene(kind: StringName) -> bool:
	return SCENES.has(kind)


static func instantiate(kind: StringName) -> Node2D:
	var packed := SCENES.get(kind) as PackedScene
	if packed == null:
		push_error("Scène d'objet Godot non enregistrée : %s" % kind)
		return null
	return packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node2D


static func scene_path(kind: StringName) -> String:
	var packed := SCENES.get(kind) as PackedScene
	return packed.resource_path if packed != null else ""
