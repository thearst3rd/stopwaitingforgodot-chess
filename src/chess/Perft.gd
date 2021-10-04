#!/usr/bin/env -S godot -s
extends SceneTree
class_name Perft

# Performance testing my chess move validation

var time_started : int

func perft_iter(position : Chess, depth : int) -> int:
	if depth <= 0:
		return 1

	var nodes_counted = 0
	var moves := position.generate_legal_moves(false)
	for move in moves:
		position.play_move(move)
		nodes_counted += perft_iter(position, depth - 1)
		position.undo()
	return nodes_counted

func perft_run(depth := 3, fen : String = Chess.INITIAL_FEN, divide := false):
	if depth < 1:
		depth = 1
	print("Running perft at depth %d" % depth)
	var nodes_counted := 0

	var position := Chess.new()
	var success = position.set_fen(fen)
	assert(success)

	time_started = OS.get_ticks_msec()
	var moves_notated = position.generate_legal_moves()
	for move in moves_notated:
		position.play_move(move)
		var iter_counted = perft_iter(position, depth - 1)
		if divide:
			print("%s: %d" % [move.notation_san, iter_counted])
		nodes_counted += iter_counted
		position.undo()
	var time_ended = OS.get_ticks_msec()

	if divide:
		print()
	print("Total count: %d" % nodes_counted)
	print("Time taken: %dms" % [time_ended - time_started])
	print()

func _init():
	var test_fen := "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8"
	var divide := false
	perft_run(1, test_fen, divide)
	perft_run(2, test_fen, divide)
	perft_run(3, test_fen, divide)
	perft_run(4, test_fen, divide)
	quit()
