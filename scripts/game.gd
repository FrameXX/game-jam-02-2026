extends Node2D

@export var level_map_scene: PackedScene # Drag your Map.tscn here in the inspector

func _ready():
	
	# Instantiate the selected map
	load_level(Global.selected_level)

func load_level(level_number: int):
	# 1. Format the number to always be two digits (e.g., 1 becomes "01")
	var level_string = str(level_number).pad_zeros(2)
	
	# 2. Build the full path string
	var map_path = "res://scenes/maps/map_" + level_string + ".tscn"
	var json_path = "res://levels/level_" + level_string + ".json"
	
	# 3. Load and instance the map
	if ResourceLoader.exists(map_path):
		var map_resource = load(map_path)
		var map_instance = map_resource.instantiate()
		add_child(map_instance)
		
		# 4. Perform the "Handshake" we discussed
		var actual_path = map_instance.find_child("Path2D")
		if actual_path:
			$WaveManager.path_node = actual_path
			$WaveManager.wave_file = json_path
			$WaveManager.wave_data = $WaveManager.load_wave_data(json_path)
			print("Loaded Level: ", level_number)
			$WaveManager.start_wave(0)
	else:
		printerr("Map file not found: ", map_path)
