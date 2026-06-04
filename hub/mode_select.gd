extends Node2D

func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer/TwoPlayerBattleButton.pressed.connect(_on_two_player)
	$CanvasLayer/Control/VBoxContainer/DebugButton.pressed.connect(_on_debug)

func _on_debug() -> void:
	_select("debug")

func _on_two_player() -> void:
	_select("two_player_battle")

func _select(mode: String) -> void:
	GameSession.game_mode = mode
	get_tree().change_scene_to_file("res://hub/hub.tscn")
