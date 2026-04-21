extends Node2D

@export var cell_size: int = 64
@export var piece_color: Color = Color(0.8, 0.4, 0.2, 1.0)
@export var border_color: Color = Color(0.1, 0.1, 0.1, 1.0)

var shape: Array = [
	[1, 1],
	[1, 0]
]

var board = null
var original_position: Vector2 = Vector2.ZERO

var placed: bool = false
var placed_grid_position: Vector2i = Vector2i.ZERO
var previous_grid_position: Vector2i = Vector2i.ZERO
var was_placed_before_drag: bool = false

var is_dragging: bool = false
#var drag_offset: Vector2 = Vector2.ZERO

static var selected_piece = null

func _ready():
	queue_redraw()

func _draw():
	draw_piece()

func _process(delta):
	if is_dragging and selected_piece == self:
		global_position = get_global_mouse_position() - get_shape_size_pixels() * 0.5

	queue_redraw()

func _input(event):
	if event.is_action_pressed("action_pick"):
		if is_dragging and selected_piece == self:
			stop_drag()
			try_place_on_board()
		else:
			try_start_drag()

	if event.is_action_pressed("action_rotate") and selected_piece == self:
		try_rotate()

#func _input(event):
	##if event is InputEventMouseButton:
#
	#if Input.is_action_just_pressed("action_pick"):
		#if is_dragging and selected_piece == self:
			#stop_drag()
			#try_place_on_board()
		#else:
			#try_start_drag()
		#
		##if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#if Input.is_action_just_pressed("action_pick"):		
			#if is_dragging and selected_piece == self:
				#stop_drag()
				#try_place_on_board()
			#else:
				#try_start_drag()
#
	#if event is InputEventKey:
		#if event.pressed and not event.echo:
			##if event.keycode == KEY_R and selected_piece == self:
			#if Input.is_action_just_pressed("action_rotate") and selected_piece == self:
				#try_rotate()

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
				#draw_rect(block_rect, border_color, false, 2.0)
				var current_border_color = border_color
				var border_width = 2.0

				if selected_piece == self:
					current_border_color = Color(1.0, 1.0, 1.0, 1.0)
					border_width = 4.0

				draw_rect(block_rect, current_border_color, false, border_width)

func set_board(new_board):
	board = new_board

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
	#var mouse_position = get_global_mouse_position()
	var mouse_position = get_cursor_position()
	var piece_rect = get_piece_rect_global()

	if piece_rect.has_point(mouse_position):
		selected_piece = self
		get_parent().move_child(self, get_parent().get_child_count() - 1)

		original_position = global_position
		was_placed_before_drag = placed

		if placed and board != null:
			previous_grid_position = placed_grid_position
			board.clear_piece(shape, placed_grid_position.x, placed_grid_position.y)
			placed = false

		is_dragging = true

func stop_drag():
	is_dragging = false

func try_place_on_board():
	if board == null:
		return

	var piece_center = get_piece_center_global()

	# Se soltou fora da área magnética do board,
	# a peça fica onde foi largada e permanece desencaixada.
	if not board.is_piece_center_inside_snap_area(piece_center):
		placed = false
		return

	var preferred_grid = board.get_snap_grid_for_piece(global_position)
	var best_grid = board.find_best_placement_for_piece(shape, preferred_grid.x, preferred_grid.y)

	if best_grid != null:
		board.place_piece(shape, best_grid.x, best_grid.y)
		global_position = board.grid_to_global(best_grid.x, best_grid.y)
		placed = true
		placed_grid_position = best_grid

		var game = get_tree().current_scene
		if game != null and game.has_method("check_level_complete"):
			game.check_level_complete()
	else:
		global_position = original_position

		if was_placed_before_drag and board != null:
			board.place_piece(shape, previous_grid_position.x, previous_grid_position.y)
			placed = true
			placed_grid_position = previous_grid_position
			
	selected_piece = null

func get_rotated_shape_clockwise(source_shape: Array) -> Array:
	var new_shape: Array = []

	if source_shape.is_empty():
		return new_shape

	var old_height = source_shape.size()
	var old_width = source_shape[0].size()

	for x in range(old_width):
		var new_row: Array = []

		for y in range(old_height - 1, -1, -1):
			new_row.append(source_shape[y][x])

		new_shape.append(new_row)

	return new_shape
	
func rotate_shape_clockwise():
	shape = get_rotated_shape_clockwise(shape)
	queue_redraw()	

func try_rotate():
	var old_shape = shape.duplicate(true)
	var rotated_shape = get_rotated_shape_clockwise(shape)

	if not placed:
		shape = rotated_shape
		queue_redraw()
		return

	if board == null:
		shape = rotated_shape
		queue_redraw()
		return

	# remove do board temporariamente
	board.clear_piece(shape, placed_grid_position.x, placed_grid_position.y)

	if board.can_place_piece(rotated_shape, placed_grid_position.x, placed_grid_position.y):
		shape = rotated_shape
		board.place_piece(shape, placed_grid_position.x, placed_grid_position.y)
		global_position = board.grid_to_global(placed_grid_position.x, placed_grid_position.y)
	else:
		# volta ao shape antigo e recoloca
		shape = old_shape
		board.place_piece(shape, placed_grid_position.x, placed_grid_position.y)

	queue_redraw()

func get_piece_center_global() -> Vector2:
	return global_position + get_shape_size_pixels() * 0.5
	
func get_cursor_position() -> Vector2:
	var game = get_tree().current_scene
	if game != null and game.has_node("Cursor"):
		return game.get_node("Cursor").global_position
	return get_global_mouse_position()	
