extends CanvasLayer

@onready var v_box_container: VBoxContainer = $VBoxContainer
var _prev_phase: String = ""

func update_scores(scores: Array) -> void:
	for child in v_box_container.get_children():
		child.queue_free()

	scores.sort_custom(func(a, b): return a.player_index < b.player_index)

	for score in scores:
		var player_index: int = score.get("player_index", -1)
		var round_score: int = score.get("round_score", 0)
		var total_score: int = score.get("total_score", 0)
		var player_uuid: String = score.get("player_uuid", "")

		var suffix := " (you)" if player_uuid == GameSession.player_uuid else ""
		var score_label := Label.new()
		score_label.text = "Player %d%s: +%d (total %d)" % [player_index, suffix, round_score, total_score]
		v_box_container.add_child(score_label)


func _process(_delta: float) -> void:
	_check_phase_change()

func _check_phase_change() -> void:
	if GameSession.current_phase == _prev_phase:
		return

	if GameSession.current_phase == "place_weapons":
		visible = false

	_prev_phase = GameSession.current_phase
