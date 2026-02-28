extends PathFollow2D

@export var speed: float = 200.0

func _process(delta):
	# progress_ratio is a value from 0.0 (start) to 1.0 (end)
	# progress is the distance in pixels along the path
	progress += speed * delta
	
	# If the enemy reaches the end of the path
	if progress_ratio >= 1.0:
		reached_end()

func reached_end():
	print("U ded")
	queue_free() # Remove the enemy
