extends Node2D


const PLAYER_COLORS: Array = [
	Color("4a90d940"),
	Color("e05c5c40"),
	Color("5cb85c40"),
	Color("f0ad4e40"),
]

var player_idx: int = 0


func _ready() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(GameSession.CELL_SIZE, GameSession.CELL_SIZE)
	rect.color = PLAYER_COLORS[player_idx % PLAYER_COLORS.size()]
	add_child(rect)
