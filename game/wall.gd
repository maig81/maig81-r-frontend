extends Node2D


const PLAYER_COLORS: Array = [
	Color("4a90d9"),
	Color("e05c5c"),
	Color("5cb85c"),
	Color("f0ad4e"),
]

var player_idx: int = 0


func _ready() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(GameSession.CELL_SIZE, GameSession.CELL_SIZE)
	rect.color = PLAYER_COLORS[player_idx % PLAYER_COLORS.size()]
	add_child(rect)
