extends Node2D  

var tile_map: TileMap = null  
var selected_building_path = "" 
var ghost_building: Sprite2D = null  
var current_building_resource: PackedScene = null  

var can_build: bool = true  

# --- NEW HELPER FUNCTION ---
# This makes it easy to add new costs in one place
func get_building_cost(path: String) -> int:
	if path.contains("hole"):
		return 10
	if path.contains("plasma_shell"):
		return 50
	return 0

func set_build_mode(active: bool):  
	can_build = active  

func _ready():  
	GameEvents.building_selected.connect(_on_building_selected)  
	ghost_building = Sprite2D.new()  
	ghost_building.modulate = Color(1, 1, 1, 0.5) 
	ghost_building.z_index = 10  
	ghost_building.hide() 
	add_child(ghost_building)  

func set_tile_map(new_map: TileMap):  
	tile_map = new_map  

func _on_building_selected(path: String):  
	selected_building_path = path  
	current_building_resource = load(path)  
	
	var temp_node = current_building_resource.instantiate()  
	var sprite = temp_node.get_node("Sprite2D") 
	if sprite:  
		ghost_building.texture = sprite.texture  
		ghost_building.show()  
	temp_node.queue_free()  
	
func _process(_delta):  
	if not can_build or selected_building_path == "" or not tile_map:  
		ghost_building.hide()  
		return  

	var mouse_pos = get_global_mouse_position()  
	var cell_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))  
	var center_pos = tile_map.map_to_local(cell_pos)  
	
	ghost_building.global_position = tile_map.to_global(center_pos)  
	ghost_building.show()  
	
	var data = tile_map.get_cell_tile_data(0, cell_pos)  
	var is_valid = true  

	# CHECK 1: Tile requirements
	if data:  
		var is_path_tile = data.get_custom_data("is_path")  
		if selected_building_path.contains("hole") and not is_path_tile:  
			is_valid = false  
	else:
		is_valid = false

	# CHECK 2: Can we afford it?
	var cost = get_building_cost(selected_building_path)
	if Global.gold < cost:
		is_valid = false

	if is_valid:  
		ghost_building.modulate = Color(1, 1, 1, 0.5) # Normal
	else:  
		ghost_building.modulate = Color(1, 0, 0, 0.5) # Red (Invalid/Too expensive)  
		
func _input(event: InputEvent):  
	if not can_build:  
		return  
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:  
		if selected_building_path != "":  
			place_building()  

func place_building():  
	# 1. Check Money First
	var cost = get_building_cost(selected_building_path)
	if Global.gold < cost:
		print("Too poor to build this!")
		return

	var mouse_pos = get_global_mouse_position()  
	var cell_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))  
	var data = tile_map.get_cell_tile_data(0, cell_pos)  
	
	if data == null:  
		return  

	var building = current_building_resource.instantiate()  
	var can_place_here: bool = true  

	# 2. Check logic requirements
	if building.get("needs_path") == true:  
		var is_path_tile = data.get_custom_data("is_path")  
		if is_path_tile != true:  
			print("NOT A PATH, CANNOT PLACE")
			can_place_here = false  

	if can_place_here:  
		# Deduct Gold
		Global.gold -= cost
		
		# Update UI (Optional: consider making a dedicated UI update function)
		var gold_label: Label = $"../HUD/CanvasLayer/Control/Main/Gold"  
		if gold_label:
			gold_label.text = "Gold: " + str(Global.gold)

		# Finalize Placement
		var center_pos = tile_map.map_to_local(cell_pos)  
		building.global_position = tile_map.to_global(center_pos)  
		building.z_index = 10  
		add_child(building)  
		
		# Reset selection
		selected_building_path = ""  
	else:
		building.queue_free() # Clean up memory if we didn't place it
