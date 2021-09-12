extends Reference
class_name ChessEngine

# The class that handles the actual chess AI

const MATE_SCORE = 1_000_000_000
const MATE_THRESHOLD = 999_000_000

const INF_SCORE = 0xFFFF_FFFF_FFFF

var search_depth = 3


# Simplified Evaluation Function piece tables
var w_pawn_table = [
	 0,  0,  0,  0,  0,  0,  0,  0,
	50, 50, 50, 50, 50, 50, 50, 50,
	10, 10, 20, 30, 30, 20, 10, 10,
	 5,  5, 10, 25, 25, 10,  5,  5,
	 0,  0,  0, 20, 20,  0,  0,  0,
	 5, -5,-10,  0,  0,-10, -5,  5,
	 5, 10, 10,-20,-20, 10, 10,  5,
	 0,  0,  0,  0,  0,  0,  0,  0,
]
var w_knight_table = [
	-50,-40,-30,-30,-30,-30,-40,-50,
	-40,-20,  0,  0,  0,  0,-20,-40,
	-30,  0, 10, 15, 15, 10,  0,-30,
	-30,  5, 15, 20, 20, 15,  5,-30,
	-30,  0, 15, 20, 20, 15,  0,-30,
	-30,  5, 10, 15, 15, 10,  5,-30,
	-40,-20,  0,  5,  5,  0,-20,-40,
	-50,-40,-30,-30,-30,-30,-40,-50,
]
var w_bishop_table = [
	-20,-10,-10,-10,-10,-10,-10,-20,
	-10,  0,  0,  0,  0,  0,  0,-10,
	-10,  0,  5, 10, 10,  5,  0,-10,
	-10,  5,  5, 10, 10,  5,  5,-10,
	-10,  0, 10, 10, 10, 10,  0,-10,
	-10, 10, 10, 10, 10, 10, 10,-10,
	-10,  5,  0,  0,  0,  0,  5,-10,
	-20,-10,-10,-10,-10,-10,-10,-20,
]
var w_rook_table = [
	 0,  0,  0,  0,  0,  0,  0,  0,
	 5, 10, 10, 10, 10, 10, 10,  5,
	-5,  0,  0,  0,  0,  0,  0, -5,
	-5,  0,  0,  0,  0,  0,  0, -5,
	-5,  0,  0,  0,  0,  0,  0, -5,
	-5,  0,  0,  0,  0,  0,  0, -5,
	-5,  0,  0,  0,  0,  0,  0, -5,
	 0,  0,  0,  5,  5,  0,  0,  0,
]
var w_queen_table = [
	-20,-10,-10, -5, -5,-10,-10,-20,
	-10,  0,  0,  0,  0,  0,  0,-10,
	-10,  0,  5,  5,  5,  5,  0,-10,
	 -5,  0,  5,  5,  5,  5,  0, -5,
	  0,  0,  5,  5,  5,  5,  0, -5,
	-10,  5,  5,  5,  5,  5,  0,-10,
	-10,  0,  5,  0,  0,  0,  0,-10,
	-20,-10,-10, -5, -5,-10,-10,-20,
]
var w_king_middle_table = [
	-30,-40,-40,-50,-50,-40,-40,-30,
	-30,-40,-40,-50,-50,-40,-40,-30,
	-30,-40,-40,-50,-50,-40,-40,-30,
	-30,-40,-40,-50,-50,-40,-40,-30,
	-20,-30,-30,-40,-40,-30,-30,-20,
	-10,-20,-20,-20,-20,-20,-20,-10,
	 20, 20,  0,  0,  0,  0, 20, 20,
	 20, 30, 10,  0,  0, 10, 30, 20,
]
var w_king_end_table = [
	-50,-40,-30,-20,-20,-30,-40,-50,
	-30,-20,-10,  0,  0,-10,-20,-30,
	-30,-10, 20, 30, 30, 20,-10,-30,
	-30,-10, 30, 40, 40, 30,-10,-30,
	-30,-10, 30, 40, 40, 30,-10,-30,
	-30,-10, 20, 30, 30, 20,-10,-30,
	-30,-30,  0,  0,  0,  0,-30,-30,
	-50,-30,-30,-30,-30,-30,-30,-50,
]
var b_pawn_table = flip_table(w_pawn_table)
var b_knight_table = flip_table(w_knight_table)
var b_bishop_table = flip_table(w_bishop_table)
var b_rook_table = flip_table(w_rook_table)
var b_queen_table = flip_table(w_queen_table)
var b_king_middle_table = flip_table(w_king_middle_table)
var b_king_end_table = flip_table(w_king_end_table)


static func flip_table(table):
	var new_table = []
	new_table.resize(64)
	for i in range(64):
		var file = Chess.square_get_file(i)
		var rank = 9 - Chess.square_get_rank(i)
		var new_i = Chess.square_index(file, rank)
		new_table[new_i] = table[i]
	return new_table


func get_move(chess : Chess):
	return negamax(chess, search_depth, -INF_SCORE, INF_SCORE)

static func get_piece_value(piece) -> int:
	match piece:
		null, "K", "k":
			pass
		"Q", "q":
			return 900
		"R", "r":
			return 500
		"B", "b":
			return 330
		"N", "n":
			return 320
		"P", "p":
			return 100
	return 0;

func get_piece_placement(piece, square) -> int:
	match piece:
		null: pass
		"K": return w_king_middle_table[square]
		"k": return b_king_middle_table[square]
		"Q": return w_queen_table[square]
		"q": return b_queen_table[square]
		"R": return w_rook_table[square]
		"r": return b_rook_table[square]
		"B": return w_bishop_table[square]
		"b": return b_bishop_table[square]
		"N": return w_knight_table[square]
		"n": return b_knight_table[square]
		"P": return w_pawn_table[square]
		"p": return b_pawn_table[square]
	return 0

# Evaluates a position from the POV of whose turn it is
# Largely based on https://www.chessprogramming.org/Simplified_Evaluation_Function
func evaluate(chess : Chess) -> int:
	var eval = 0
	for i in range(64):
		var piece = chess.pieces[i]
		if piece == null:
			continue
		var mult = 1 if (Chess.piece_color(piece) == chess.turn) else -1
		eval += mult * (get_piece_value(piece) + get_piece_placement(piece, i))
	return eval

func negamax(chess : Chess, depth, alpha, beta):
	if depth <= 0:
		if chess.in_check():
			var moves = chess.generate_legal_moves()
			if moves.size() == 0:
				return [-MATE_SCORE, null]
		return [evaluate(chess), null]
	var moves = chess.generate_legal_moves()
	var best_score = -INF_SCORE
	var best_move = null
	if moves.size() == 0:
		best_score = -MATE_SCORE if chess.in_check() else 0
	for move in moves:
		chess.play_move(move)
		var curr_score = -negamax(chess, depth - 1, -beta, -alpha)[0]
		if curr_score > MATE_THRESHOLD:
			curr_score -= 1
		elif curr_score < -MATE_THRESHOLD:
			curr_score += 1
		chess.undo()
		if curr_score > best_score:
			best_score = curr_score
			best_move = move
			alpha = max(alpha, best_score)
			if alpha >= beta:
				break
	return [best_score, best_move]
