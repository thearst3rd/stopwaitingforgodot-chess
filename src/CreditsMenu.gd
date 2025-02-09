extends ColorRect


@onready var version_text := $M/Panel/M/ScrollContainer/V/GameTitle/Version as Label
@onready var repo_link := $M/Panel/M/ScrollContainer/V/RepoLinkCenterer/RepoLink as LinkButton


func _ready() -> void:
	version_text.text = "v%s" % ProjectSettings.get_setting("global/Version")


func _on_BackButton_pressed() -> void:
	hide()


func _on_RepoLink_pressed() -> void:
	var error := OS.shell_open(repo_link.text)
	assert(not error)
