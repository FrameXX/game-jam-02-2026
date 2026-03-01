extends Node2D

@export var needs_path: bool = false
@export var damage: float = 25.0
@export var attack_range: float = 150.0
@export var attack_cooldown: float = 0.1
@export var laser_duration: float = 0.15

@onready var head: Sprite2D = $Sprite2D/Head
@onready var base_sprite: Sprite2D = $Sprite2D/Base

var can_attack: bool = true
var current_target: Node2D = null
var is_firing_laser: bool = false
var laser_target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("buildings")

func _process(_delta: float) -> void:
	find_nearest_enemy()

	if current_target:
		rotate_toward_target()

		if can_attack:
			attack_target()

func _draw() -> void:
	if is_firing_laser and current_target:
		var from = Vector2.ZERO
		var to = to_local(laser_target_position)

		# Draw glow layers (outer to inner)
		draw_line(from, to, Color(1.0, 0.4, 0.7, 0.2), 8.0)
		draw_line(from, to, Color(1.0, 0.4, 0.7, 0.4), 5.0)
		draw_line(from, to, Color(1.0, 0.5, 0.8, 0.6), 3.0)
		# Core laser (bright pink)
		draw_line(from, to, Color(1.0, 0.4, 0.8, 1.0), 2.0)
		# Inner bright core
		draw_line(from, to, Color(1.0, 0.8, 0.9, 1.0), 1.0)

func find_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")

	if enemies.is_empty():
		current_target = null
		return

	var nearest_enemy = null
	var nearest_distance = attack_range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		if enemy.is_supply:
			continue

		var distance = global_position.distance_to(enemy.global_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy

	current_target = nearest_enemy

func rotate_toward_target() -> void:
	if not current_target or not head:
		return

	var target_position = current_target.global_position
	var direction = target_position - global_position
	var angle = direction.angle()

	# Rotate the head to face the target
	head.rotation = angle + deg_to_rad(90)

func attack_target() -> void:
	if not current_target:
		return

	# Check if target still has the take_damage method
	if current_target.has_method("take_damage"):
		print(damage)
		current_target.take_damage(damage)
		print("Blaster attacked enemy for ", damage, " damage!")

		# Show laser effect
		laser_target_position = current_target.global_position
		show_laser()

		# Start cooldown
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
	else:
		# Target might have been destroyed, find a new one
		current_target = null

func show_laser() -> void:
	is_firing_laser = true
	queue_redraw()

	await get_tree().create_timer(laser_duration).timeout

	is_firing_laser = false
	queue_redraw()


func _on_pressed() -> void:
	pass # Replace with function body.
