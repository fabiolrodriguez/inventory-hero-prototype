extends Node2D

@export var cols: int = 4
@export var rows: int = 4
@export var cell_size: int = 64

@export var grid_line_color: Color = Color(0.8, 0.8, 0.8, 1.0)
@export var grid_fill_color: Color = Color(0.15, 0.15, 0.15, 1.0)
@export var occupied_fill_color: Color = Color(0.4, 0.8, 0.4, 1.0)

var grid_data: Array = []

func _ready():
	initialize_grid()
	queue_redraw()

func initialize_grid():
	grid_data.clear()

	for y in range(rows):
		var row_data: Array = []

		for x in range(cols):
			row_data.append(0)

		grid_data.append(row_data)

func _draw():
	draw_grid()

func draw_grid():
	for y in range(rows):
		for x in range(cols):
			var cell_position = Vector2(x * cell_size, y * cell_size)
			var cell_size_vector = Vector2(cell_size, cell_size)
			var cell_rect = Rect2(cell_position, cell_size_vector)

			var fill_color = grid_fill_color
			if grid_data[y][x] != 0:
				fill_color = occupied_fill_color

			draw_rect(cell_rect, fill_color, true)
			draw_rect(cell_rect, grid_line_color, false, 2.0)
			
func get_board_size_pixels() -> Vector2:
	return Vector2(cols * cell_size, rows * cell_size)

func is_inside_grid(grid_x: int, grid_y: int) -> bool:
	return grid_x >= 0 and grid_x < cols and grid_y >= 0 and grid_y < rows
	
func is_cell_empty(grid_x: int, grid_y: int) -> bool:
	if not is_inside_grid(grid_x, grid_y):
		return false

	return grid_data[grid_y][grid_x] == 0		

func set_cell(grid_x: int, grid_y: int, value: int):
	if not is_inside_grid(grid_x, grid_y):
		return

	grid_data[grid_y][grid_x] = value
	queue_redraw()
	
func grid_to_local(grid_x: int, grid_y: int) -> Vector2:
	return Vector2(grid_x * cell_size, grid_y * cell_size)	
	
func grid_to_global(grid_x: int, grid_y: int) -> Vector2:
	return to_global(grid_to_local(grid_x, grid_y))
	
func local_to_grid(local_position: Vector2) -> Vector2i:
	var grid_x = floor(local_position.x / cell_size)
	var grid_y = floor(local_position.y / cell_size)

	return Vector2i(grid_x, grid_y)
	
func global_to_grid(global_position: Vector2) -> Vector2i:
	var local_position = to_local(global_position)
	return local_to_grid(local_position)	
	
func get_cell_rect(grid_x: int, grid_y: int) -> Rect2:
	var cell_position = grid_to_local(grid_x, grid_y)
	return Rect2(cell_position, Vector2(cell_size, cell_size))	

func is_global_position_inside_board(global_position: Vector2) -> bool:
	var local_position = to_local(global_position)

	return local_position.x >= 0 and local_position.x < cols * cell_size and local_position.y >= 0 and local_position.y < rows * cell_size

func get_mouse_grid_position() -> Vector2i:
	return global_to_grid(get_global_mouse_position())
	
func get_cell_center_local(grid_x: int, grid_y: int) -> Vector2:
	return grid_to_local(grid_x, grid_y) + Vector2(cell_size, cell_size) * 0.5
	
func get_cell_center_global(grid_x: int, grid_y: int) -> Vector2:
	return to_global(get_cell_center_local(grid_x, grid_y))
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var mouse_global = get_global_mouse_position()
		var mouse_grid = global_to_grid(mouse_global)

		print("Mouse global:", mouse_global)
		print("Mouse grid:", mouse_grid)
		
func can_place_piece(shape: Array, grid_x: int, grid_y: int) -> bool:
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				var target_x = grid_x + x
				var target_y = grid_y + y

				if not is_inside_grid(target_x, target_y):
					return false

				if not is_cell_empty(target_x, target_y):
					return false

	return true
	
func place_piece(shape: Array, grid_x: int, grid_y: int):
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				set_cell(grid_x + x, grid_y + y, 1)
				
func clear_piece(shape: Array, grid_x: int, grid_y: int):
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				var target_x = grid_x + x
				var target_y = grid_y + y

				if is_inside_grid(target_x, target_y):
					set_cell(target_x, target_y, 0)
					
func is_board_full() -> bool:
	for y in range(rows):
		for x in range(cols):
			if grid_data[y][x] == 0:
				return false

	return true									
