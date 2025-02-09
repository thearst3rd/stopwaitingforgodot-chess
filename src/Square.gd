extends ColorRect


signal piece_grabbed(from_square)
signal piece_dropped(from_square, to_square)


var file := -1
var rank := -1
var index := -1
var san_name := "-"

var grabbable := false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			$Piece.modulate = Color.WHITE
			$LegalMoveIndicator.hide()

func _connect_square_signals(game: ChessGame):
	piece_grabbed.connect(game._on_Square_piece_grabbed)
	piece_dropped.connect(game._on_Square_piece_dropped)


func _get_drag_data(_position: Vector2):
	if $Piece.texture == null or not grabbable:
		return null

	piece_grabbed.emit(index)

	var drag_preview_texture := TextureRect.new()
	drag_preview_texture.expand = true
	drag_preview_texture.texture = $Piece.texture
	drag_preview_texture.size = $Piece.size

	var drag_preview_control := Control.new()
	drag_preview_control.add_child(drag_preview_texture)
	drag_preview_texture.position = -0.5 * $Piece.size

	set_drag_preview(drag_preview_control)

	$Piece.modulate = Color(1.0, 1.0, 1.0, 0.25)

	var data := {}
	data["from_square"] = index
	return data


func _can_drop_data(_position: Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false

	if typeof(data["from_square"]) != TYPE_INT:
		return false

	return true


func _drop_data(_position: Vector2, data) -> void:
	piece_dropped.emit(data["from_square"], index)
