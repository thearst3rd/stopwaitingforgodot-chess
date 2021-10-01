extends Control


var chess = Chess.new()
var engine = ChessEngine.new()
onready var board = find_node("Board")
onready var title_text = find_node("Title").text
onready var bot_timer = find_node("BotTimer")
onready var bot_check = find_node("BotCheck")

onready var reset_button = find_node("ResetButton")
onready var undo_button = find_node("UndoButton")
onready var bot_button = find_node("BotButton")

var legal_moves = null
var bot_thinking = false
var bot_thinking_thread : Thread = null


func update_state(after_move = false):
	board.setup_board(chess)
	find_node("FenText").text = chess.get_fen()
	legal_moves = chess.generate_legal_moves()
	find_node("UndoButton").disabled = chess.move_stack.size() == 0

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
			result_text = "Draw by fifty move rule"
		Chess.RESULT.SEVENTY_FIVE_MOVE:
			result_text = "Draw by seventy-five move rule"
		Chess.RESULT.THREEFOLD:
			result_text = "Draw by threefold repetition"
		Chess.RESULT.FIVEFOLD:
			result_text = "Draw by fivefold repetition"

	find_node("Title").text = result_text

	for square in get_tree().get_nodes_in_group("Squares"):
		var piece = chess.pieces[square.index]
		if piece:
			square.grabbable = (not game_over and not bot_thinking) and Chess.piece_color(piece) == chess.turn

		var highlight = square.get_node("LastMoveHighlight")
		var checkIndicator = square.get_node("CheckIndicator")
		highlight.hide()
		checkIndicator.hide()
		if Settings.show_highlights:
			if last_move and (square.index == last_move.from_square or square.index == last_move.to_square):
				highlight.show()
			if piece in ["K", "k"] and chess.is_square_attacked(square.index, not Chess.piece_color(piece)):
				checkIndicator.show()

	find_node("SanDisplay").update_moves(chess)

	bot_button.disabled = game_over or bot_thinking

	reset_button.disabled = bot_thinking
	undo_button.disabled = bot_thinking

	if after_move and last_move:
		if Settings.sounds and not (bot_check.pressed and OS.get_name() == "HTML5"):
			if last_move.en_passant or last_move.captured_piece:
				find_node("CaptureSound").play()
			else:
				find_node("MoveSound").play()

			if result != Chess.RESULT.ONGOING:
				find_node("TerminalSound").play()
			elif Settings.sound_check:
				if last_move.notation_san[-1] == "+":
					find_node("CheckSound").play()

func bot_play(with_timeout = false):
	if chess.is_game_over():
		return
	bot_thinking = true
	update_state()
	if with_timeout:
		bot_timer.start()
	else:
		if OS.get_name() == "HTML5":
			# TODO: Remove this when itch.io supports CORS
			bot_think()
		else:
			bot_thinking_thread = Thread.new()
			var error = bot_thinking_thread.start(self, "bot_think")
			assert(not error)

func bot_think():
	var result = engine.get_move(chess)
	call_deferred("bot_finalize", result)

func bot_finalize(result):
	if OS.get_name() != "HTML5":
		bot_thinking_thread.wait_to_finish()
		bot_thinking_thread = null
	print("%s  score: %d  searched: %d %d  eval: %d  time: %dms" % [result[1].notation_san, result[0],
			engine.num_positions_searched, engine.num_positions_searched_q, engine.num_positions_evaluated,
			engine.search_time / 1000.0])
	chess.play_move(result[1])
	bot_thinking = false
	bot_timer.stop()
	update_state(true)


## CALLBACKS ##

func _ready():
	randomize()
	get_tree().call_group("Squares", "connect", "piece_grabbed", self, "_on_Square_piece_grabbed")
	get_tree().call_group("Squares", "connect", "piece_dropped", self, "_on_Square_piece_dropped")
	update_state()

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if bot_thinking_thread != null:
		bot_thinking_thread.wait_to_finish()


## SIGNALS ##

func _on_ResetButton_pressed():
	bot_thinking = false
	bot_timer.stop()
	chess.reset()
	update_state()
	if bot_check.pressed and board.get_child(0).index == 63:
		# Board is flipped, play move
		bot_play(true)

func _on_FlipButton_pressed():
	board.flip_board()

func _on_UndoButton_pressed():
	bot_thinking = false
	bot_timer.stop()
	chess.undo()
	update_state()

func _on_SetFen_pressed():
	bot_thinking = false
	bot_timer.stop()
	if chess.set_fen(find_node("FenText").text):
		update_state()
	else:
		find_node("InvalidFen").show()
		find_node("InvalidFenTimer").start()

func _on_Square_piece_grabbed(from_index):
	if Settings.show_dests:
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
			chess.play_move(lm)
			update_state(true)
			if bot_check.pressed:
				bot_play(true)
			break

func _on_InvalidFenTimer_timeout():
	find_node("InvalidFen").hide()

func _on_SettingsButton_pressed():
	find_node("SettingsMenu").popup_centered()

func _on_SettingsMenu_settings_changed():
	if board:	# Workaround for crash on startup... Probably can check for some kind of is_ready instead
		update_state()

func _on_CreditsButton_pressed():
	find_node("CreditsMenu").show()

func _on_BotButton_pressed():
	bot_play()

func _on_BotCheck_pressed():
	# Nothing to do?
	pass

func _on_BotTimer_timeout():
	bot_play()
