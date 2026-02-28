extends Panel

var gold: int = 100
@onready var gold_label: Label = $"../Main/Gold"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed_plus_10() -> void:
	gold += 10
	gold_label.text = "Gold: " + str(gold)
