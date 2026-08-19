class_name PsychokinesisStateMachine
extends Node

## Automate qui protège le cycle de vie d'un objet psychokinétique contre les
## transitions impossibles entre repos, prise, charge, projection et chute.

## Émis après chaque transition valide entre deux états.
signal state_changed(previous: State, current: State)

## États successifs possibles d'une interaction psychokinétique.
enum State {
	IDLE,
	TARGETED,
	ATTRACTED,
	HELD,
	CHARGING,
	THROWN,
	LANDING,
}

## État appliqué lorsque le composant entre dans l'arbre de scène.
@export var initial_state := State.IDLE

var state := State.IDLE


func _ready() -> void:
	state = initial_state


## Tente une transition et renvoie false si le passage demandé est interdit.
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


## Revient à l'état de repos et émet le changement si nécessaire.
func reset() -> void:
	var previous := state
	state = State.IDLE
	if previous != state:
		state_changed.emit(previous, state)


## Indique si l'objet est actuellement attiré, tenu ou en charge.
func is_controlled() -> bool:
	return state in [State.ATTRACTED, State.HELD, State.CHARGING]


## Indique si l'objet est projeté ou en phase d'atterrissage.
func is_airborne() -> bool:
	return state in [State.ATTRACTED, State.HELD, State.CHARGING, State.THROWN, State.LANDING]


## Donne un nom lisible à une valeur d'état pour les diagnostics.
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
