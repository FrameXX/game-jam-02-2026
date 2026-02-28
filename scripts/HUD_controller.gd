extends CanvasLayer

var panel
var label

func _ready():
	panel = $Panel
	label = $Panel/Label
	panel.visible = false

func show_dialog(text: String):
	label.text = text
	panel.visible = true

func _on_cross_dialogue_button_pressed() -> void:
	panel.visible = false
