extends GridContainer


export (Color) var light_square_color = Color(234.0/255.0, 223.0/255.0, 237.0/255.0)
export (Color) var dark_square_color = Color(167.0/255.0, 129.0/255.0, 177.0/255.0)

const Square = preload("Square.tscn")


func setup_board(chess : Chess):
	for square in get_children():
		var piece = chess.pieces[square.index]
		if piece != null:
			var col = "b" if (ord(piece) >= ord("a")) else "w"
			piece = piece.to_upper()
			square.get_node("Piece").texture = load("res://assets/tatiana/" + col + piece + ".svg")
		else:
			square.get_node("Piece").texture = null

func flip_board():
	var squares_flipped = []
	for square in get_children():
		squares_flipped.push_front(square)
		remove_child(square)

	for square in squares_flipped:
		add_child(square)


## CALLBACKS ##

func _ready():
	for rank in range(8, 0, -1):
		for file in range(1, 9):
			var square = Square.instance()

			square.file = file
			square.rank = rank
			square.index = Chess.square_index(file, rank)
			square.san_name = Chess.square_get_name(square.index)

			square.color = dark_square_color if Chess.square_is_dark(square.index) else light_square_color
			add_child(square)
