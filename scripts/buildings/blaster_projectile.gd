extends Area2D

@export var speed: float = 2048.0
@export var damage: float = 64.0
@export var trail_length: int = 1
@export var trail_spacing: float = 0.02

var target_position: Vector2 = Vector2.ZERO
var target_enemy: Node2D = null
var direction: Vector2 = Vector2.ZERO
var trail_positions: Array[Vector2] = []
var trail_timer: float = 0.0

func _ready() -> void:
	# Connect to body entered signal for collision detection
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Calculate direction if not yet set (fallback)
	if direction == Vector2.ZERO and target_position != Vector2.ZERO:
		direction = (target_position - global_position).normalized()
		rotation = direction.angle()

	# Move projectile toward target
	global_position += direction * speed * delta

	# Update trail
	trail_timer += delta
	if trail_timer >= trail_spacing:
		trail_timer = 0.0
		trail_positions.insert(0, global_position)
		if trail_positions.size() > trail_length:
			trail_positions.pop_back()

	# Redraw for trail effect
	queue_redraw()

	# Check if we've passed the target position
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < 15.0:
		# Hit the target area
		if target_enemy and is_instance_valid(target_enemy):
			if target_enemy.has_method("take_damage"):
				target_enemy.take_damage(damage)
		queue_free()

func _draw() -> void:
	# Draw trail (older positions are more faded)
	for i in range(trail_positions.size()):
		var pos = to_local(trail_positions[i])
		var alpha = 1.0 - (float(i) / float(trail_length))
		var size = 6.0 * (1.0 - (float(i) / float(trail_length)))

		# Trail glow
		draw_circle(pos, size + 2.0, Color(1.0, 0.4, 0.7, alpha * 0.2))
		# Trail core
		draw_circle(pos, size, Color(1.0, 0.5, 0.8, alpha * 0.4))

	# Draw glowing projectile orb
	# Outer glow
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.4, 0.7, 0.3))
	# Middle glow
	draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.5, 0.8, 0.5))
	# Core
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.4, 0.8, 1.0))
	# Bright center
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.9, 1.0, 1.0))

func _on_body_entered(body: Node2D) -> void:
	# Check if we hit an enemy
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func set_target(enemy: Node2D, dmg: float) -> void:
	target_enemy = enemy
	damage = dmg
	if enemy and is_instance_valid(enemy):
		target_position = enemy.global_position
		# Calculate direction toward target
		direction = (target_position - global_position).normalized()
		# Rotate projectile to face direction
		rotation = direction.angle()
