extends Button


func _ready():
	# needed for gamepads to work
	grab_focus()


func _on_Button_pressed():
	var params = {
		show_progress_bar = false,
		"a_number": 10,
		"a_string": "Ciao mamma!",
		"an_array": [1, 2, 3, 4],
		"a_dict": {
			"name": "test",
			"val": 15
		},
	}
	Game.change_scene("res://scenes/gameplay/gameplay.tscn", params)
