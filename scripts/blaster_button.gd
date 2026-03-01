extends Button

@export var cost = 60

func _ready() -> void:
	text = str(cost)


func _on_pressed() -> void:
	print("Blaster button pressed")
	GameEvents.building_selected.emit("res://scenes/buildings/blaster.tscn", )
