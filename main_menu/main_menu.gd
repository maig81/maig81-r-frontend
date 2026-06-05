extends Node2D

@onready var rootPanel: VBoxContainer = $CanvasLayer/MenuStack/RootPanel
@onready var singlePlayerPanel: VBoxContainer = $CanvasLayer/MenuStack/SinglePlayerPanel
@onready var multiPlayerPanel: VBoxContainer = $CanvasLayer/MenuStack/MultiPlayerPanel
@onready var settingsPanel: VBoxContainer = $CanvasLayer/MenuStack/SettingsPanel
var panels: Array[VBoxContainer]


func _ready() -> void:
	panels = [rootPanel, singlePlayerPanel, multiPlayerPanel, settingsPanel]

	#ROOT PANEL
	$CanvasLayer/MenuStack/RootPanel/MultiPlayerButton.pressed.connect(_on_multi_player_button_pressed)
	$CanvasLayer/MenuStack/RootPanel/SinglePlayerButton.pressed.connect(_on_single_player_button_pressed)
	$CanvasLayer/MenuStack/RootPanel/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$CanvasLayer/MenuStack/RootPanel/ExitButton.pressed.connect(_on_exit_button_pressed)

	#BACK BUTTONS
	$CanvasLayer/MenuStack/SinglePlayerPanel/BackButton.pressed.connect(_on_back_button_pressed)
	$CanvasLayer/MenuStack/MultiPlayerPanel/BackButton.pressed.connect(_on_back_button_pressed)
	$CanvasLayer/MenuStack/SettingsPanel/BackButton.pressed.connect(_on_back_button_pressed)

	# MULTIPLAYER PANEL
	$CanvasLayer/MenuStack/MultiPlayerPanel/TwoPlayerBattleGameButton.pressed.connect(_on_two_player_battle_game_button_pressed)
	$CanvasLayer/MenuStack/MultiPlayerPanel/MassiveGameButton.pressed.connect(_on_massive_game_button_pressed)

	#SINGLE PLAYER PANEL
	$CanvasLayer/MenuStack/SinglePlayerPanel/StandardGameButton.pressed.connect(_on_standard_game_button_pressed)
	$CanvasLayer/MenuStack/SinglePlayerPanel/BlitzGameButton.pressed.connect(_on_blitz_game_button_pressed)
	$CanvasLayer/MenuStack/SinglePlayerPanel/EndlessGameButton.pressed.connect(_on_endless_game_button_pressed)
	$CanvasLayer/MenuStack/SinglePlayerPanel/CustomGameButton.pressed.connect(_on_custom_game_button_pressed)

	toggle_panel(rootPanel)

func toggle_panel(panel: VBoxContainer) -> void:
	for p in panels:
		if (p == panel):
			p.visible = true
		else:
			p.visible = false

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
	get_tree().change_scene_to_file("res://hub/hub.tscn")

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
