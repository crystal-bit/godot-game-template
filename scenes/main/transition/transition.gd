# Transitions.
# You can tweak transition speed and appearance, just make sure to
# update `is_displayed`.
class_name Transition
extends CanvasLayer

signal progress_bar_filled()

onready var anim: AnimationPlayer = $AnimationPlayer
onready var progress = $ColorRect/Progress


# Tells if transition is currently displayed
func is_displayed() -> bool:
	var is_screen_black = $ColorRect.modulate.a == 1
	return anim.is_playing() or is_screen_black


func is_transition_in_playing():
	return anim.is_playing() and anim.current_animation == 'transition-in'


# appear
func fade_in(params = {}):
	progress.hide()
	if params and params.get('show_progress_bar') != null:
		if params.get('show_progress_bar') == true:
			progress.show()
	anim.play("transition-in")


# disappear
func fade_out():
	if progress.visible and not progress.is_completed():
		yield(self, "progress_bar_filled")
	anim.connect("animation_finished", self, "_on_fade_out_finished", [], CONNECT_ONESHOT)
	anim.play("transition-out")


func _on_fade_out_finished(cur_anim):
	if cur_anim == "transition-out":
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
