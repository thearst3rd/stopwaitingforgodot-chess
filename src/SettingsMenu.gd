extends ColorRect

signal settings_changed


onready var show_dests = find_node("ShowDestsCheck")
onready var show_highlights = find_node("ShowHighlightsCheck")


## CALLBACKS ##

func _ready():
	show_dests.pressed = Settings.show_dests
	show_highlights.pressed = Settings.show_highlights


## SIGNALS ##

func _on_BackButton_pressed():
	hide()

func _on_ShowDestsCheck_toggled(button_pressed):
	Settings.show_dests = button_pressed
	emit_signal("settings_changed")

func _on_ShowHighlightsCheck_toggled(button_pressed):
	Settings.show_highlights = button_pressed
	emit_signal("settings_changed")
