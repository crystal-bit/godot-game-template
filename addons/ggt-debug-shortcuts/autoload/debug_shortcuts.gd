extends Node


func _ready():
	if OS.is_debug_build() == false:
		queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("debug_pause_game"):
			get_tree().paused = !get_tree().paused
		elif event.is_action_pressed("debug_quit_game"):
			get_tree().quit()
		elif event.is_action_pressed("debug_restart_scene"):
			var ggt_game_autoload = get_node_or_null("/root/Game")
			# if "ggt-core" addon is enabled
			if ggt_game_autoload:
				ggt_game_autoload.restart_scene()
			else:
				get_tree().reload_current_scene()
