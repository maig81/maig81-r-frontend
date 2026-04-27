extends Node2D

var is_surrounded: bool = false

var rect: ColorRect = null
var player_index: int = -1

func _ready() -> void:
	rect = ColorRect.new()
	rect.size = Vector2(GameSession.CELL_SIZE, GameSession.CELL_SIZE)
	rect.color = Color("000000")
	add_child(rect)

func set_surrounded(surrounded: bool, player_index: int) -> void:
	if is_surrounded == surrounded:
		return

	# Change state if it's different
	is_surrounded = surrounded
	if is_surrounded:
		self.player_index = player_index
		rect.color = Color("ffffff")
	else:
		player_index = -1
		rect.color = Color("000000")
