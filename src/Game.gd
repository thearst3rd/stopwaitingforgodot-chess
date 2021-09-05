extends CenterContainer


var chess = Chess.new()
onready var board = $V/C/V/Board
onready var title_text = $V/Title.text

var legal_moves = null


func update():
	board.setup_board(chess)
	$V/H/FenText.text = chess.get_fen()
	legal_moves = chess.generate_legal_moves()
	$V/C/V/H/UndoButton.disabled = chess.move_stack.size() == 0

	var last_move = null
	if chess.move_stack.size() > 0:
		last_move = chess.move_stack[-1]

	var result = chess.get_result()
	var game_over = result != Chess.RESULT.ONGOING

	var result_text = title_text
	match result:
		Chess.RESULT.ONGOING:
			pass
		Chess.RESULT.CHECKMATE:
			result_text = "%s wins by checkmate!" % ("White" if chess.turn else "Black")
		Chess.RESULT.STALEMATE:
			result_text = "Draw by stalemate"
		Chess.RESULT.INSUFFICIENT:
			result_text = "Draw by insufficient material"
		Chess.RESULT.FIFTY_MOVE:
			result_text = "Draw by fifty-move rule"
		Chess.RESULT.THREEFOLD:
			result_text = "Draw by threefold repetition"

	$V/Title.text = result_text

	for square in get_tree().get_nodes_in_group("Squares"):
		var piece = chess.pieces[square.index]
		if piece:
			square.grabbable = not game_over and Chess.piece_color(piece) == chess.turn
		var highlight = square.get_node("LastMoveHighlight")
		highlight.hide()
		if last_move and (square.index == last_move.from_square or square.index == last_move.to_square):
			highlight.show()


## CALLBACKS ##

func _ready():
	get_tree().call_group("Squares", "connect", "piece_grabbed", self, "_on_Square_piece_grabbed")
	get_tree().call_group("Squares", "connect", "piece_dropped", self, "_on_Square_piece_dropped")
	update()


## SIGNALS ##

func _on_ResetButton_pressed():
	chess.reset()
	update()

func _on_FlipButton_pressed():
	board.flip_board()

func _on_UndoButton_pressed():
	chess.undo()
	update()

func _on_SetFen_pressed():
	if chess.set_fen($V/H/FenText.text):
		update()
	else:
		$V/H/InvalidFen.show()
		$V/H/InvalidFenTimer.start()

func _on_Square_piece_grabbed(from_index):
	var target_squares = []
	for move in legal_moves:
		if move.from_square == from_index:
			target_squares.push_back(move.to_square)
	for square in get_tree().get_nodes_in_group("Squares"):
		if square.index in target_squares:
			var indicator = square.get_node("LegalMoveIndicator/ColorRect")
			if chess.pieces[square.index] == null:
				indicator.rect_min_size = Vector2(15, 15)
			else:
				indicator.rect_min_size = Vector2(40, 40)
			indicator.get_parent().show()

func _on_Square_piece_dropped(from_index, to_index):
	var m = chess.construct_move(from_index, to_index)
	for lm in legal_moves:
		if m.from_square == lm.from_square and m.to_square == lm.to_square and m.promotion == lm.promotion:
			chess.play_move(m)
			break
	update()

func _on_InvalidFenTimer_timeout():
	$V/H/InvalidFen.hide()
