extends Node2D

@export var piece_scene: PackedScene

@onready var board = $Board
@onready var pieces_container = $Pieces
var current_level_index: int = 0

var level_shapes: Array = [
	[
		[1, 1],
		[1, 0]
	], # 3
	[
		[1, 1, 1]
	], # 3
	[
		[1, 1],
		[1, 1]
	], # 4
	[
		[1],
		[1]
	], # 2
	[
		[1, 1]
	], # 2
	[
		[1],
		[1]
	] # 2
]

var levels: Array = [
	{
		"cols": 4,
		"rows": 4,
		"shapes": [
			[
				[1, 1],
				[1, 0]
			],
			[
				[1, 1, 1]
			],
			[
				[1, 1],
				[1, 1]
			],
			[
				[1],
				[1],
				[1]
			],
			[
				[1, 1, 0],
				[0, 1, 1]
			]
		]
	}
]

func _ready():
	if not is_level_shape_set_valid():
		push_error("Level shape set is invalid: total piece cells do not match board size.")
		return
	spawn_level_pieces()

func clear_existing_pieces():
	for child in pieces_container.get_children():
		child.queue_free()

func spawn_level_pieces():
	clear_existing_pieces()

	var board_size = board.get_board_size_pixels()
	var start_x = board.global_position.x + board_size.x + 60
	var current_y = board.global_position.y
	var spacing = 24

	for shape_data in level_shapes:
		var piece = piece_scene.instantiate()
		pieces_container.add_child(piece)

		piece.set_board(board)
		piece.set_shape(shape_data)

		piece.global_position = Vector2(start_x, current_y)

		current_y += piece.get_shape_size_pixels().y + spacing
		
func check_level_complete():
	if board.is_board_full():
		print("LEVEL COMPLETE")
		
func count_shape_cells(shape: Array) -> int:
	var count = 0

	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				count += 1

	return count
	
func get_total_level_shape_cells() -> int:
	var total = 0

	for shape_data in level_shapes:
		total += count_shape_cells(shape_data)
	
	print(total)
	return total
	
func is_level_shape_set_valid() -> bool:
	var board_total_cells = board.cols * board.rows
	var shape_total_cells = get_total_level_shape_cells()

	return board_total_cells == shape_total_cells
	
func load_level():
	clear_existing_pieces()
	board.initialize_grid()
	spawn_level_pieces()	
