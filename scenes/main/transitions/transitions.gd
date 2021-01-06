# Transitions fade-in and fade-out.
# You can tweak transition speed and appearance.
# Just make sure to update the `is_playing` method accordingly.
class_name Transition
extends CanvasLayer

signal progress_bar_filled()

onready var anim := $AnimationPlayer
onready var progress = $ColorRect/Progress


# is_displayed
func is_playing() -> bool:
	var is_screen_black = $ColorRect.modulate.a == 1
	return anim.is_playing() or is_screen_black


# cover immediately the screen, without transitions
func set_black():
	anim.play("black")


# appear
func fade_in(params = {}):
	progress.show()
	if params and params.get('show_progress_bar') != null:
		if params.get('show_progress_bar') == false:
			progress.hide()
	anim.play("fade-to-black")


# disappear
func fade_out():
	if progress.visible and not progress.is_completed():
		yield(self, "progress_bar_filled")
	anim.connect("animation_finished", self, "_on_fade_out_finished", [], CONNECT_ONESHOT)
	anim.play("fade-from-black")


func _on_fade_out_finished(cur_anim):
	if cur_anim == "fade-from-black":
		progress.bar.value = 0


# progress_ratio: value between 0 and 1
func _update_progress_bar(progress_ratio):
	var tween = progress.tween
	if tween.is_active():
		tween.stop_all() # stop previous animation
	tween.interpolate_property(
		progress.bar,
		"value",
		progress.bar.value,
		progress_ratio,
		1,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT,
		0
	)
	tween.start()
	if progress_ratio == 1:
		yield(tween, "tween_completed")
		emit_signal("progress_bar_filled")


# called by the scene loader
func _on_resource_stage_loaded(stage: int, stages_amount: int):
	if progress.visible:
		var percentage = float(stage) / float(stages_amount)
		_update_progress_bar(percentage)
	else:
		pass
