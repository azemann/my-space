class_name SerreInputActions
extends RefCounted

const MOVE_LEFT := &"move_left"
const MOVE_RIGHT := &"move_right"
const JUMP := &"jump"
const CLIMB_UP := &"climb_up"
const CLIMB_DOWN := &"climb_down"
const WEAPON_PRIMARY := &"weapon_primary"
const ROPE_REEL_IN := &"rope_reel_in"
const ROPE_REEL_OUT := &"rope_reel_out"
const WEAPON_MENU := &"weapon_menu"
const WEAPON_CANCEL := &"weapon_cancel"
const WEAPON_HOLSTER := &"weapon_holster"
const RESPAWN := &"respawn"
const WEAPON_SLOT_PREFIX := "weapon_slot_"


static func weapon_slot(index: int) -> StringName:
	return StringName("%s%d" % [WEAPON_SLOT_PREFIX, index + 1])
