extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var music_db = AudioServer.get_bus_volume_db(music_bus_id)
	var sfx_db = AudioServer.get_bus_index("SFX")
	$VBoxContainer/Music.value = db_to_linear(music_db)
	$VBoxContainer/SFX.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_easter_egg_button_pressed() -> void:
	$SettingsMenuController/RichTextLabel.visible = true

@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sfx_bus_id = AudioServer.get_bus_index("SFX")
func _on_music_slider_value_changed(value: float) -> void:
	# linear_to_db converts 0.0-1.0 to -80dB to 0dB
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(value))
	
	# Mute the bus if the slider is at 0
	AudioServer.set_bus_mute(music_bus_id, value < 0.01)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_id, value < 0.01)
