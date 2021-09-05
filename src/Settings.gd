extends Node


const SETTINGS_FILENAME = "user://settings.txt"

var show_dests = true
var show_highlights = true


func load_settings():
	var f = File.new()
	var error = f.open(SETTINGS_FILENAME, File.READ)
	if error:
		print("Error loading settings.json")
		return

	var d = str2var(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return

	if "show_dests" in d:
		show_dests = bool(d.show_dests)
	if "show_highlights" in d:
		show_highlights = bool(d.show_highlights)

func save_settings():
	var f = File.new()
	var error = f.open(SETTINGS_FILENAME, File.WRITE)
	assert(not error)

	var d = {
		"show_dests": show_dests,
		"show_highlights": show_highlights,
	}

	f.store_line(var2str(d))


## CALLBACKS ##

func _ready():
	load_settings()

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()

# Save on quitting
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_settings()
		get_tree().quit() # default behavior
