extends Node


const SETTINGS_FILENAME := "user://settings.txt"

var show_dests := true
var show_highlights := true
var sounds := true
var sound_check := true


func _ready() -> void:
	load_settings()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (not ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
		save_settings()

func load_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILENAME, FileAccess.READ)
	if (file == null):
		return;

	var d = str_to_var(file.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return

	if "show_dests" in d:
		show_dests = bool(d.show_dests)
	if "show_highlights" in d:
		show_highlights = bool(d.show_highlights)
	if "sounds" in d:
		sounds = bool(d.sounds)
	if "sound_check" in d:
		sound_check = bool(d.sound_check)


func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILENAME, FileAccess.WRITE)

	var d := {
		"show_dests": show_dests,
		"show_highlights": show_highlights,
		"sounds": sounds,
		"sound_check": sound_check,
	}

	file.store_line(var_to_str(d))
