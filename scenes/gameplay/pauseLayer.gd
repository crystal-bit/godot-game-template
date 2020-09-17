extends CanvasLayer

onready var pause_screen := $Pause
onready var resume_option := $Pause/VBoxOptions/Resume


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_game()
		get_tree().set_input_as_handled()


func resume():
	get_tree().paused = false
	pause_screen.hide()


func pause_game():
	resume_option.grab_focus()
	get_tree().paused = true
	pause_screen.show()


func _on_Resume_pressed():
	resume()


func _on_Main_Menu_pressed():
	""" Note: this should be connected as one-shot to avoid bugs on
	multiple click during animations.
	For other parts of the game the pause state takes care of this."""
	Game.change_scene("res://scenes/menu/menu.tscn")
	# if, by accident, you try to load the main scene (the container
	# for this template) it prevents to load it because
	# it's in the Game.scenes_denylist
	# Game.change_scene("res://scenes/main.tscn")
