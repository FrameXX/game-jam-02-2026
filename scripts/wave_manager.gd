extends Node2D

var wave_file: String = "res://levels/level_00.json"
var wave_data: Dictionary
var current_wave_index: int = 0
var path_node: Path2D # We will fill this from the outside

func _ready():
	pass
	
func start_wave(index: int):
	var waves = wave_data.get("waves", [])
	if index >= waves.size():
		print("All waves complete!")
		return

	var current_wave = waves[index]
	print("Starting Wave: ", current_wave["wave_number"])

	for enemy_group in current_wave["enemies"]:
		await spawn_enemy_group(enemy_group)
	var delay = current_wave.get("spawn_delay", 2.0)
	print("Wave ", current_wave["wave_number"], " spawn complete. Waiting ", delay, "s...")
	
	await get_tree().create_timer(delay).timeout
	
	# 4. Move to the next index and start again
	current_wave_index += 1
	start_wave(current_wave_index)

func spawn_enemy_group(group: Dictionary):
	# group["type"] -> "slime"
	# group["count"] -> 5
	# group["interval"] -> 1.0
	if not path_node:
		printerr("WaveManager Error: No Path2D assigned!")
		return
		
	for i in range(group["count"]):
		print("Spawning ", group["type"])
		var current_enemy = load("res://scenes/enemies/" + group["type"] + ".tscn")
#		
#		# 4. Add the enemy as a child of the path
		path_node.add_child(current_enemy.instantiate())
		
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
