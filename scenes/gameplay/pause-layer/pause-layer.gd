extends CanvasLayer

onready var pause := $Pause
onready var pause_button := $PauseButton
onready var resume_option := $Pause/VBoxOptions/Resume
onready var label := $PressESCToOpenMenu

func _ready():
	if OS.has_touchscreen_ui_hint():
		label.visible = false
	else:
		# to hide the pause_button on desktop: un-comment the next line
		# pause_button.hide()
		pass


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_game()
		get_tree().set_input_as_handled()


func resume():
	get_tree().paused = false
	pause.hide()


func pause_game():
	resume_option.grab_focus()
	get_tree().paused = true
	pause.show()


func _on_Resume_pressed():
	resume()


func _on_Main_Menu_pressed():
	Game.change_scene("res://scenes/menu/menu.tscn", {
		'show_progress_bar': false
	})


func _on_PauseButton_pressed():
	pause_game()
