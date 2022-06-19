extends Control


const ANG_SPEED = PI
const ARC_ANGLE = 3 * PI / 2

var offset := 0.0

onready var game := find_parent("Game") as Control


func _process(delta) -> void:
	offset += ANG_SPEED * delta
	if offset >= TAU:
		offset -= TAU
	update()


func _draw() -> void:
	if game.bot_thinking:
		draw_arc(Vector2(14, 14), 12, offset, offset + ARC_ANGLE, 32, Color.white, 3.0, true)
