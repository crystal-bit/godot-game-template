extends CanvasLayer

@onready var pause := self
@onready var pause_button := $MarginContainer/Control/PauseButton
@onready var resume_option := $MarginContainer/Control/VBoxOptions/Resume
@onready var label = $MarginContainer/Control/Label
@onready var pause_options = $MarginContainer/Control/VBoxOptions
@onready var color_rect = $ColorRect

@onready var nodes_grp1 = [pause_button, label] # should be visible during gamemplay and hidden during pause
@onready var nodes_grp2 = [pause_options, color_rect] # should be visible only in pause menu


func _ready():
	pause_hide()


func pause_show():
	for n in nodes_grp1:
		print("hiding ", n.name)
		n.hide()
	for n in nodes_grp2:
		n.show()


func pause_hide():
	for n in nodes_grp1:
		if n:
			print("showing ", n.name)
			n.show()

	for n in nodes_grp2:
		if n:
			print("hiding ", n.name)
			n.hide()


# when the node is removed from the tree (mostly because of a scene change)
func _exit_tree() -> void:
	# disable pause
#	get_tree().paused = false
	pass


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_game()
		get_viewport().set_input_as_handled()


func resume():
	get_tree().paused = false
	pause_hide()


func pause_game():
	resume_option.grab_focus()
	get_tree().paused = true
	pause_show()


func _on_Resume_pressed():
	resume()


func _on_PauseButton_pressed():
	pause_game()


func _on_main_menu_pressed():
	Game.change_scene_to_file("res://scenes/menu/menu.tscn", {"show_progress_bar": false})
