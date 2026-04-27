extends Node

var room_id: String = ""
var player_uuid: String = ""
var player_index: int = -1

var terrain_width: int = 0
var terrain_height: int = 0
var terrain_cells: Array = []

var game_status: String = ""
var players: Dictionary = {}
var wall_cells: Array = []

const CELL_SIZE: int = 16

func reset() -> void:
	room_id = "";
	player_uuid = "";
	player_index = -1
	terrain_width = 0;
	terrain_height = 0;
	terrain_cells = []
	game_status = "";
	players = {};
	wall_cells = []
