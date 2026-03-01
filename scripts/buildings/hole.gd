extends Node2D
@export var needs_path: bool = true
@export var max_enemies: int = 3

var enemies_fallen: int = 0

@onready var area: Area2D = $Area2D

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)
		area.area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if it's an enemy that fell in
	if body.is_in_group("enemies"):
		register_enemy_fallen()

func _on_area_entered(area: Area2D) -> void:
	# Check if the area belongs to an enemy
	var parent = area.get_parent()
	if parent and parent.is_in_group("enemies"):
		register_enemy_fallen()

func register_enemy_fallen() -> void:
	enemies_fallen += 1
	print("Enemy fell into hole! Count: ", enemies_fallen, "/", max_enemies)

	if enemies_fallen >= max_enemies:
		destroy_hole()

func destroy_hole() -> void:
	print("Hole has absorbed ", max_enemies, " enemies. Disappearing!")

	# Visual disappearing effect
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)

	tween.set_parallel(false)
	tween.finished.connect(queue_free)
