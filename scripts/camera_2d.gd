extends Camera2D

@export var move_speed: float = 400.0
@export var zoom_speed: float = 0.05
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_zoom(-zoom_speed)

func _adjust_zoom(delta_zoom: float):
	var new_zoom = clamp(zoom.x + delta_zoom, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

func _process(delta: float):
	var direction = Vector2.ZERO
	
	# Check for default UI input actions
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		
	# Normalize to prevent faster diagonal movement
	if direction.length() > 0:
		direction = direction.normalized()
		
	position += direction * move_speed * delta
