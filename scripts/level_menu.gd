extends Node2D

var panel
var label

func _ready():
	panel = $CanvasLayer/Control/Panel
	label = $CanvasLayer/Control/Panel/Label
	panel.visible = false

func show_dialog(text: String):
	print("Showing dialog:", text)
	label.text = text
	panel.visible = true
	await get_tree().create_timer(3.0).timeout
	panel.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_level1_pressed() -> void:
	select_level(1)

func _on_level_2_pressed() -> void:
	select_level(2)
	
func select_level(level: int):
	if Global.unlocked_level >= level:
		Global.selected_level = level;
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		show_dialog("Level not yet unlocked!\nFirst play level: " + str(Global.unlocked_level) + "!")
