extends Node2D

var wave_file: String
var wave_data: Dictionary
var current_wave_index: int = 0
var tile_map: TileMap

# This is our new list that contains both enemies and peppered supplies
var final_wave_list: Array = []

signal wave_finished

func start_wave(index: int):
	# Use the final_wave_list instead of the raw JSON waves
	if index >= final_wave_list.size():
		return

	var current_wave = final_wave_list[index]
	
	# If wave_number is -1, it's an injected supply wave
	if current_wave.get("wave_number") == -1:
		print("Incoming Supply Drop!")
	else:
		print("Starting Wave: ", current_wave["wave_number"])

	for enemy_group in current_wave["enemies"]:
		await spawn_enemy_group(enemy_group)
		
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		await get_tree().create_timer(0.5).timeout
		
	wave_finished.emit()
	current_wave_index += 1
	
	# Check for win condition against the FULL list
	if current_wave_index >= final_wave_list.size():
		$"../HUD/CanvasLayer".show_dialog("You won!")
		await get_tree().create_timer(1.5).timeout
		if Global.unlocked_level == Global.selected_level:
			Global.unlocked_level += 1
		get_tree().change_scene_to_file("res://scenes/level_menu.tscn")

func spawn_enemy_group(group: Dictionary):
	if not tile_map:
		printerr("WaveManager Error: No TileMap assigned!")
		return
		
	var path_idx = group.get("path_id", 0) 
	var paths_list = wave_data.get("paths", [])
	
	if paths_list.size() <= path_idx:
		printerr("WaveManager Error: Path index not found!")
		return
		
	var path_node_name = paths_list[path_idx]
	var path_node = tile_map.find_child(path_node_name)
	
	if not path_node:
		return

	# Load once per group for performance
	var enemy_scene = load("res://scenes/enemies/" + group["type"] + ".tscn")
	
	for i in range(group["count"]):
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.add_to_group("enemies")
		enemy_instance.z_index = 10
		path_node.add_child(enemy_instance)
		
		await get_tree().create_timer(group["interval"]).timeout

func load_wave_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var json_data = JSON.parse_string(content)
	if json_data == null: return {}
	
	# --- INJECTION LOGIC ---
	wave_data = json_data # Store the full data for paths
	final_wave_list = json_data.get("waves", []).duplicate()
	
	var supplies = json_data.get("supplies", [])
	for s_string in supplies:
		# Split "1, 2" -> ["1", " 2"]
		var parts = s_string.split(",")
		var amount = parts[0].strip_edges().to_int()
		var count = parts[1].strip_edges().to_int()
		var path_id = parts[2].strip_edges().to_int()
		
		for i in range(amount):
			# Insert the supply wave at a random position within the allowed range
			var random_pos = randi_range(0, final_wave_list.size())
			
			var supply_wave = {
				"wave_number": -1, # Flag for supplies
				"enemies": [{
					"type": "supplies",
					"count": count,
					"interval": 0.3,
					"path_id": path_id
				}]
			}
			final_wave_list.insert(random_pos, supply_wave)
	
	return json_data
