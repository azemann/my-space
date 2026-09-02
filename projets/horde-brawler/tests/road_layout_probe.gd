extends SceneTree

const ROAD_LAYOUT_DATA := preload("res://maps/road_layout_data.gd")
const FORMATS: Array[Vector2] = [
	Vector2(960.0, 720.0),
	Vector2(1152.0, 720.0),
	Vector2(1280.0, 720.0),
	Vector2(1560.0, 720.0),
	Vector2(1680.0, 720.0),
]

var errors := 0


func _initialize() -> void:
	var layout := ROAD_LAYOUT_DATA.new()
	for viewport_size in FORMATS:
		var sample := Vector2(0.55, 0.63)
		_check(
			layout.unproject(layout.project(sample, viewport_size), viewport_size).distance_to(sample) < 0.001,
			"Projection réversible en %s" % viewport_size
		)
		_check(
			is_equal_approx(layout.project(Vector2.ZERO, viewport_size).x, viewport_size.x * 0.5),
			"Centre responsive en %s" % viewport_size
		)
		_check(
			layout.road_width(viewport_size) <= viewport_size.x * 0.92 + 0.01,
			"Largeur contenue en %s" % viewport_size
		)
	_check(
		is_equal_approx(
			layout.road_width(Vector2(1680.0, 720.0)),
			layout.road_width(Vector2(1280.0, 720.0))
		),
		"L'ultrawide doit plafonner la route"
	)
	layout.horizon_ratio = 0.7
	_check(
		not layout.validation_errors(Vector2(1280.0, 720.0)).is_empty(),
		"Un horizon sous la bande du joueur doit être refusé"
	)
	print("ROAD LAYOUT vérifié sur cinq formats — erreurs : %d" % errors)
	quit(1 if errors else 0)


func _check(condition: bool, message: String) -> void:
	if not condition:
		errors += 1
		push_error(message)
