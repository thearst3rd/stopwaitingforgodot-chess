extends Reference
class_name Chess

# This class contains all the code for a chess position, including legal move generation, game end conditions, etc

const INITIAL_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"


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
