extends Panel

var gold: int = 100
@onready var gold_label: Label = $"../Main/Gold"

func _on_button_pressed_plus_10() -> void:
	gold += 10
	gold_label.text = "Gold: " + str(gold)
