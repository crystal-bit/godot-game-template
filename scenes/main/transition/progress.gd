extends Control


onready var bar := $ProgressBar
onready var tween := $ProgressBar/Tween


func is_completed():
	return bar.value == bar.max_value
