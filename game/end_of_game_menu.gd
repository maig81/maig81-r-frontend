extends CanvasLayer

@onready var winner_label: Label = $Label
@onready var content: VBoxContainer = $Panel/VBoxContainer


# show_result populates the menu from the match_end payload and reveals it.
# statistics = { final_scores: [...], rounds: [...] } (see backend match_end).
func show_result(winner_uuid: String, statistics: Dictionary) -> void:
	var final_scores: Array = statistics.get("final_scores", [])
	final_scores.sort_custom(_by_player_index)

	_set_winner_text(winner_uuid, final_scores)
	_populate(final_scores, statistics.get("rounds", []))
	visible = true


func _set_winner_text(winner_uuid: String, final_scores: Array) -> void:
	if winner_uuid == GameSession.player_uuid:
		winner_label.text = "YOU WIN"
		return

	for score in final_scores:
		if score.get("player_uuid", "") == winner_uuid:
			winner_label.text = "PLAYER %d WINS" % score.get("player_index", -1)
			return

	winner_label.text = "GAME OVER"


func _populate(final_scores: Array, rounds: Array) -> void:
	for child in content.get_children():
		child.queue_free()

	_add_label("Final Scores")
	for score in final_scores:
		var suffix := " (you)" if score.get("player_uuid", "") == GameSession.player_uuid else ""
		_add_label("Player %d%s: %d" % [score.get("player_index", -1), suffix, score.get("total_score", 0)])

	if not rounds.is_empty():
		_add_label("Rounds")
		for round_data in rounds:
			var player_scores: Array = round_data.get("player_scores", [])
			player_scores.sort_custom(_by_player_index)
			var parts: Array = []
			for score in player_scores:
				parts.append("P%d +%d" % [score.get("player_index", -1), score.get("round_score", 0)])
			_add_label("Round %d:  %s" % [round_data.get("round_number", 0), "   ".join(parts)])

	var button := Button.new()
	button.text = "Main Menu"
	button.pressed.connect(_on_main_menu_pressed)
	content.add_child(button)


func _add_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	content.add_child(label)


func _by_player_index(a: Dictionary, b: Dictionary) -> bool:
	return a.get("player_index", 0) < b.get("player_index", 0)


func _on_main_menu_pressed() -> void:
	GameSession.reset()
	Network.route_to_scene("main_menu")
