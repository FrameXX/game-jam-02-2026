extends PathFollow2D

@export var speed: float = 200.0

func _process(delta):
	# progress_ratio is a value from 0.0 (start) to 1.0 (end)
	# progress is the distance in pixels along the path
	progress += speed * delta
	
	# If the enemy reaches the end of the path
	if progress_ratio >= 1.0:
		reached_end()

func _on_trap_detector_area_entered(area: Area2D):
	# We know it's a hole because our Mask is set to Layer 4 (Traps)
	fall_into_hole()

func fall_into_hole():
	# 1. Stop the enemy from moving
	set_process(false)
	
	# 2. Visual "Falling" effect
	var tween = create_tween()
	# Shrink and rotate while disappearing
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	# 3. Remove the enemy when the animation is done
	tween.set_parallel(false)
	tween.finished.connect(queue_free)
func reached_end():
	print("U ded")
	queue_free() # Remove the enemy
