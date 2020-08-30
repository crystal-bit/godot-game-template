extends CanvasLayer

onready var pause_screen = $Pause


func _unhandled_key_input(event):
	if event.scancode == KEY_ESCAPE and event.pressed:
		if get_tree().paused:
			resume()
		else:
			pause_game()


func resume():
	get_tree().paused = false
	pause_screen.hide()


func pause_game():
	get_tree().paused = true
	pause_screen.show()


func _on_Resume_pressed():
	resume()


func _on_Main_Menu_pressed():
	Game.change_scene("res://scenes/menu/menu.tscn")
	# if, by accident, you try to load the main scene (the container
	# for this template) it prevents to load it because
	# it's in the Game.scenes_denylist
	# Game.change_scene("res://scenes/main.tscn")


func _on_Quit_pressed():
	get_tree().quit()
