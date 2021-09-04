extends Node


const SETTINGS_FILENAME = "user://settings.txt"

var show_dests = true


func load_settings():
	var f = File.new()
	var error = f.open(SETTINGS_FILENAME, File.READ)
	if error:
		print("Error loading settings.json")
		return

	var d = str2var(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return

	if OS.get_name() != "HTML":
		if "fullscreen" in d:
			OS.window_fullscreen = bool(d.fullscreen)

	if "show_dests" in d:
		show_dests = bool(d.show_dests)

func save_settings():
	var f = File.new()
	var error = f.open(SETTINGS_FILENAME, File.WRITE)
	assert(not error)

	var d = {
		"fullscreen": OS.window_fullscreen,
		"show_dests": show_dests,
	}

	if OS.get_name() == "HTML5":
		d["fullscreen"] = false

	f.store_line(var2str(d))


## CALLBACKS ##

func _ready():
	load_settings()

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()
