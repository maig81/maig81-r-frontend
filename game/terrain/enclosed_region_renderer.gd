extends Node

const EnclosedTile = preload("res://game/terrain/enclosed_tile.tscn")

var _rendered: Dictionary = {}

func draw_regions(regions: Array) -> void:
	for region in regions:
		for cell in region.cells:
			var x: int = cell.x
			var y: int = cell.y
			#var player_idx: int = region.player
			var key: String = "%d,%d" % [x, y]
			if _rendered.has(key):
				continue

			var tile_node = EnclosedTile.instantiate()
			tile_node.player_idx = region.player
			tile_node.position = Vector2(x, y) * GameSession.CELL_SIZE
			add_child(tile_node)
			_rendered[key] = tile_node


func clear() -> void:
	for node in _rendered.values():
		node.queue_free()
	_rendered.clear()
