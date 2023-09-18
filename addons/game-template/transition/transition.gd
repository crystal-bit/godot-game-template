# Transitions.
# You can tweak transition speed and appearance, just make sure to
# update `is_displayed`.
class_name Transition
extends CanvasLayer

signal progress_bar_filled
signal transition_started(anim_name)
signal transition_finished(anim_name)

var target_progress = 0
var loading = false

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var progress = $ColorRect/Progress


# Tells if transition is currently displayed
func is_displayed() -> bool:
	var is_screen_black = $ColorRect.modulate.a == 1
	return anim.is_playing() or is_screen_black


func is_transition_in_playing():
	return anim.current_animation == "transition-in" and anim.is_playing()


# appear
func fade_in(params = {}):
	progress.hide()
	if params and params.get("show_progress_bar") != null:
		if params.get("show_progress_bar") == true:
			progress.show()
	anim.play("transition-in")


# disappear
func fade_out():
	if progress.visible and not progress.is_completed():
		await self.progress_bar_filled
	anim.connect(
		"animation_finished", Callable(self, "_on_fade_out_finished").bind(), CONNECT_ONE_SHOT
	)
	anim.play("transition-out")


func _on_fade_out_finished(cur_anim):
	if cur_anim == "transition-out":
		progress.bar.value = 0


# progress_ratio: value between 0 and 1
func _update_progress_bar(progress_ratio: float):
	loading = true
	if is_nan(progress_ratio):
		target_progress = 1.0
		return
	target_progress = progress_ratio


func _process(_delta):
	if loading:
		progress.bar.value += 0.01 * sign(target_progress - progress.bar.value)
		if progress.bar.value > 0.99 and target_progress == 1.0:
			loading = false
			emit_signal("progress_bar_filled")


# called by the scene loader
func _on_resource_stage_loaded(progress_percentage: float):
	if progress.visible:
		_update_progress_bar(progress_percentage)
	else:
		pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "transition-out":
		emit_signal("transition_finished", anim_name)


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "transition-in":
		emit_signal("transition_started", anim_name)
