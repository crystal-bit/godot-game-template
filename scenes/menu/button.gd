extends Button


func _on_Button_pressed():
	print("PREMUUUUTo")
	var params = {
		"a_number": 10,
		"a_string": "Ciao mamma!",
		"an_array": [1, 2, 3, 4],
		"a_dict": {
			"name": "test",
			"val": 15
		},
		"you_can_pass_also_node_duplicates_but_im_not_sure_its_really_a_good_idea": self.duplicate()
	}
	Game.change_scene("res://scenes/gameplay/gameplay.tscn", params)
