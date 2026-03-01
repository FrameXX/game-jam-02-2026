extends Panel

@onready var gold_label: Label = $"../Main/Gold"

signal start_wave_pressed
signal build_mode_toggled(is_active)

func _on_start_pressed():
	print("start wave presed")
	start_wave_pressed.emit()
	# Optional: Hide the button so they can't spam it during the wave
	$%Start.hide()
	$%Build.hide()

func _on_button_pressed_plus_10() -> void:
	Global.gold += 10
	gold_label.text = "Gold: " + str(Global.gold)
	
func show_start_button():
	$%Start.show()

func show_build_button():
	$%Build.show()
