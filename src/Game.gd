extends CenterContainer


var chess = Chess.new()
onready var board = $V/C/V/Board


func update():
	board.setup_board(chess)
	$V/Fen.text = chess.get_fen()


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
	chess.pieces[to_index] = chess.pieces[from_index]
	chess.pieces[from_index] = null
	update()
