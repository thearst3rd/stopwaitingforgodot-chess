extends ColorRect


## CALLBACKS ##

func _ready():
	find_node("Version").text = "v%s" % ProjectSettings.get_setting("global/Version")


## SIGNALS ##

func _on_BackButton_pressed():
	hide()

func _on_RepoLink_pressed():
	assert(not OS.shell_open(find_node("RepoLink").text))
