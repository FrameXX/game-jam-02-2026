extends Node2D


const ENEMY_SCENE = preload("res://scenes/BasicEnemyPathFollow.tscn")
@onready var enemy_path = $map/Path2D/BasicEnemyPathFollow

func _on_timer_timeout():
	# 1. Create the instance
	var new_enemy = ENEMY_SCENE.instantiate()
	
	# 2. Find the Path2D node
	# Adjust the name inside "$" to match your Path2D node exactly!
	var path_node = $map/Path2D
	
	# 3. Add the enemy to the PATH, not the script's root
	path_node.add_child(new_enemy)
	
	
	print("Enemy added to path!")
