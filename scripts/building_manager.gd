extends Node2D

var tile_map: TileMap = null
var selected_building_path = ""
var ghost_building: Node2D = null
var current_building_resource: PackedScene = null

var can_build: bool = true
var destroy_mode: bool = false
var hovered_building: Node2D = null

func get_building_cost(path: String) -> int:
	if path.contains("hole"):
		return 10
	if path.contains("plasma_shell"):
		return 50
	if path.contains("blaster"):
		return 60
	return 0

func set_build_mode(active: bool):
	can_build = active

func _ready():
	GameEvents.building_selected.connect(_on_building_selected)
	GameEvents.destroy_mode_toggled.connect(_on_destroy_mode_toggled)
	ghost_building = Node2D.new()
	ghost_building.z_index = 10
	ghost_building.hide()
	add_child(ghost_building)

func set_tile_map(new_map: TileMap):
	tile_map = new_map

func _on_destroy_mode_toggled(is_active: bool):
	destroy_mode = is_active
	if is_active:
		# Clear building selection when entering destroy mode
		selected_building_path = ""
		for child in ghost_building.get_children():
			child.queue_free()
		ghost_building.hide()
	else:
		# Clear hover highlight when exiting destroy mode
		_clear_hover_highlight()

func _on_building_selected(path: String):
	print("Building selected: ", path)
	selected_building_path = path
	current_building_resource = load(path)

	# Clear previous ghost visuals
	for child in ghost_building.get_children():
		child.queue_free()

	# Instantiate the building scene for preview
	var building_instance = load(path).instantiate()

	# Disable all scripts so the ghost doesn't run any logic
	disable_all_scripts(building_instance)

	# Disable all collisions so the ghost doesn't interact with the game
	disable_all_collisions(building_instance)

	# Add to ghost container
	ghost_building.add_child(building_instance)
	ghost_building.modulate = Color(1, 1, 1, 0.5)
	ghost_building.show()

func disable_all_scripts(node: Node) -> void:
	# Remove script from this node
	if node.get_script():
		node.set_script(null)

	# Recursively disable scripts on all children
	for child in node.get_children():
		disable_all_scripts(child)

func disable_all_collisions(node: Node) -> void:
	# Disable CollisionShape2D nodes
	if node is CollisionShape2D:
		node.disabled = true
	elif node is CollisionPolygon2D:
		node.disabled = true

	# Disable Area2D collision detection
	if node is Area2D:
		node.monitoring = false
		node.monitorable = false

	# Recursively process all children
	for child in node.get_children():
		disable_all_collisions(child)

func _process(_delta):
	if destroy_mode:
		_handle_destroy_mode_hover()
		return

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
		ghost_building.modulate = Color(1, 1, 1, 0.5)
	else:
		ghost_building.modulate = Color(1, 0, 0, 0.5)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if destroy_mode:
			_try_destroy_building()
			return
		if not can_build:
			return
		if selected_building_path != "":
			place_building()

func place_building():
	if current_building_resource == null:
		print("No building selected!")
		return

	# Check Money First
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

	# Check logic requirements
	if building.get("needs_path") == true:
		var is_path_tile = data.get_custom_data("is_path")
		if is_path_tile != true:
			print("NOT A PATH, CANNOT PLACE")
			can_place_here = false
	else:
		var is_path_tile = data.get_custom_data("is_path")
		if is_path_tile == true:
			print("A PATH, CANNOT PLACE")
			can_place_here = false

	if can_place_here:
		# Deduct Gold
		Global.gold -= cost

		# Update UI
		var gold_label: Label = $"../HUD/CanvasLayer/Control/Main/Gold"
		if gold_label:
			gold_label.text = "Gold: " + str(Global.gold)

		# Finalize Placement
		var center_pos = tile_map.map_to_local(cell_pos)
		building.global_position = tile_map.to_global(center_pos)
		building.z_index = 10
		add_child(building)

		# Reset selection and clear ghost
		selected_building_path = ""
		for child in ghost_building.get_children():
			child.queue_free()
		ghost_building.hide()
	else:
		building.queue_free()

func _handle_destroy_mode_hover():
	# Use physics query to find building under mouse cursor
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	# Query for areas at mouse position (buildings use Area2D for collision)
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = 0xFFFFFFFF  # Check all layers
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results = space_state.intersect_point(query)

	var new_hovered_building: Node2D = null

	# Find the first building in results
	for result in results:
		var collider = result.get("collider")
		if collider:
			# Check if the collider or its parent is a building
			var building_node = collider
			if collider is Area2D:
				building_node = collider.get_parent()

			if building_node and building_node.is_in_group("buildings"):
				new_hovered_building = building_node
				break

	# Update hover highlight
	if new_hovered_building != hovered_building:
		_clear_hover_highlight()
		hovered_building = new_hovered_building
		if hovered_building:
			hovered_building.modulate = Color(1, 0.3, 0.3)  # Red tint

func _clear_hover_highlight():
	if hovered_building and is_instance_valid(hovered_building):
		hovered_building.modulate = Color(1, 1, 1)
	hovered_building = null

func _try_destroy_building():
	if hovered_building and is_instance_valid(hovered_building):
		print("Destroying building!")
		hovered_building.queue_free()
		hovered_building = null
		# Exit destroy mode after destroying
		GameEvents.destroy_mode_toggled.emit(false)
