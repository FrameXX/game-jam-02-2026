extends Button


func _on_pressed() -> void:
	print("Hole button pressed")
	GameEvents.building_selected.emit("res://scenes/buildings/hole.tscn", )
