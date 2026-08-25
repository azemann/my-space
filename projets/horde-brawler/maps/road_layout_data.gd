@tool
## Décrit la géométrie responsive et la projection pseudo-3D d'une route.
## Toutes les valeurs résolues dépendent explicitement de la taille du viewport.
class_name RoadLayoutData
extends Resource

@export_category("Documentation")
## Résume l'intention de perspective et d'espace jouable de ce layout.
@export_multiline var gameplay_summary := "Route large à perspective comprimée près de l'horizon."

@export_category("Perspective responsive")
## Hauteur de l'horizon, exprimée en part de la hauteur visible.
@export_range(0.05, 0.35, 0.01) var horizon_ratio := 0.14
## Position du bas géométrique ; au-dessus de 1, la route se termine sous l'écran.
@export_range(0.95, 1.25, 0.01) var bottom_ratio := 1.08
## Part maximale de la largeur visible occupée par la route au premier plan.
@export_range(0.5, 0.98, 0.01) var road_viewport_width_ratio := 0.92
## Largeur maximale de la route relativement à la hauteur ; plafonne l'ultrawide.
@export_range(0.8, 2.0, 0.01) var road_height_cap_ratio := 1.55
## Largeur à l'horizon, exprimée en part de la largeur au premier plan.
@export_range(0.05, 0.5, 0.01) var horizon_width_ratio := 0.21
## Compression des distances près de l'horizon. Au-dessus de 1, l'approche accélère visuellement.
@export_range(0.25, 4.0, 0.05) var perspective_curve := 1.5
## Échelle uniforme d'un agent au point de fuite.
@export_range(0.1, 1.0, 0.05) var far_scale := 0.42
## Échelle uniforme d'un agent au premier plan.
@export_range(0.5, 2.0, 0.05) var near_scale := 1.15

@export_category("Zone jouable")
## Début vertical de la bande du joueur, en part de la hauteur visible.
@export_range(0.35, 0.8, 0.01) var player_top_ratio := 0.55
## Fin verticale de la bande du joueur, en part de la hauteur visible.
@export_range(0.7, 1.0, 0.01) var player_bottom_ratio := 0.92
## Profondeur logique d'apparition des ennemis : 0 = horizon, 1 = premier plan.
@export_range(0.0, 0.25, 0.01) var enemy_spawn_depth := 0.03
## Marge latérale logique conservée à chaque bord pour les formations lointaines.
@export_range(0.0, 0.8, 0.01) var enemy_spawn_lateral_margin := 0.36
## Distance logique entre le bas de l'écran et l'horizon. Sert aussi au défilement des segments.
@export_range(100.0, 5000.0, 10.0) var visible_distance := 1200.0
## Largeur minimale exigée dans le haut de la bande du joueur, en pixels logiques.
@export_range(100.0, 800.0, 10.0) var minimum_playable_width := 320.0


## Largeur de la route au premier plan pour cette taille de viewport.
func road_width(viewport_size: Vector2) -> float:
	return minf(
		maxf(0.0, viewport_size.x) * road_viewport_width_ratio,
		maxf(0.0, viewport_size.y) * road_height_cap_ratio
	)


## Convertit une profondeur logique linéaire en profondeur visuelle courbée.
func curved_depth(depth: float) -> float:
	return pow(clampf(depth, 0.0, 1.0), maxf(0.001, perspective_curve))


## Largeur de la route à une profondeur logique donnée.
func width_at(depth: float, viewport_size: Vector2) -> float:
	var near_width := road_width(viewport_size)
	return lerpf(near_width * horizon_width_ratio, near_width, curved_depth(depth))


## Échelle uniforme d'un agent à une profondeur logique donnée.
func scale_at(depth: float) -> float:
	return lerpf(far_scale, near_scale, curved_depth(depth))


## Convertit une position routière en position écran. X accepte -2 à +2 pour les accotements.
func project(road_position: Vector2, viewport_size: Vector2) -> Vector2:
	var depth := clampf(road_position.y, 0.0, 1.0)
	var y := lerpf(
		viewport_size.y * horizon_ratio,
		viewport_size.y * bottom_ratio,
		curved_depth(depth)
	)
	var x := viewport_size.x * 0.5
	x += clampf(road_position.x, -2.0, 2.0) * width_at(depth, viewport_size) * 0.5
	return Vector2(x, y)


## Retrouve la profondeur logique correspondant à une coordonnée verticale écran.
func depth_from_screen_y(screen_y: float, viewport_size: Vector2) -> float:
	var curved := inverse_lerp(
		viewport_size.y * horizon_ratio,
		viewport_size.y * bottom_ratio,
		screen_y
	)
	return pow(
		clampf(curved, 0.0, 1.0),
		1.0 / maxf(0.001, perspective_curve)
	)


## Convertit une position écran en position routière logique.
func unproject(screen_position: Vector2, viewport_size: Vector2) -> Vector2:
	var depth := depth_from_screen_y(screen_position.y, viewport_size)
	var half_width := maxf(1.0, width_at(depth, viewport_size) * 0.5)
	var lateral := clampf(
		(screen_position.x - viewport_size.x * 0.5) / half_width,
		-2.0,
		2.0
	)
	return Vector2(lateral, depth)


## Bande verticale accessible au joueur dans le viewport courant.
func player_bounds(viewport_size: Vector2) -> Rect2:
	return Rect2(
		0.0,
		viewport_size.y * player_top_ratio,
		viewport_size.x,
		viewport_size.y * (player_bottom_ratio - player_top_ratio)
	)


func road_left(depth: float, viewport_size: Vector2) -> float:
	return viewport_size.x * 0.5 - width_at(depth, viewport_size) * 0.5


func road_right(depth: float, viewport_size: Vector2) -> float:
	return viewport_size.x * 0.5 + width_at(depth, viewport_size) * 0.5


## Retourne les incohérences compréhensibles directement depuis l'éditeur.
func validation_errors(viewport_size: Vector2 = Vector2(1280.0, 720.0)) -> PackedStringArray:
	var errors := PackedStringArray()
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		errors.append("La taille d'aperçu doit être positive.")
		return errors
	if horizon_ratio >= player_top_ratio:
		errors.append("L'horizon doit rester au-dessus de la bande du joueur.")
	if player_top_ratio >= player_bottom_ratio:
		errors.append("Le haut de la bande du joueur doit précéder son bas.")
	var player_top_depth := depth_from_screen_y(
		viewport_size.y * player_top_ratio,
		viewport_size
	)
	if width_at(player_top_depth, viewport_size) < minimum_playable_width:
		errors.append("La route est trop étroite dans la bande du joueur.")
	if perspective_curve <= 0.0 or visible_distance <= 0.0:
		errors.append("La courbe et la distance visible doivent être positives.")
	if far_scale >= near_scale:
		errors.append("L'échelle lointaine doit être inférieure à l'échelle proche.")
	return errors
