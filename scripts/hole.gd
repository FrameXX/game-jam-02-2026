extends Button

func _on_pressed() -> void:
	GameEvents.building_selected.emit("res://scenes/buildings/hole.tscn")
