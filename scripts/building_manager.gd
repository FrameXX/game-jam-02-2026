extends Node2D

var tile_map: TileMap = null
var selected_building_path: String = "" # Path to the PackedScene (.tscn)

var can_build: bool = true
func set_build_mode(active: bool):
	can_build = active
	# DO UI HERE

func _ready():
	GameEvents.building_selected.connect(_on_building_selected)

func set_tile_map(new_map: TileMap):
	tile_map = new_map
	print("BuildingManager now using: ", tile_map.get_path())

func _on_building_selected(path: String):
	selected_building_path = path
	print("Manager received: ", path)

func _unhandled_input(event: InputEvent):
	if not can_build:
		return
	# 1. Check if we have something selected and the user clicked
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Tile cliked.")
		if selected_building_path != "":
			place_building()

func place_building():
	print("Placing building on tile.")
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
