extends Node2D

# 1. Load the scene file
const ENEMY_SCENE = preload("res://scenes/basic_enemy_path_follow.tscn")

# Removed the @onready var that pointed to a specific enemy instance

var new_enemy = ENEMY_SCENE.instantiate()
func _on_timer_timeout():
	# 2. Create a fresh instance of the enemy
	
	# 3. Get the Path2D node (the parent)
	var path_node = $"../Map/Path2D"
	
	# 4. Add the enemy as a child of the path
	path_node.add_child(ENEMY_SCENE.instantiate())
	
	# 5. Optional: Ensure it starts at the beginning
	new_enemy.progress = 0
	
	print("Enemy added to path!")
