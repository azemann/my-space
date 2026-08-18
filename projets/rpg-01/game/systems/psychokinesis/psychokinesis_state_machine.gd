class_name PsychokinesisStateMachine
extends Node

signal state_changed(previous: State, current: State)

enum State {
	IDLE,
	TARGETED,
	ATTRACTED,
	HELD,
	CHARGING,
	THROWN,
	LANDING,
}

@export var initial_state := State.IDLE

var state := State.IDLE


func _ready() -> void:
	state = initial_state


func transition(next_state: State) -> bool:
	if next_state == state:
		return true
	if not _is_transition_allowed(state, next_state):
		push_warning("Transition psychokinétique refusée : %s -> %s" % [state_name(state), state_name(next_state)])
		return false
	var previous := state
	state = next_state
	state_changed.emit(previous, state)
	return true


func reset() -> void:
	var previous := state
	state = State.IDLE
	if previous != state:
		state_changed.emit(previous, state)


func is_controlled() -> bool:
	return state in [State.ATTRACTED, State.HELD, State.CHARGING]


func is_airborne() -> bool:
	return state in [State.ATTRACTED, State.HELD, State.CHARGING, State.THROWN, State.LANDING]


static func state_name(value: State) -> String:
	return State.keys()[value].to_lower()


static func _is_transition_allowed(previous_state: State, next_state: State) -> bool:
	match previous_state:
		State.IDLE:
			return next_state in [State.TARGETED, State.ATTRACTED, State.HELD]
		State.TARGETED:
			return next_state in [State.IDLE, State.ATTRACTED, State.HELD]
		State.ATTRACTED:
			return next_state in [State.IDLE, State.HELD, State.LANDING]
		State.HELD:
			return next_state in [State.CHARGING, State.LANDING, State.THROWN]
		State.CHARGING:
			return next_state in [State.HELD, State.LANDING, State.THROWN]
		State.THROWN:
			return next_state == State.LANDING
		State.LANDING:
			return next_state in [State.IDLE, State.TARGETED, State.ATTRACTED, State.HELD]
	return false
