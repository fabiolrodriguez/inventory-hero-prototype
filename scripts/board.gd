extends Node2D

@export var cols: int = 6
@export var rows: int = 6
@export var cell_size: int = 64

@export var grid_line_color: Color = Color(0.8, 0.8, 0.8, 1.0)
@export var grid_fill_color: Color = Color(0.15, 0.15, 0.15, 1.0)
@export var occupied_fill_color: Color = Color(0.4, 0.8, 0.4, 1.0)

var grid_data: Array = []

func _ready():
	initialize_grid()
	set_cell(1, 1, 1)
	set_cell(2, 1, 1)
	set_cell(2, 2, 1)
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

#func draw_grid():
	#for y in range(rows):
		#for x in range(cols):
			#var cell_position = Vector2(x * cell_size, y * cell_size)
			#var cell_size_vector = Vector2(cell_size, cell_size)
			#var cell_rect = Rect2(cell_position, cell_size_vector)
#
			#draw_rect(cell_rect, grid_fill_color, true)
			#draw_rect(cell_rect, grid_line_color, false, 2.0)

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
	
	
