extends Button

@onready var building_panel: Panel = $".."

func _ready() -> void:
	# Connect to the destroy mode signal
	GameEvents.destroy_mode_toggled.connect(_on_destroy_mode_toggled)

func _on_pressed() -> void:
	print("Destroy button pressed")
	# Toggle destroy mode
	GameEvents.destroy_mode_toggled.emit(true)
	# Hide the building panel
	if building_panel:
		building_panel.visible = false

func _on_destroy_mode_toggled(is_active: bool) -> void:
	# Visual feedback for destroy mode
	if is_active:
		modulate = Color(1, 0.5, 0.5)  # Red tint when active
	else:
		modulate = Color(1, 1, 1)  # Normal color when inactive
