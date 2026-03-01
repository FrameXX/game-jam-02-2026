extends Node2D

func _ready():
	# Instantiate the selected map
	load_level(Global.selected_level)
	$WaveManager.wave_finished.connect(_on_wave_finished)
	$HUD/CanvasLayer/Control/Main.start_wave_pressed.connect(_on_hud_start_wave)
	print("ready")

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

		var new_tilemap = map_instance.find_child("TileMap")
		if new_tilemap:
			$BuildingManager.set_tile_map(new_tilemap)

	# 4. Perform the "Handshake" we discussed
		$WaveManager.tile_map = new_tilemap
		$WaveManager.wave_file = json_path
		$WaveManager.wave_data = $WaveManager.load_wave_data(json_path)
		print("Loaded Level: ", level_number)

	else:
		printerr("Map file not found: ", map_path)

func _on_wave_finished():
	print("Entering Build Mode")
	$BuildingManager.set_build_mode(true)
	$HUD/CanvasLayer/Control/Main.show_start_button() # Show a button to manually start the next wave
	$HUD/CanvasLayer/Control/Main.show_build_button() # Show a button to manually start the next wave

func _on_hud_start_wave():
	$BuildingManager.set_build_mode(false) # Lock building
	$HUD/CanvasLayer.show_dialog("Starting new wave.")
	$WaveManager.start_wave($WaveManager.current_wave_index)
