extends RefCounted
class_name Move

# Everything needed to play out or undo a move


var from_square := -1
var to_square := -1
var promotion = null
var captured_piece = null
var en_passant := false
var lose_castling := [false, false, false, false]
var prev_ep_target = null
var prev_halfmove_clock = -1
var notation_san = null


func duplicate():
	var new_move = get_script().new()
	new_move.from_square = from_square
	new_move.to_square = to_square
	new_move.promotion = promotion
	new_move.captured_piece = captured_piece
	new_move.en_passant = en_passant
	new_move.lose_castling = lose_castling.duplicate()
	new_move.prev_ep_target = prev_ep_target
	new_move.prev_halfmove_clock = prev_halfmove_clock
	new_move.notation_san = notation_san
	return new_move

# TODO: figure out if I can do this without creating a circular dependancy...
#func _to_string():
#	return "%s%s%s" % [Chess.square_get_name(from_square), Chess.square_get_name(to_square),
#			"" if promotion == null else promotion.to_lower()]
