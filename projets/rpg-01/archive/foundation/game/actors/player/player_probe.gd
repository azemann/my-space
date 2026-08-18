extends CharacterBody2D

@export var speed := 150.0
@export var height_level := 0
@export var camera_limits := Rect2()


func _ready() -> void:
	add_to_group("player")
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera != null and camera_limits.size != Vector2.ZERO:
		camera.limit_left = int(camera_limits.position.x)
		camera.limit_top = int(camera_limits.position.y)
		camera.limit_right = int(camera_limits.end.x)
		camera.limit_bottom = int(camera_limits.end.y)


func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	move_and_slide()
	queue_redraw()


func _draw() -> void:
	_draw_ellipse_shape(Vector2(0, 7), Vector2(10, 5), Color(0.04, 0.07, 0.08, 0.42))
	draw_circle(Vector2(0, -5), 8.0, Color("f2c36b"))
	draw_rect(Rect2(-8, 2, 16, 14), Color("315a78"), true)
	draw_line(Vector2(-6, 5), Vector2(-10, 12), Color("e6b65f"), 3.0)
	draw_line(Vector2(6, 5), Vector2(10, 12), Color("e6b65f"), 3.0)
	draw_arc(Vector2(0, -5), 8.0, 0.0, TAU, 20, Color("172b37"), 2.0)


func _draw_ellipse_shape(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
