extends Button

@onready var underline = $Underline

const FADE_DURATION := 0.15

var _fade_tween: Tween

func _ready() -> void:
	connect("mouse_entered", self._on_mouse_entered)
	connect("mouse_exited", self._on_mouse_exited)

func _fade_underline(to_visible: bool) -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	if to_visible:
		underline.visible = true
		_fade_tween.tween_property(underline, "modulate:a", 1.0, FADE_DURATION)
	else:
		_fade_tween.tween_property(underline, "modulate:a", 0.0, FADE_DURATION)
		_fade_tween.tween_callback(func(): underline.visible = false)

func _on_mouse_entered():
	_fade_underline(true)

func _on_mouse_exited():
	_fade_underline(false)
