extends Node2D

@export var cell_size: int = 64
@export var piece_color: Color = Color(0.8, 0.4, 0.2, 1.0)
@export var border_color: Color = Color(0.1, 0.1, 0.1, 1.0)

var shape: Array = [
	[1, 1],
	[1, 0]
]

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	queue_redraw()

func _draw():
	draw_piece()

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				try_start_drag()
			else:
				stop_drag()

func draw_piece():
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				var block_position = Vector2(x * cell_size, y * cell_size)
				var block_rect = Rect2(block_position, Vector2(cell_size, cell_size))

				var current_color = piece_color
				if is_dragging:
					current_color.a = 0.7

				draw_rect(block_rect, current_color, true)
				draw_rect(block_rect, border_color, false, 2.0)

func set_shape(new_shape: Array):
	shape = new_shape
	queue_redraw()

func get_shape_size_cells() -> Vector2i:
	if shape.is_empty():
		return Vector2i.ZERO

	return Vector2i(shape[0].size(), shape.size())

func get_shape_size_pixels() -> Vector2:
	var size_cells = get_shape_size_cells()
	return Vector2(size_cells.x * cell_size, size_cells.y * cell_size)

func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				cells.append(Vector2i(x, y))

	return cells

func get_piece_rect_global() -> Rect2:
	return Rect2(global_position, get_shape_size_pixels())

func try_start_drag():
	var mouse_position = get_global_mouse_position()
	var piece_rect = get_piece_rect_global()

	if piece_rect.has_point(mouse_position):
		is_dragging = true
		drag_offset = mouse_position - global_position

func stop_drag():
	is_dragging = false
