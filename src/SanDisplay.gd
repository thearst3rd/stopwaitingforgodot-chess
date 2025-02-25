extends ColorRect


@onready var scroll_container := $ScrollContainer as ScrollContainer
@onready var scroll_bar := scroll_container.get_v_scroll_bar()
@onready var sans := $ScrollContainer/Sans as GridContainer


func create_number_label(num: int) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = Color(1, 1, 1, 0.13)
	rect.custom_minimum_size = Vector2(50, 30)
	var label := Label.new()
	label.text = str(num) + ". "
	label.align = HORIZONTAL_ALIGNMENT_RIGHT
	label.valign = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = rect.custom_minimum_size
	rect.add_child(label)
	return rect


func create_san_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(100, 0)
	return label


func update_moves(chess: Chess) -> void:
	for child in sans.get_children():
		sans.remove_child(child)

	var moves := []
	while chess.move_stack.size() > 0:
		moves.push_front(chess.move_stack[-1])
		chess.undo()

	if chess.turn:
		sans.add_child(create_number_label(chess.fullmove_counter))
		sans.add_child(create_san_label("..."))

	for move in moves:
		if not chess.turn:
			sans.add_child(create_number_label(chess.fullmove_counter))
		var label := create_san_label(move.notation_san)
		sans.add_child(label)
		chess.play_move(move)

	# Thanks to https://godotengine.org/qa/4106/how-to-change-scrollbarcontainers-scrollbar-position
	await scroll_bar.changed
	@warning_ignore("narrowing_conversion")
	scroll_container.set_v_scroll(scroll_bar.max_value)
