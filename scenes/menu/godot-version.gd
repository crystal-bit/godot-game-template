extends Label

func _ready():
	text = "Godot %s" % Engine.get_version_info().string
