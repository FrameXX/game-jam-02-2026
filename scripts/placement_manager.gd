extends Node2D

@onready var tile_map: TileMapLayer = $TileMapLayer # Use TileMap in Godot 3/4.0-4.2
var selected_building_path: String = "" # Path to the PackedScene (.tscn)

func _unhandled_input(event: InputEvent):
	# 1. Check if we have something selected and the user clicked
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_building_path != "":
			place_building()

func place_building():
	# 2. Get the mouse position relative to the world
	var mouse_pos = get_global_mouse_position()
	
	# 3. Convert that position to TileMap grid coordinates (e.g., Vector2i(5, 2))
	var cell_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))
	
	# 4. Calculate the center of that tile in global coordinates
	var center_pos = tile_map.map_to_local(cell_pos)
	
	# 5. Instance and place the building
	var building_scene = load(selected_building_path)
	var building = building_scene.instantiate()
	
	building.global_position = center_pos
	add_child(building)
	
	# Optional: Clear selection after building
	# selected_building_path = ""
