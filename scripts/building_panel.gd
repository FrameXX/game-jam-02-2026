extends Panel

@onready var building: Panel = $"."

func _ready() -> void:
	building.visible = false
		
func _on_build_pressed() -> void:
	building.visible = !building.visible
