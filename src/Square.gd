extends ColorRect


var file = -1
var rank = -1
var square_name = "##"


func get_drag_data(_position):
	if $Piece.texture == null:
		return null

	var drag_preview_texture = TextureRect.new()
	drag_preview_texture.expand = true
	drag_preview_texture.texture = $Piece.texture
	drag_preview_texture.rect_size = $Piece.rect_size

	var drag_preview_control = Control.new()
	drag_preview_control.add_child(drag_preview_texture)
	drag_preview_texture.rect_position = -0.5 * $Piece.rect_size

	set_drag_preview(drag_preview_control)

	var data = {}
	data["from_square"] = self
	return data

func can_drop_data(_position, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false

	if not data["from_square"]:
		return false

	if data["from_square"] == self:
		return false

	return true

func drop_data(_position, data):
	var from_piece = data["from_square"].get_node("Piece")
	$Piece.texture = from_piece.texture
	from_piece.texture = null

	print(data["from_square"].square_name + square_name)
