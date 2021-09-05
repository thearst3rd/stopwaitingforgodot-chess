extends ColorRect

signal piece_grabbed(from_square)
signal piece_dropped(from_square, to_square)


var file = -1
var rank = -1
var index = -1
var san_name = "-"

var grabbable = false


func get_drag_data(_position):
	if $Piece.texture == null or not grabbable:
		return null

	emit_signal("piece_grabbed", index)

	var drag_preview_texture = TextureRect.new()
	drag_preview_texture.expand = true
	drag_preview_texture.texture = $Piece.texture
	drag_preview_texture.rect_size = $Piece.rect_size

	var drag_preview_control = Control.new()
	drag_preview_control.add_child(drag_preview_texture)
	drag_preview_texture.rect_position = -0.5 * $Piece.rect_size

	set_drag_preview(drag_preview_control)

	$Piece.modulate = Color(1.0, 1.0, 1.0, 0.25)

	var data = {}
	data["from_square"] = index
	return data

func can_drop_data(_position, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false

	if typeof(data["from_square"]) != TYPE_INT:
		return false

	return true

func drop_data(_position, data):
	emit_signal("piece_dropped", data["from_square"], index)


## CALLBACKS ##

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			$Piece.modulate = Color.white
			$LegalMoveIndicator.hide()
