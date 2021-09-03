extends GridContainer


export (Color) var light_square_color = Color(234.0/255.0, 223.0/255.0, 237.0/255.0)
export (Color) var dark_square_color = Color(167.0/255.0, 129.0/255.0, 177.0/255.0)

const Square = preload("Square.tscn")


func setup_board():
	for square in get_children():
		# Hard code piece graphics for now
		var col = "w" if square.rank < 5 else "b"
		var piece = null

		if square.rank == 2 or square.rank == 7:
			piece = "P"
		if square.rank == 1 or square.rank == 8:
			match square.file:
				1, 8: piece = "R"
				2, 7: piece = "N"
				3, 6: piece = "B"
				4:    piece = "Q"
				5:    piece = "K"

		if piece != null:
			square.get_node("Piece").texture = load("res://assets/tatiana/" + col + piece + ".svg")
		else:
			square.get_node("Piece").texture = null

func flip_board():
	var squares_flipped = []
	for square in get_children():
		squares_flipped.insert(0, square)
		remove_child(square)

	for square in squares_flipped:
		add_child(square)


## CALLBACKS ##

func _ready():
	for rank in range(8, 0, -1):
		for file in range(1, 9):
			var square = Square.instance()
			var is_dark = (rank + file) % 2 == 0
			square.color = dark_square_color if is_dark else light_square_color
			add_child(square)

			square.file = file
			square.rank = rank
			square.square_name = char(ord("a") - 1 + file) + str(rank)

			setup_board()


## SIGNALS ##

func _on_ResetButton_pressed():
	setup_board()

func _on_FlipButton_pressed():
	flip_board()
