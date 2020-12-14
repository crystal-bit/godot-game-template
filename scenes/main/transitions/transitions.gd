class_name Transitions
extends CanvasLayer


onready var anim := $AnimationPlayer


func playing() -> bool:
	var is_screen_black = $ColorRect.color.a == 1
	return anim.is_playing() or is_screen_black


func set_black():
	anim.play("black")


func fade_in():
	anim.play("fade-to-black")


func fade_out():
	anim.play("fade-from-black")
