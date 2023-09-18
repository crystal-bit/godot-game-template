extends Control

@onready var bar := $ProgressBar


func is_completed():
	return bar.value == bar.max_value
