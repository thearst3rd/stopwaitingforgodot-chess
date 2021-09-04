extends CenterContainer


var chess = Chess.new()
onready var board = $V/C/V/Board

var legal_moves = null


func update():
	board.setup_board(chess)
	$V/Fen.text = chess.get_fen()
	legal_moves = chess.generate_pseudo_legal_moves()
	$V/C/V/H/UndoButton.disabled = chess.move_stack.size() == 0


## CALLBACKS ##

func _ready():
	get_tree().call_group("Squares", "connect", "piece_dropped", self, "_on_Square_piece_dropped")
	update()


## SIGNALS ##

func _on_ResetButton_pressed():
	chess = Chess.new()
	update()

func _on_FlipButton_pressed():
	board.flip_board()

func _on_Square_piece_dropped(from_index, to_index):
	var m = chess.construct_move(from_index, to_index)
	for lm in legal_moves:
		if m.from_square == lm.from_square and m.to_square == lm.to_square and m.promotion == lm.promotion:
			chess.play_move(m)
			break
	update()

func _on_UndoButton_pressed():
	chess.undo()
	update()
