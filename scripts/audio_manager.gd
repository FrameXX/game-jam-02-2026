extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var music_bus = AudioServer.get_bus_index("Music")
	# Set to 0.7 (70%) on startup
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(0.7))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
