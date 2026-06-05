extends CanvasLayer

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause() -> void:
	visible = !visible

func _on_resume_button_pressed() -> void:
	_toggle_pause()

func _on_forfeit_button_pressed() -> void:
	get_tree().paused = false
	GameSession.reset()
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
