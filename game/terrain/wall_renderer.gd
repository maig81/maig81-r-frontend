extends Node

const Wall = preload("res://game/terrain/wall.tscn")

var _rendered: Dictionary = {}

func draw_walls(cells: Array) -> void:
	for cell in cells:
		var x: int = cell[0]
		var y: int = cell[1]
		var player_idx: int = cell[2]
		var key: String = "%d,%d" % [x, y]
		if _rendered.has(key):
			continue
		var wall_node = Wall.instantiate()
		wall_node.player_idx = player_idx
		wall_node.position = Vector2(x, y) * GameSession.CELL_SIZE
		add_child(wall_node)
		_rendered[key] = wall_node


func clear() -> void:
	for node in _rendered.values():
		node.queue_free()
	_rendered.clear()
