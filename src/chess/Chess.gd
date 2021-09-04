extends Reference
class_name Chess

# This class contains all the code for a chess position, including legal move generation, game end conditions, etc

const INITIAL_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

enum SQUARES {
	A8, B8, C8, D8, E8, F8, G8, H8,
	A7, B7, C7, D7, E7, F7, G7, H7,
	A6, B6, C6, D6, E6, F6, G6, H6,
	A5, B5, C5, D5, E5, F5, G5, H5,
	A4, B4, C4, D4, E4, F4, G4, H4,
	A3, B3, C3, D3, E3, F3, G3, H3,
	A2, B2, C2, D2, E2, F2, G2, H2,
	A1, B1, C1, D1, E1, F1, G1, H1,
}


static func square_index(file : int, rank : int) -> int:
	return 8 * (8 - rank) + file - 1

static func square_get_file(square_index : int) -> int:
	return (square_index % 8) + 1

static func square_get_rank(square_index : int) -> int:
	return 8 - (square_index / 8)

static func square_get_name(square_index) -> String:
	if typeof(square_index) != TYPE_INT or square_index < 0 or square_index >= 64:
		return "-"
	return char(ord("a") - 1 + square_get_file(square_index)) + str(square_get_rank(square_index))

static func square_is_dark(square_index : int) -> bool:
	var file = square_get_file(square_index)
	var rank = square_get_rank(square_index)
	return (rank + file) % 2 == 0

static func piece_color(piece_char : String) -> bool:
	return ord(piece_char) >= ord("a")


var pieces = [
	"r", "n", "b", "q", "k", "b", "n", "r",
	"p", "p", "p", "p", "p", "p", "p", "p",
	null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null,
	"P", "P", "P", "P", "P", "P", "P", "P",
	"R", "N", "B", "Q", "K", "B", "N", "R"
]	# indexed list of pieces. 0 = a8, 63 = h1
var turn = false 	# false is white, true is black
var castling = [true, true, true, true]	# white O-O, O-O-O, black O-O, O-O-O
var ep_target = null	# Square index of ep target square
var halfmove_clock = 0
var fullmove_counter = 1

var move_stack = []


func duplicate():
	var new_chess = .new()	# ???? Took me a while. Chess.new() doesn't work, new() doesn't work, but .new() does
	new_chess.pieces = pieces.duplicate()
	new_chess.turn = turn
	new_chess.castling = castling.duplicate()
	new_chess.ep_target = ep_target
	new_chess.halfmove_clock = halfmove_clock
	new_chess.fullmove_counter = fullmove_counter
	new_chess.move_stack = []
	for move in move_stack:
		new_chess.move_stack.push_back(move.duplicate())
	return new_chess

func set_fen(fen):
	# TODO
	pass

func get_fen():
	var fen_pieces = ""
	var blanks = 0
	for i in range(64):
		if i > 0 and i % 8 == 0:
			if blanks > 0:
				fen_pieces += str(blanks)
				blanks = 0
			fen_pieces += "/"
		if pieces[i] == null:
			blanks += 1
		else:
			if blanks > 0:
				fen_pieces += str(blanks)
				blanks = 0
			fen_pieces += pieces[i]
	if blanks > 0:
		fen_pieces += str(blanks)

	var fen_turn = "b" if turn else "w"

	var fen_castling = ""
	if castling[0]: fen_castling += "K"
	if castling[1]: fen_castling += "Q"
	if castling[2]: fen_castling += "k"
	if castling[3]: fen_castling += "q"
	if fen_castling == "":
		fen_castling = "-"

	return "%s %s %s %s %d %d" % [fen_pieces, fen_turn, fen_castling, square_get_name(ep_target), halfmove_clock,
			fullmove_counter]

# Creates a Move object from these squares. Does not check if the move is legal
func construct_move(from_square, to_square, promotion = "q"):
	var move = Move.new()
	move.from_square = from_square
	move.to_square = to_square
	move.captured_piece = pieces[to_square]

	if pieces[from_square].to_lower() == "p":
		var rank = square_get_rank(to_square)
		if rank == 1 or rank == 8:
			move.promotion = promotion.to_lower() if turn else promotion.to_upper()
		if to_square == ep_target:
			move.en_passant = true

	if pieces[from_square].to_lower() == "k":
		if turn:
			if castling[2]: move.lose_castling[2] = true
			if castling[3]: move.lose_castling[3] = true
		else:
			if castling[0]: move.lose_castling[0] = true
			if castling[1]: move.lose_castling[1] = true

	if castling[0] and to_square == SQUARES.H1 or from_square == SQUARES.H1:
		move.lose_castling[0] = true
	if castling[1] and to_square == SQUARES.A1 or from_square == SQUARES.A1:
		move.lose_castling[1] = true
	if castling[2] and to_square == SQUARES.H8 or from_square == SQUARES.H8:
		move.lose_castling[2] = true
	if castling[3] and to_square == SQUARES.A8 or from_square == SQUARES.A8:
		move.lose_castling[3] = true

	return move

# Plays the given move on the board and updates the internal state accordingly
func play_move(move):
	if move.promotion:
		pieces[move.to_square] = move.promotion
	else:
		pieces[move.to_square] = pieces[move.from_square]
	pieces[move.from_square] = null
	if move.en_passant:
		var delta = -8 if turn else 8
		pieces[ep_target + delta] = null

	# Castling
	if pieces[move.to_square].to_lower() == "k":
		if move.to_square == move.from_square + 2: # O-O
			pieces[move.from_square + 1] = pieces[move.to_square + 1]
			pieces[move.to_square + 1] = null
		elif move.to_square == move.from_square - 2: # O-O-O
			pieces[move.from_square - 1] = pieces[move.to_square - 2]
			pieces[move.to_square - 2] = null

	for i in range(4):
		if move.lose_castling[i]:
			castling[i] = false

	# Double pawn step
	move.prev_ep_target = ep_target
	ep_target = null
	if pieces[move.to_square].to_lower() == "p":
		var delta = 8 if turn else -8
		if move.to_square == move.from_square + (2 * delta):
			ep_target = move.from_square + delta

	move.prev_halfmove_clock = halfmove_clock
	if move.en_passant or move.captured_piece != null or pieces[move.to_square].to_lower() == "p":
		halfmove_clock = 0
	else:
		halfmove_clock += 1

	turn = not turn
	if not turn:
		fullmove_counter += 1

	move_stack.push_back(move)

# Undoes the most recent move
func undo():
	if move_stack.size() == 0:
		return

	var move = move_stack.pop_back()

	turn = not turn
	if turn:
		fullmove_counter -= 1

	halfmove_clock = move.prev_halfmove_clock
	ep_target = move.prev_ep_target

	# Castling
	if pieces[move.to_square].to_lower() == "k":
		if move.to_square == move.from_square + 2: # O-O
			pieces[move.to_square + 1] = pieces[move.from_square + 1]
			pieces[move.from_square + 1] = null
		elif move.to_square == move.from_square - 2: # O-O-O
			pieces[move.to_square - 2] = pieces[move.from_square - 1]
			pieces[move.from_square - 1] = null

	for i in range(4):
		if move.lose_castling[i]:
			castling[i] = true

	if move.promotion:
		pieces[move.from_square] = "p" if turn else "P"
	else:
		pieces[move.from_square] = pieces[move.to_square]
	pieces[move.to_square] = move.captured_piece
	if move.en_passant:
		var delta = -8 if turn else 8
		pieces[move.prev_ep_target + delta] = "P" if turn else "p"


## MOVE GENERATION ##

const ROOK_OFFSETS = [[-1, 0], [0, 1], [1, 0] ,[0, -1]]
const BISHOP_OFFSETS = [[-1, -1], [-1, 1], [1, 1] ,[1, -1]]
const ROYAL_OFFSETS = ROOK_OFFSETS + BISHOP_OFFSETS
const KNIGHT_OFFSETS = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]

# Generate all pseudo-legal moves (i.e., the pieces move by their rules but there is no check)
func generate_pseudo_legal_moves():
	var moves = []
	for square in range(64):
		var piece = pieces[square]
		if piece == null:
			continue
		var color = piece_color(piece)
		if color != turn:
			continue

		match piece:
			"K", "k":
				moves.append_array(generate_leaping_moves(color, square, ROYAL_OFFSETS))
			"Q", "q":
				moves.append_array(generate_sliding_moves(color, square, ROYAL_OFFSETS))
			"R", "r":
				moves.append_array(generate_sliding_moves(color, square, ROOK_OFFSETS))
			"B", "b":
				moves.append_array(generate_sliding_moves(color, square, BISHOP_OFFSETS))
			"N", "n":
				moves.append_array(generate_leaping_moves(color, square, KNIGHT_OFFSETS))
			"p", "P":
				moves.append_array(generate_pawn_moves(color, square))
	return moves

func generate_leaping_moves(col, square_index, offsets):
	var moves = []
	for offset in offsets:
		var d_file = offset[0]
		var d_rank = offset[1]
		var file = square_get_file(square_index) + d_file
		var rank = square_get_rank(square_index) + d_rank
		if file >= 1 and file <= 8 and rank >= 1 and rank <= 8:
			var new_square = square_index(file, rank)
			var piece = pieces[new_square]
			if piece == null or piece_color(piece) != col:
				moves.append(construct_move(square_index, new_square))
	return moves

func generate_sliding_moves(col, square_index, offsets):
	var moves = []
	for offset in offsets:
		var d_file = offset[0]
		var d_rank = offset[1]
		var file = square_get_file(square_index) + d_file
		var rank = square_get_rank(square_index) + d_rank
		while file >= 1 and file <= 8 and rank >= 1 and rank <= 8:
			var new_square = square_index(file, rank)
			var piece = pieces[new_square]
			if piece != null && piece_color(piece) == col:
				break
			moves.append(construct_move(square_index, new_square))
			if piece != null:
				break
			file += d_file
			rank += d_rank
	return moves

func generate_pawn_move_list(from_square, to_square):
	var rank = square_get_rank(to_square)
	if rank == 1 or rank == 8:
		return [
			construct_move(from_square, to_square, "q"),
			construct_move(from_square, to_square, "n"),
			construct_move(from_square, to_square, "r"),
			construct_move(from_square, to_square, "b"),
		]
	else:
		return [
			construct_move(from_square, to_square)
		]

func generate_pawn_moves(col, square_index):
	var moves = []
	var delta = 8 if col else -8
	if pieces[square_index + delta] == null:
		moves.append_array(generate_pawn_move_list(square_index, square_index + delta))
		var target_rank = 7 if col else 2
		if square_get_rank(square_index) == target_rank:
			moves.append_array(generate_pawn_move_list(square_index, square_index + 2 * delta))
	var file = square_get_file(square_index)
	if file > 1:
		var new_square = square_index + delta - 1
		var piece = pieces[new_square]
		if new_square == ep_target or (piece != null and piece_color(piece) != col):
			moves.append_array(generate_pawn_move_list(square_index, new_square))
	if file < 8:
		var new_square = square_index + delta + 1
		var piece = pieces[new_square]
		if new_square == ep_target or (piece != null and piece_color(piece) != col):
			moves.append_array(generate_pawn_move_list(square_index, new_square))
	return moves
