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

	toggle_panel(rootPanel)

func toggle_panel(panel: VBoxContainer) -> void:
	for p in panels:
		if (p == panel):
			p.visible = true
		else:
			p.visible = false


#BUTTON HANDLERS
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
