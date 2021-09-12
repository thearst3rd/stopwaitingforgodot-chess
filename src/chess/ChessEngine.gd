extends Reference
class_name ChessEngine

const MATE_SCORE = 1_000_000_000
const MATE_THRESHOLD = 999_000_000

const INF_SCORE = 0xFFFF_FFFF_FFFF

var search_depth = 3

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
			return 300
		"N", "n":
			return 300
		"P", "p":
			return 100
	return 0;


# Evaluates a position from the POV of whose turn it is
static func evaluate(chess : Chess) -> int:
	var material_count = 0
	# Simple, just count pieces
	for i in range(64):
		var piece = chess.pieces[i]
		if piece == null:
			continue
		var mult = 1 if (Chess.piece_color(piece) == chess.turn) else -1
		material_count += mult * get_piece_value(piece)

	return material_count

static func negamax(chess : Chess, depth, alpha, beta):
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
