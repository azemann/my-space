class_name PsychokinesisTargetDetector
extends Node

## Service de recherche et de classement des objets psychokinétiques. Il tient
## compte de la portée, de la puissance, du pointeur et de l'ordre d'affichage.


## Renvoie toutes les cibles saisissables situées dans la portée du joueur.
func nearby_targets(player: PlayerController, acquisition_range: float, power_level: int) -> Array[PsychokineticBody2D]:
	var result: Array[PsychokineticBody2D] = []
	if player == null:
		return result
	for node in get_tree().get_nodes_in_group(&"psychokinetic_targets"):
		var body := node as PsychokineticBody2D
		if is_available(body, player, acquisition_range, power_level):
			result.append(body)
	return result


## Choisit parmi les zones qui signalent actuellement un survol natif Godot.
func find_native_hover(
	player: PlayerController,
	acquisition_range: float,
	power_level: int,
	pointer_world_position: Vector2
) -> PsychokineticBody2D:
	var result: PsychokineticBody2D
	for body in nearby_targets(player, acquisition_range, power_level):
		if not body.is_pointer_over:
			continue
		if result == null or is_drawn_in_front(body, result, pointer_world_position):
			result = body
	return result


## Cherche la meilleure collision de sélection sous un point mondial précis.
func find_at_world_point(
	pointer_world_position: Vector2,
	player: PlayerController,
	acquisition_range: float,
	power_level: int
) -> PsychokineticBody2D:
	var result: PsychokineticBody2D
	for body in nearby_targets(player, acquisition_range, power_level):
		if not body.selection_contains_point(pointer_world_position):
			continue
		if result == null or is_drawn_in_front(body, result, pointer_world_position):
			result = body
	return result


## Choisit la cible la plus cohérente avec une direction de visée à la manette.
func find_directional(
	player: PlayerController,
	acquisition_range: float,
	power_level: int,
	aim_direction: Vector2
) -> PsychokineticBody2D:
	if player == null:
		return null
	var direction := aim_direction.normalized()
	var best: PsychokineticBody2D
	var best_score := INF
	for body in nearby_targets(player, acquisition_range, power_level):
		var offset := body.global_position - player.global_position
		var distance := offset.length()
		var alignment := direction.dot(offset.normalized()) if distance > 0.01 else 1.0
		if alignment < 0.05:
			continue
		var score := (1.0 - alignment) * 0.72 + (distance / acquisition_range) * 0.28
		if score < best_score:
			best = body
			best_score = score
	return best


## Vérifie qu'une cible existe, se trouve à portée et accepte le niveau du pouvoir.
func is_available(
	body: PsychokineticBody2D,
	player: PlayerController,
	acquisition_range: float,
	power_level: int
) -> bool:
	return body != null \
		and is_instance_valid(body) \
		and player != null \
		and body.can_be_grabbed(power_level) \
		and player.global_position.distance_to(body.global_position) <= acquisition_range


## Compare deux cibles superposées pour sélectionner celle visuellement au premier plan.
func is_drawn_in_front(
	candidate: PsychokineticBody2D,
	current: PsychokineticBody2D,
	pointer_world_position: Vector2
) -> bool:
	if candidate.z_index != current.z_index:
		return candidate.z_index > current.z_index
	if not is_equal_approx(candidate.global_position.y, current.global_position.y):
		return candidate.global_position.y > current.global_position.y
	return candidate.pointer_distance(pointer_world_position) < current.pointer_distance(pointer_world_position)
