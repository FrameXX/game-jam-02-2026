extends PathFollow2D

@export var speed: float = 200.0
@export var max_health: float = 100.0

var current_health: float
var is_falling: bool = false

signal died(enemy)

func _ready():
	current_health = max_health

func _process(delta):
	if is_falling:
		return

	# progress_ratio is a value from 0.0 (start) to 1.0 (end)
	# progress is the distance in pixels along the path
	progress += speed * delta

	# If the enemy reaches the end of the path
	if progress_ratio >= 1.0:
		reached_end()

func _on_trap_detector_area_entered(area: Area2D):
	# Already falling into another hole, ignore
	if is_falling:
		return

	# Check if it's a hole (trap layer)
	var parent = area.get_parent()
	if parent and parent.has_method("register_enemy_fallen"):
		parent.register_enemy_fallen()
	fall_into_hole()

func take_damage(amount: float):
	current_health -= amount
	print("Enemy took ", amount, " damage. Health: ", current_health)

	if current_health <= 0:
		die()

func die():
	Global.gold += 10
	$"../../../../HUD/CanvasLayer/Control/Main/Gold".text = "Gold: " + str(Global.gold)
	emit_signal("died", self)
	queue_free()

func fall_into_hole():
	# Mark as falling to prevent triggering other holes
	is_falling = true

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
	$"../../../../HUD/CanvasLayer".show_dialog("U ded\nReturning to level selector")
	await get_tree().create_timer(2.0).timeout 
	Global.base_health -= 10
	get_tree().change_scene_to_file("res://scenes/level_menu.tscn")
	queue_free()
	# Damage the base when enemy reaches the end
