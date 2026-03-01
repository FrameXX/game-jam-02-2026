extends CanvasLayer

var panel
var label

func _ready():
	panel = $Control/Panel
	label = $Control/Panel/Label
	panel.visible = false

func show_dialog(text: String):
	print("Showing dialog:", text)
	label.text = text
	panel.visible = true
	await get_tree().create_timer(3.0).timeout
	panel.visible = false

func _on_cross_dialogue_button_pressed() -> void:
	panel.visible = false


func _on_start_pressed() -> void:
	pass # Replace with function body.
