extends Node

const Castle = preload("res://game/terrain/castle.tscn")

var _rendered: Dictionary = {}

func draw_castles(castles: Array) -> void:
	print_debug(castles)
	for castle in castles:
		var x: int = castle[0]
		var y: int = castle[1]
		var key: String = "%d,%d" % [x, y]
		if _rendered.has(key):
			continue
		var castle_node = Castle.instantiate()
		castle_node.position = Vector2(x, y) * GameSession.CELL_SIZE
		add_child(castle_node)
		_rendered[key] = castle_node

func clear() -> void:
	for node in _rendered.values():
		node.queue_free()
	_rendered.clear()


func set_surrounded_castles(cells: Array) -> void:
	var surrounded: Dictionary = {}
	for region in cells:
		var player_index: int = region.get("player", -1)
		for castle in region.castles:
			surrounded["%d,%d" % [castle.x, castle.y]] = player_index

	# apply to all rendered castles
	for key in _rendered:
		_rendered[key].set_surrounded(surrounded.has(key), surrounded.get(key, -1))
