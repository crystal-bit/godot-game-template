extends Button


func _ready() -> void:
	if OS.has_feature('HTML5'):
		queue_free()


func _on_ExitButton_pressed():
	# gently shutdown the game
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		yield(transitions.anim, "animation_finished")
		yield(get_tree().create_timer(0.3), "timeout")
	get_tree().quit()
