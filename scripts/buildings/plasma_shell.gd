extends Node2D

@export var needs_path: bool = false
@export var damage: float = 25.0
@export var attack_range: float = 150.0
@export var attack_cooldown: float = 1.0

@onready var head: Sprite2D = $Sprite2D/Head
@onready var base_sprite: Sprite2D = $Sprite2D/Base

var can_attack: bool = true
var current_target: Node2D = null

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	find_nearest_enemy()

	if current_target:
		rotate_toward_target()

		if can_attack:
			attack_target()

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
	head.rotation = angle

func attack_target() -> void:
	if not current_target:
		return

	# Check if target still has the take_damage method
	if current_target.has_method("take_damage"):
		current_target.take_damage(damage)
		print("Plasma shell attacked enemy for ", damage, " damage!")

		# Start cooldown
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
	else:
		# Target might have been destroyed, find a new one
		current_target = null
