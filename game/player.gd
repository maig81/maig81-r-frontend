extends Node2D

const BLOCKS = preload("res://game/blocks.gd")
const SIZE = 16


var id: String = ""
var index: int = -1
var is_local = true
var block_id: int = -1
var block_rotation_index: int = -1
var block_nodes: Array = []

func _ready() -> void:
	print_debug("player.gd: _ready", id, is_local)
	var rect = ColorRect.new()
	rect.color = Color(0, 1, 0, 0.2) # Green with 20% opacity
	rect.size = Vector2(SIZE, SIZE)
	add_child(rect)


func _unhandled_input(event: InputEvent) -> void:
	if (!is_local):
		return

	# Move in discrete grid steps (SIZE) on key press.
	# Arrow keys and WASD are supported.
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	var dir := Vector2.ZERO
	match key_event.keycode:
		KEY_LEFT, KEY_A:
			dir.x -= 1
		KEY_RIGHT, KEY_D:
			dir.x += 1
		KEY_UP, KEY_W:
			dir.y -= 1
		KEY_DOWN, KEY_S:
			dir.y += 1
		KEY_R:
			RotateBlock()
		KEY_E:
			PlaceBlock()

	if dir != Vector2.ZERO:
		position += dir * SIZE
		Network.send_message("move_cursor", {"x": int(dir.x), "y": int(dir.y)})


func MoveCursor(new_position: Vector2) -> void:
	position = new_position * SIZE

func RotateBlock() -> void:
	DrawBlock(block_id, (block_rotation_index + 1) % 4)
	Network.send_message("rotate_block", {})

func PlaceBlock() -> void:
	Network.send_message("place_block", {})


func DrawBlock(new_block_id: int, new_rotation_index: int) -> void:
	if new_block_id == block_id and new_rotation_index == block_rotation_index:
		return

	# Remove existing block nodes
	for node in block_nodes:
		node.queue_free()
	block_nodes.clear()

	# Draw new block
	var block = BLOCKS.BLOCKS[new_block_id][new_rotation_index]
	for cell in block:
		var cell_position_x = cell[0]
		var cell_position_y = cell[1]
		var cell_position = Vector2(cell_position_x, cell_position_y) * SIZE

		var rect = ColorRect.new()
		rect.color = Color(1, 0, 0, 0.3) # Green with 20% opacity
		rect.size = Vector2(SIZE, SIZE)
		rect.position = cell_position
		add_child(rect)
		block_nodes.append(rect)

	# Update block ID and rotation index
	block_id = new_block_id
	block_rotation_index = new_rotation_index
