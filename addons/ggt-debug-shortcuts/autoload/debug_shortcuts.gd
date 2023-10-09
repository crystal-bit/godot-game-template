extends Node


func _ready():
	if OS.is_debug_build() == false:
		queue_free()
