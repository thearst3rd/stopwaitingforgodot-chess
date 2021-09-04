extends CenterContainer


var chess = Chess.new()
onready var board = $V/C/V/Board


func update():
	board.setup_board(chess)
	$V/Fen.text = chess.get_fen()
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
	var move = chess.construct_move(from_index, to_index)
	chess.play_move(move)
	update()

func _on_UndoButton_pressed():
	chess.undo()
	update()
