extends Node2D

var wave_file: String
var wave_data: Dictionary
var current_wave_index: int = 0
var tile_map: TileMap # We will fill this from the outside

func _ready():
	pass
	
signal wave_finished

func start_wave(index: int):
	var waves = wave_data.get("waves", [])

	var current_wave = waves[index]
	print("Starting Wave: ", current_wave["wave_number"])

	for enemy_group in current_wave["enemies"]:
		await spawn_enemy_group(enemy_group)
		
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		# Check again every half-second so we don't lag the game
		await get_tree().create_timer(0.5).timeout
		
	wave_finished.emit()
	current_wave_index += 1
	
	print("Wave ", current_wave["wave_number"], " spawn complete.")
	
	if current_wave_index >= waves.size():
		$"../HUD/CanvasLayer".show_dialog("You won!")
		await get_tree().create_timer(1.5).timeout
		if Global.unlocked_level == Global.selected_level:
			Global.unlocked_level += 1
		get_tree().change_scene_to_file("res://scenes/level_menu.tscn")
	
	# 4. Move to the next index and start again

func spawn_enemy_group(group: Dictionary):
	# group["type"] -> "slime"
	# group["count"] -> 5
	# group["interval"] -> 1.0
	if not tile_map:
		printerr("WaveManager Error: No Path2D assigned!")
		return
	var path_idx = group.get("path_id", 0) 
	var paths_list = wave_data.get("paths", [])
	
	if paths_list.size() <= path_idx:
		printerr("WaveManager Error: Path index ", path_idx, " not found in JSON 'paths'!")
		return
		
	var path_node_name = paths_list[path_idx]	
	var path_node = tile_map.find_child(path_node_name)
	if not path_node:
		printerr("WaveManager Error: Could not find a child named ", path_node_name, " inside TileMap!")
		return
	var enemy_scene = load("res://scenes/enemies/" + group["type"] + ".tscn")	
	for i in range(group["count"]):
		print("Spawning ", group["type"])
		var current_enemy = load("res://scenes/enemies/" + group["type"] + ".tscn")
	# 3. Instantiate and Add
		var enemy = enemy_scene.instantiate()
		path_node.add_child(enemy) # The enemy (PathFollow2D) is now on the correct track
		var enemy_instance = current_enemy.instantiate()
		enemy_instance.add_to_group("enemies")
#		# 4. Add the enemy as a child of the path
		enemy_instance.z_index = 10
		path_node.add_child(enemy_instance)
		
		# Insert your actual instantiation logic here (e.g., .instantiate())
		await get_tree().create_timer(group["interval"]).timeout

func load_wave_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		print("File not found!")
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var json_data = JSON.parse_string(content)
	
	if json_data == null:
		print("Error parsing JSON")
		return {}
		
	return json_data
