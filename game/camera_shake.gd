extends Camera2D

@export var intensity: float = .5 # 0.0 = disabled, 1.0 = full

const MAX_OFFSET := Vector2(10.0, 7.0)
const SHAKE_DECAY := 1.5 # shake units lost per second

const SHAKE_BY_KIND := {
	"catapult_destroyed": 0.7,
	"wall_destroyed": 0.5,
	"castle_hit": 0.35,
	"rock_spark": 0.2,
	"splash": 0.3,
}

var shake: float = 0.0

func add_shake(kind: String) -> void:
	shake = clamp(shake + SHAKE_BY_KIND.get(kind, 0.2), 0.0, 1.0)

func _process(delta: float) -> void:
	shake = max(shake - SHAKE_DECAY * delta, 0.0)

	if shake == 0.0 or intensity == 0.0:
		offset = Vector2.ZERO
		return

	var t := Time.get_ticks_msec() / 1000.0
	var current_intensity := shake * shake * intensity
	offset.x = MAX_OFFSET.x * current_intensity * sin(t * 97.0)
	offset.y = MAX_OFFSET.y * current_intensity * sin(t * 67.0)
