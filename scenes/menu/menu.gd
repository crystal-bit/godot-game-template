extends Control

@export var play_button: Button
@export var exit_button: Button
@export var settings_menu: Control
@export var margin_container: MarginContainer


func _ready():
	# needed for gamepads to work
	play_button.grab_focus()
	if OS.has_feature('web'):
		exit_button.queue_free() # exit button dosn't make sense on HTML5


func _on_PlayButton_pressed() -> void:
	var params = {
		"show_progress_bar": true,
		"a_number": 10,
		"a_string": "Ciao!",
		"an_array": [1, 2, 3, 4],
		"a_dict": {
			"name": "test",
			"val": 15
		},
	}
	GGT.change_scene("res://scenes/gameplay/gameplay.tscn", params)


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions = get_node_or_null("/root/GGT_Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	settings_menu.show()


func _on_settings_menu_visibility_changed() -> void:
	margin_container.visible = !settings_menu.visible


func _on_settings_menu_confirm_button_clicked() -> void:
	settings_menu.hide()
