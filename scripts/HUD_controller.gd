extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/Label

func _ready():
	panel.visible = false

func show_dialog(text: String):
	label.text = text
	panel.visible = true

func _on_cross_dialogue_button_pressed() -> void:
	panel.visible = false
