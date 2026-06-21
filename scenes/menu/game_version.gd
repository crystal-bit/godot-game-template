extends Label


func _ready():
	# you need to enable "Advanced Settings" to make this property visible
	var ver = ProjectSettings.get_setting("application/config/version")
	var mode = "debug" if OS.is_debug_build() else "release"
	text =  "%s (%s)" % [ver, mode]
