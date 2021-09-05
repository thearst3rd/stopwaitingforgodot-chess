extends ColorRect


onready var scroll_container = find_node("ScrollContainer")
onready var scroll_bar = scroll_container.get_v_scrollbar()
onready var sans = find_node("Sans")


func create_number_label(num):
	var rect = ColorRect.new()
	rect.color = Color(1, 1, 1, 0.13)
	rect.rect_min_size = Vector2(50, 30)
	var label = Label.new()
	label.text = str(num) + ". "
	label.align = Label.ALIGN_RIGHT
	label.valign = Label.VALIGN_CENTER
	label.rect_min_size = rect.rect_min_size
	rect.add_child(label)
	return rect

func create_san_label(text):
	var label = Label.new()
	label.text = text
	label.rect_min_size = Vector2(100, 0)
	return label

func update_moves(chess):
	for child in sans.get_children():
		sans.remove_child(child)

	var moves = []
	while chess.move_stack.size() > 0:
		moves.push_front(chess.move_stack[-1])
		chess.undo()

	if chess.turn:
		sans.add_child(create_number_label(chess.fullmove_counter))
		sans.add_child(create_san_label("..."))

	for move in moves:
		if not chess.turn:
			sans.add_child(create_number_label(chess.fullmove_counter))
		var label = create_san_label(move.notation_san)
		sans.add_child(label)
		chess.play_move(move)

	# Thanks to https://godotengine.org/qa/4106/how-to-change-scrollbarcontainers-scrollbar-position
	yield(scroll_bar, "changed")
	find_node("ScrollContainer").set_v_scroll(scroll_bar.max_value)
