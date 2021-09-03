extends GridContainer


export (Color) var light_square_color = Color(234.0/255.0, 223.0/255.0, 237.0/255.0)
export (Color) var dark_square_color = Color(167.0/255.0, 129.0/255.0, 177.0/255.0)

const Square = preload("Square.tscn")


func _ready():
	for rank in range(8, 0, -1):
		for file in range(1, 9):
			var square = Square.instance()
			var is_dark = (rank + file) % 2 == 0
			square.color = dark_square_color if is_dark else light_square_color
			add_child(square)

			# Hard code piece graphics for now
			var col = "w" if rank < 5 else "b"
			var piece = null

			if rank == 2 or rank == 7:
				piece = "P"
			if rank == 1 or rank == 8:
				match file:
					1, 8: piece = "R"
					2, 7: piece = "N"
					3, 6: piece = "B"
					4:    piece = "Q"
					5:    piece = "K"

			if piece != null:
				square.get_node("Piece").texture = load("res://assets/tatiana/" + col + piece + ".svg")
