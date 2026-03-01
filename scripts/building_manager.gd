extends Node2D

var tile_map: TileMap = null
var selected_building_path = "" # Path to the PackedScene (.tscn)
var ghost_building: Sprite2D = null
var current_building_resource: PackedScene = null

var can_build: bool = true
func set_build_mode(active: bool):
	can_build = active
	# DO UI HERE

func _ready():
	GameEvents.building_selected.connect(_on_building_selected)
	# Create the ghost sprite once
	ghost_building = Sprite2D.new()
	ghost_building.modulate = Color(1, 1, 1, 0.5) # 50% transparency
	ghost_building.z_index = 10
	ghost_building.hide() # Start hidden
	add_child(ghost_building)
func set_tile_map(new_map: TileMap):
	tile_map = new_map
	print("Building manager now using: ", tile_map.get_path())

func _on_building_selected(path: String):
	selected_building_path = path
	current_building_resource = load(path)
	
	# Instance it briefly to grab its texture for the ghost
	var temp_node = current_building_resource.instantiate()
	var sprite = temp_node.get_node("Sprite2D") # Assumes your building has a Sprite2D
	if sprite:
		ghost_building.texture = sprite.texture
		ghost_building.show()
	temp_node.queue_free()
	
	print("Building manager received: ", path)
	
func _process(_delta):
	if not can_build or selected_building_path == "" or not tile_map:
		ghost_building.hide()
		return

	# Get mouse position and snap to grid
	var mouse_pos = get_global_mouse_position()
	var cell_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))
	var center_pos = tile_map.map_to_local(cell_pos)
	
	# Update ghost position
	ghost_building.global_position = tile_map.to_global(center_pos)
	ghost_building.show()
	
	# Check if the tile is valid (e.g., is there a tile there at all?)
	var data = tile_map.get_cell_tile_data(0, cell_pos)
	var is_valid = true

	# Check path requirement for the preview
	if data:
		var is_path_tile = data.get_custom_data("is_path")
		# If the building path is a 'hole', and it's not a path tile...
		if selected_building_path.contains("hole") and not is_path_tile:
			is_valid = false

	if is_valid:
		ghost_building.modulate = Color(1, 1, 1, 0.5) # Blue/White tint
	else:
		ghost_building.modulate = Color(1, 0, 0, 0.5) # Red tint (Invalid!)
		
func _input(event: InputEvent):
	if not can_build:
		return
	# 1. Check if we have something selected and the user clicked
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Tile clicked.")
		if selected_building_path != "":
			place_building()

func place_building():
	var mouse_pos = get_global_mouse_position()
	var cell_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))
	var data = tile_map.get_cell_tile_data(0, cell_pos)
	var can_place_here:bool = true
	# VERIFICATION: Only place if a valid tile exists
	if data == null:
		print("Cannot build here: No tile found!")
		return

	print("Placing building on tile.")
	var center_pos = tile_map.map_to_local(cell_pos)
	var building = current_building_resource.instantiate()
	building.z_index = 10
	if building.needs_path == true:
			var is_path_tile = data.get_custom_data("is_path")
			print(str(cell_pos) + " is path tile: " + str(is_path_tile))
			if is_path_tile != true:
				can_place_here = false
				print("PLACEMENT BLOCKED: Not a path tile.")
			else:
				can_place_here = true

	if can_place_here:
		center_pos = tile_map.map_to_local(cell_pos)
		building.global_position = tile_map.to_global(center_pos)
		add_child(building)

	selected_building_path = ""
