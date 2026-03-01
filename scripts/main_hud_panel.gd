extends Panel

var gold: int = 100
@onready var gold_label: Label = $"../Main/Gold"

signal start_wave_pressed
signal build_mode_toggled(is_active)

func _on_start_pressed():
	print("start wave presed")
	start_wave_pressed.emit()
	# Optional: Hide the button so they can't spam it during the wave
	$%Start.hide()

func _on_button_pressed_plus_10() -> void:
	gold += 10
	gold_label.text = "Gold: " + str(gold)
	
func show_start_button():
	$%Start.show()
