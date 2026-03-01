extends Button

@onready var building_panel: Panel = $".."

var destroy_mode_active: bool = false

func _ready() -> void:
	pressed.connect(_on_pressed)
	GameEvents.destroy_mode_toggled.connect(_on_destroy_mode_toggled)

func _on_pressed() -> void:
	print("Destroy button pressed")
	destroy_mode_active = !destroy_mode_active
	GameEvents.destroy_mode_toggled.emit(destroy_mode_active)

func _on_destroy_mode_toggled(is_active: bool) -> void:
	destroy_mode_active = is_active
	if is_active:
		modulate = Color(1, 0.5, 0.5)
	else:
		modulate = Color(1, 1, 1)
