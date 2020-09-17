class_name Transitions
extends CanvasLayer

onready var anim := $AnimationPlayer


func playing() -> bool:
	return anim.is_playing() or $ColorRect.color.a != 0


func set_black():
	anim.play("black")


func fade_in():
	anim.play("fade-to-black")


func fade_out():
	anim.play("fade-from-black")
