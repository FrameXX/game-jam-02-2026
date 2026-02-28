extends Node2D

# 1. Load the scene file
#const ENEMY_SCENE = preload("res://scenes/enemies/basic.tscn")

# Removed the @onready var that pointed to a specific enemy instance
#
##var new_enemy = ENEMY_SCENE.instantiate()
#func _on_timer_timeout():
#	# 2. Create a fresh instance of the enemy
#	
#	# 3. Get the Path2D node (the parent)
#	var path_node = $"../Map/Path2D"
#	
#	# 4. Add the enemy as a child of the path
#	path_node.add_child(ENEMY_SCENE.instantiate())
#	
#	# 5. Optional: Ensure it starts at the beginning
#	new_enemy.progress = 0
#	
#	print("Enemy added to path!")
#
var wave_file: String = "res://levels/level_00.json"
var wave_data: Dictionary
var current_wave_index: int = 0

func _ready():
	wave_data = load_wave_data(wave_file)
	start_wave(current_wave_index)

func start_wave(index: int):
	var waves = wave_data.get("waves", [])
	if index >= waves.size():
		print("All waves complete!")
		return

	var current_wave = waves[index]
	print("Starting Wave: ", current_wave["wave_number"])

	for enemy_group in current_wave["enemies"]:
		spawn_enemy_group(enemy_group)

func spawn_enemy_group(group: Dictionary):
	# group["type"] -> "slime"
	# group["count"] -> 5
	# group["interval"] -> 1.0
	for i in range(group["count"]):
		print("Spawning ", group["type"])
		var current_enemy = load("res://scenes/enemies/" + group["type"] + ".tscn")
		var path_node = $"../Map/Path2D"
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
