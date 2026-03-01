extends Node2D

@export var needs_path: bool = false
@export var damage: float = 64
@export var attack_range: float = 150.0
@export var attack_cooldown: float = 0.3

@onready var head: Sprite2D = $Head
@onready var base_sprite: Sprite2D = $Base

var can_attack: bool = true
var current_target: Node2D = null
var projectile_scene: PackedScene = preload("res://scenes/buildings/blaster_projectile.tscn")

func _ready() -> void:
	add_to_group("buildings")

func _process(_delta: float) -> void:
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

	# Spawn projectile
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	# Set projectile position and target
	projectile.global_position = global_position
	projectile.set_target(current_target, damage)

	print("Blaster fired projectile at enemy!")

	# Start cooldown
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_pressed() -> void:
	pass # Replace with function body.
