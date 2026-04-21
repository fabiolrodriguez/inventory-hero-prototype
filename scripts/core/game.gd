extends Node2D

@export var piece_scene: PackedScene

@onready var board = $Board
@onready var pieces_container = $Pieces

@onready var left_area = $Layout/LeftArea
@onready var right_area = $Layout/RightArea
@onready var shop_spawn_area = $Layout/Shop

#var current_level_index: int = 0

var current_total_cells: int = 16

var level_total_cells_progression: Array[int] = [16, 20, 24, 30, 36, 42, 48]
var current_level_index: int = 0

var max_snake_shapes_per_level: int = 1

@onready var cursor = $Cursor

var cursor_speed: float = 600.0

var shape_pool: Array = [
	{
		"type": "single",
		"shape": [[1]]
	},
	{
		"type": "line2_h",
		"shape": [[1, 1]]
	},
	{
		"type": "line2_v",
		"shape": [[1], [1]]
	},
	{
		"type": "line3_h",
		"shape": [[1, 1, 1]]
	},
	{
		"type": "line3_v",
		"shape": [[1], [1], [1]]
	},
	{
		"type": "l3_a",
		"shape": [[1, 1], [1, 0]]
	},
	{
		"type": "l3_b",
		"shape": [[1, 1], [0, 1]]
	},
	{
		"type": "square",
		"shape": [[1, 1], [1, 1]]
	},
	{
		"type": "line4_h",
		"shape": [[1, 1, 1, 1]]
	},
	{
		"type": "line4_v",
		"shape": [[1], [1], [1], [1]]
	},
	{
		"type": "l4_a",
		"shape": [[1, 1, 1], [1, 0, 0]]
	},
	{
		"type": "l4_b",
		"shape": [[1, 1, 1], [0, 0, 1]]
	},
	{
		"type": "s",
		"shape": [[1, 1, 0], [0, 1, 1]]
	},
	{
		"type": "z",
		"shape": [[0, 1, 1], [1, 1, 0]]
	}
]

var level_shapes: Array = [] 

var piece_colors: Array = [
	Color(0.9, 0.3, 0.3),
	Color(0.3, 0.8, 0.9),
	Color(0.9, 0.8, 0.3),
	Color(0.5, 0.9, 0.4),
	Color(0.8, 0.4, 0.9),
	Color(0.9, 0.6, 0.2)
]

func _ready():
	update_layout_visuals()
	load_current_level()
	#load_level_from_total_cells(current_total_cells)
	
func load_current_level():
	if current_level_index >= level_total_cells_progression.size():
		print("No more levels")
		return

	load_level_from_total_cells(level_total_cells_progression[current_level_index])	

func position_board_in_left_area():
	var board_size = board.get_board_size_pixels()
	var left_rect = get_left_half_rect()

	var centered_x = left_rect.position.x + (left_rect.size.x - board_size.x) * 0.5
	var centered_y = left_rect.position.y + (left_rect.size.y - board_size.y) * 0.5

	board.global_position = Vector2(centered_x, centered_y)

func clear_existing_pieces():
	for child in pieces_container.get_children():
		child.queue_free()

func spawn_level_pieces():
	clear_existing_pieces()

	var spawn_rect = get_shop_spawn_rect()

	for i in range(level_shapes.size()):
		var piece = piece_scene.instantiate()
		pieces_container.add_child(piece)

		piece.set_board(board)
		piece.set_shape(level_shapes[i])
		piece.piece_color = piece_colors[i % piece_colors.size()]

		var piece_size = piece.get_shape_size_pixels()
		piece.global_position = get_random_position_inside_shop(piece_size, spawn_rect, 16)


func get_total_level_shape_cells() -> int:
	var total = 0

	for shape_data in level_shapes:
		total += count_shape_cells(shape_data)

	return total

func is_level_shape_set_valid() -> bool:
	var board_total_cells = board.cols * board.rows
	var shape_total_cells = get_total_level_shape_cells()

	return board_total_cells == shape_total_cells

func check_level_complete():
	if board.is_board_full():
		current_level_index += 1
		load_current_level()
		
func get_left_half_rect() -> Rect2:
	var viewport_size = get_viewport_rect().size
	return Rect2(Vector2(0, 0), Vector2(viewport_size.x * 0.5, viewport_size.y))
	
func get_shop_spawn_rect() -> Rect2:
	var viewport_size = get_viewport_rect().size
	var right_half_x = viewport_size.x * 0.5
	var right_half_width = viewport_size.x * 0.5
	var shop_size = Vector2(420, 520)

	var shop_x = right_half_x + (right_half_width - shop_size.x) * 0.5
	var shop_y = (viewport_size.y - shop_size.y) * 0.5

	return Rect2(Vector2(shop_x, shop_y), shop_size)	
	
func update_layout_visuals():
	var viewport_size = get_viewport_rect().size

	left_area.position = Vector2(0, 0)
	left_area.size = Vector2(viewport_size.x * 0.5, viewport_size.y)

	right_area.position = Vector2(viewport_size.x * 0.5, 0)
	right_area.size = Vector2(viewport_size.x * 0.5, viewport_size.y)

	var shop_rect = get_shop_spawn_rect()
	shop_spawn_area.position = shop_rect.position
	shop_spawn_area.size = shop_rect.size	
			
			
func count_shape_cells(shape: Array) -> int:
	var count = 0

	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				count += 1

	return count

func get_board_dimensions_from_total_cells(total_cells: int) -> Vector2i:
	var best_cols = 1
	var best_rows = total_cells
	var smallest_diff = total_cells

	for cols in range(1, total_cells + 1):
		if total_cells % cols == 0:
			var rows = total_cells / cols
			var diff = abs(rows - cols)

			if diff < smallest_diff:
				smallest_diff = diff
				best_cols = cols
				best_rows = rows

	return Vector2i(best_cols, best_rows)

func duplicate_shape(shape: Array) -> Array:
	return shape.duplicate(true)
func generate_level_shapes(total_cells: int) -> Array:
	var generated_shapes: Array = []
	var remaining_cells = total_cells
	var snake_shape_count = 0

	while remaining_cells > 0:
		var valid_entries: Array = []

		for entry in shape_pool:
			var shape_data = entry["shape"]
			var shape_type = entry["type"]
			var shape_cells = count_shape_cells(shape_data)

			if shape_cells > remaining_cells:
				continue

			if is_snake_shape_type(shape_type) and snake_shape_count >= max_snake_shapes_per_level:
				continue

			valid_entries.append(entry)

		if valid_entries.is_empty():
			push_error("No valid shapes available for remaining cells: %d" % remaining_cells)
			break

		var chosen_entry = valid_entries.pick_random()
		var chosen_shape = duplicate_shape(chosen_entry["shape"])
		var chosen_type = chosen_entry["type"]

		generated_shapes.append(chosen_shape)
		remaining_cells -= count_shape_cells(chosen_shape)

		if is_snake_shape_type(chosen_type):
			snake_shape_count += 1

	return generated_shapes	
	
func load_level_from_total_cells(total_cells: int):
	var board_dimensions = get_board_dimensions_from_total_cells(total_cells)
	
	if total_cells <= 16:
		max_snake_shapes_per_level = 0
	elif total_cells <= 30:
		max_snake_shapes_per_level = 1
	else:
		max_snake_shapes_per_level = 2	

	board.cols = board_dimensions.x
	board.rows = board_dimensions.y
	board.initialize_grid()
	board.queue_redraw()

	level_shapes = generate_level_shapes(total_cells)

	clear_existing_pieces()
	position_board_in_left_area()
	spawn_level_pieces()
	
func get_random_position_inside_shop(piece_size: Vector2, shop_rect: Rect2, padding: int = 16) -> Vector2:
	var min_x = shop_rect.position.x + padding
	var min_y = shop_rect.position.y + padding

	var max_x = shop_rect.position.x + shop_rect.size.x - piece_size.x - padding
	var max_y = shop_rect.position.y + shop_rect.size.y - piece_size.y - padding

	if max_x < min_x:
		max_x = min_x

	if max_y < min_y:
		max_y = min_y

	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)

	return Vector2(random_x, random_y)
	
func is_snake_shape_type(shape_type: String) -> bool:
	return shape_type == "s" or shape_type == "z"	

func _on_restart_button_pressed() -> void:
	load_current_level()
	
#func _process(delta):
	#var input_vector = Vector2(
		#Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		#Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	#)
#
	#if input_vector.length() > 0:
		#cursor.position += input_vector.normalized() * cursor_speed * delta
#
	#var viewport_size = get_viewport_rect().size
#
	#cursor.position.x = clamp(cursor.position.x, 0, viewport_size.x)
	#cursor.position.y = clamp(cursor.position.y, 0, viewport_size.y)

func _process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# Se o controle estiver sendo usado, move o cursor virtual
	if input_vector.length() > 0.1:
		cursor.global_position += input_vector.normalized() * cursor_speed * delta
	else:
		# Se não houver input do controle, o cursor segue o mouse real
		cursor.global_position = get_global_mouse_position()

	var viewport_size = get_viewport_rect().size
	cursor.global_position.x = clamp(cursor.global_position.x, 0, viewport_size.x)
	cursor.global_position.y = clamp(cursor.global_position.y, 0, viewport_size.y)
	
func get_cursor_position() -> Vector2:
	var game = get_tree().current_scene
	if game != null and game.has_node("Cursor"):
		return game.get_node("Cursor").global_position
	return get_global_mouse_position()
	
	
