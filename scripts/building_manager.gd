extends Node2D

var tile_map: TileMap = null
var selected_building_path = ""
var ghost_building: Node2D = null
var current_building_resource: PackedScene = null

var can_build: bool = true

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
	ghost_building = Node2D.new()
	ghost_building.z_index = 10
	ghost_building.hide()
	add_child(ghost_building)

func set_tile_map(new_map: TileMap):
	tile_map = new_map

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
	if not can_build:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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

		pass

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
