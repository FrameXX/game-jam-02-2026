extends Button

@export var cost = 10

func _ready() -> void:
	text = str(cost)


func _on_pressed() -> void:
	print("Hole button pressed")
	GameEvents.building_selected.emit("res://scenes/buildings/hole.tscn", )
