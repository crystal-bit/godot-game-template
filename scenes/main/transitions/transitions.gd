# Transitions fade-in and fade-out.
# You can tweak transition speed and appearance.
# Just make sure to update the `is_playing` method.
class_name Transition
extends CanvasLayer


onready var anim := $AnimationPlayer


func is_playing() -> bool:
	var is_screen_black = $ColorRect.color.a == 1
	return anim.is_playing() or is_screen_black


func set_black():
	anim.play("black")


func fade_in():
	anim.play("fade-to-black")


func fade_out():
	anim.play("fade-from-black")
