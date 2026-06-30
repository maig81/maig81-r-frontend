extends Node2D

@onready var rootPanel: VBoxContainer = $MainMenuStation/RootPanel
@onready var singlePlayerPanel: VBoxContainer = $MainMenuStation/SinglePlayerPanel
@onready var multiPlayerPanel: VBoxContainer = $MainMenuStation/MultiPlayerPanel
@onready var settingsPanel: VBoxContainer = $MainMenuStation/SettingsPanel
var panels: Array[VBoxContainer]

const STATION_POS := {
	"main": Vector2(0, 0),
	"rooms": Vector2(2000, 0),
}


func _ready() -> void:
	panels = [rootPanel, singlePlayerPanel, multiPlayerPanel, settingsPanel]
	#ROOT PANEL
	$MainMenuStation/RootPanel/MultiPlayerButton.pressed.connect(_on_multi_player_button_pressed)
	$MainMenuStation/RootPanel/SinglePlayerButton.pressed.connect(_on_single_player_button_pressed)
	$MainMenuStation/RootPanel/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$MainMenuStation/RootPanel/ExitButton.pressed.connect(_on_exit_button_pressed)

	#BACK BUTTONS
	$MainMenuStation/SinglePlayerPanel/BackButton.pressed.connect(_on_back_button_pressed)
	$MainMenuStation/MultiPlayerPanel/BackButton.pressed.connect(_on_back_button_pressed)
	$MainMenuStation/SettingsPanel/BackButton.pressed.connect(_on_back_button_pressed)

	# MULTIPLAYER PANEL
	$MainMenuStation/MultiPlayerPanel/TwoPlayerBattleGameButton.pressed.connect(_on_two_player_battle_game_button_pressed)
	$MainMenuStation/MultiPlayerPanel/MassiveGameButton.pressed.connect(_on_massive_game_button_pressed)

	#SINGLE PLAYER PANEL
	$MainMenuStation/SinglePlayerPanel/StandardGameButton.pressed.connect(_on_standard_game_button_pressed)
	$MainMenuStation/SinglePlayerPanel/BlitzGameButton.pressed.connect(_on_blitz_game_button_pressed)
	$MainMenuStation/SinglePlayerPanel/EndlessGameButton.pressed.connect(_on_endless_game_button_pressed)
	$MainMenuStation/SinglePlayerPanel/CustomGameButton.pressed.connect(_on_custom_game_button_pressed)

	$MainMenuStation/SinglePlayerPanel/DebugGameButton.pressed.connect(_on_single_player_debug_pressed)

	toggle_panel(rootPanel)

	Network.message_received.connect(_on_message_received)

func _exit_tree() -> void:
	Network.message_received.disconnect(_on_message_received)

func _on_message_received(type: String, payload: Variant) -> void:
	match type:
		"room_created":
			GameSession.room_id = payload.get("room_id", "")
			GameSession.player_uuid = payload.get("player_uuid", "")
			Network.send_message("player_ready")
			Network.route_to_scene(payload.get("next_screen", ""))
		"room_error":
			print_debug("room_error", payload)

func toggle_panel(panel: VBoxContainer) -> void:
	for p in panels:
		if (p == panel):
			p.visible = true
		else:
			p.visible = false

func travel_to(station: String) -> void:
	$Camera2D.position = STATION_POS[station]

# ------------------------------------------------------------------------------------------------
# ROOT PANEL BUTTON HANDLERS
# ------------------------------------------------------------------------------------------------
func _on_multi_player_button_pressed() -> void:
	toggle_panel(multiPlayerPanel)

func _on_single_player_button_pressed() -> void:
	toggle_panel(singlePlayerPanel)

func _on_settings_button_pressed() -> void:
	toggle_panel(settingsPanel)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	toggle_panel(rootPanel)


# ------------------------------------------------------------------------------------------------
# MULTIPLAYER PANEL
# ------------------------------------------------------------------------------------------------
func _on_two_player_battle_game_button_pressed() -> void:
	GameSession.game_mode = "two_player_battle"
	get_tree().change_scene_to_file("res://matchmaking/matchmaking.tscn")

func _on_massive_game_button_pressed() -> void:
	print_debug("Massive game button pressed")


# ------------------------------------------------------------------------------------------------
# SINGLE PLAYER PANEL
# ------------------------------------------------------------------------------------------------
func _on_standard_game_button_pressed() -> void:
	print_debug("Standard game button pressed")

func _on_blitz_game_button_pressed() -> void:
	print_debug("Blitz game button pressed")

func _on_endless_game_button_pressed() -> void:
	print_debug("Endless game button pressed")

func _on_custom_game_button_pressed() -> void:
	print_debug("Custom game button pressed")

func _on_single_player_debug_pressed() -> void:
	GameSession.game_mode = "single_player_debug"
	Network.send_message("create_room", {"mode": GameSession.game_mode})
	print_debug("Custom game button pressed")
