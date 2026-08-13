class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal damaged(amount: int)
signal depleted

## Quantité de vie au démarrage et après une réinitialisation. À zéro, le personnage réapparaît avec sa vie restaurée.
@export_range(1, 10000, 1, "or_greater") var maximum_health := 100
var current_health := 100


func _ready() -> void:
	current_health = maximum_health
	health_changed.emit(current_health, maximum_health)


func apply_damage(amount: int) -> int:
	var applied := mini(maxi(amount, 0), current_health)
	if applied == 0:
		return 0
	current_health -= applied
	damaged.emit(applied)
	health_changed.emit(current_health, maximum_health)
	if current_health == 0:
		depleted.emit()
	return applied


func heal(amount: int) -> int:
	var previous := current_health
	current_health = mini(maximum_health, current_health + maxi(amount, 0))
	if current_health != previous:
		health_changed.emit(current_health, maximum_health)
	return current_health - previous


func reset() -> void:
	current_health = maximum_health
	health_changed.emit(current_health, maximum_health)
