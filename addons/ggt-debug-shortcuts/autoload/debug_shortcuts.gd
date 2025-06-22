extends Node

var _advancing_frame = false


func _ready():
	if OS.is_debug_build() == false:
		queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if _advancing_frame:
		return

	if event is InputEventKey:
		if event.is_action_pressed("ggt_debug_pause_game"):
			get_tree().paused = !get_tree().paused
		elif event.is_action_pressed("ggt_debug_step_frame"):
			frame_advance()
		elif event.is_action_pressed("ggt_debug_quit_game"):
			get_tree().quit()
		elif event.is_action_pressed("ggt_debug_restart_scene"):
			var ggt = get_node_or_null("/root/GGT")
			# if "ggt-core" addon is enabled
			if ggt:
				ggt.restart_scene()
			else:
				get_tree().reload_current_scene()
		elif event.is_action_pressed("ggt_debug_speedup_game"):
			Engine.time_scale = 2 # if your gameplay changes timescale, then you probably want to create a time scale manager script to avoid issues
		elif event.is_action_released("ggt_debug_speedup_game"):
			Engine.time_scale = 1


func frame_advance():
	if get_tree().paused:
		_advancing_frame = true
		get_tree().paused = false
		await get_tree().process_frame
		await get_tree().physics_frame
		get_tree().paused = true
		_advancing_frame = false
