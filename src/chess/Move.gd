extends Reference
class_name Move

# Everything needed to play out or undo a move

var from_square = -1
var to_square = -1
var promotion = null
var captured_piece = null
var en_passant = false
var lose_castling = [false, false, false, false]
var prev_ep_target = null
var prev_halfmove_clock = -1
