extends Button


func _ready() -> void:
	if OS.has_feature('HTML5'):
		queue_free()


func _on_ExitButton_pressed():
	# gently shutdown the game
	Transitions.fade_in({
		'show_progress_bar': false
	})
	yield(Transitions.anim, "animation_finished")
	yield(get_tree().create_timer(0.3), "timeout")
	get_tree().quit()
