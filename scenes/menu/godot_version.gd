extends Label


func _ready():
	if OS.has_feature('release'):
		queue_free()
	else:
		text = "Godot %s" % Engine.get_version_info().string
