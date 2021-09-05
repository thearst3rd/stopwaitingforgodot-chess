extends WindowDialog

signal settings_changed


onready var show_dests = find_node("ShowDestsCheck")
onready var show_highlights = find_node("ShowHighlightsCheck")
onready var sounds = find_node("SoundsCheck")
onready var sound_check = find_node("SoundCheckCheck")


## CALLBACKS ##

func _ready():
	show_dests.pressed = Settings.show_dests
	show_highlights.pressed = Settings.show_highlights
	sounds.pressed = Settings.sounds
	sound_check.pressed = Settings.sound_check
	sound_check.disabled = not Settings.sounds


## SIGNALS ##

func _on_ShowDestsCheck_toggled(button_pressed):
	Settings.show_dests = button_pressed

func _on_ShowHighlightsCheck_toggled(button_pressed):
	Settings.show_highlights = button_pressed
	emit_signal("settings_changed")

func _on_SoundsCheck_toggled(button_pressed):
	Settings.sounds = button_pressed
	sound_check.disabled = not Settings.sounds

func _on_SoundCheckCheck_toggled(button_pressed):
	Settings.sound_check = button_pressed
