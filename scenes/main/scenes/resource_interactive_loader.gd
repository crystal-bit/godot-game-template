extends Node

signal resource_loaded(res)
signal resource_stage_loaded(current_stage, total_stages)


var stages_amount
var path
var _loader

var _loading_start_time = 0
var _time_max = 100 # msec


func load_scene(p):
	path = p
	_loading_start_time = OS.get_ticks_msec()
	_loader = ResourceLoader.load_interactive(path)
	stages_amount = float(_loader.get_stage_count())
	set_process(true)


func _process(delta):
	if _loader == null:
		return
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + _time_max:
		var err = _loader.poll()
		if err == ERR_FILE_EOF:
			_on_background_loading_completed(_loader.get_resource())
			set_process(false)
			return
		elif err == OK:
			_update_progress()
		else: # Error during loading.
			print("Error while loading new scene.")
			_loader = null
			set_process(false)



func _update_progress():
	var stage = _loader.get_stage()
	var stages_amount = _loader.get_stage_count()
	emit_signal("resource_stage_loaded", stage, stages_amount)


func _on_background_loading_completed(resource):
#	var minimum_transition_duration = 500
#	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
#	print("{scn} loaded in {elapsed}ms".format({ 'scn': resource.resource_path, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle scene transition
#	if load_time < minimum_transition_duration:
#		yield(get_tree().create_timer((minimum_transition_duration - load_time) / 1000.0), "timeout")
	emit_signal("resource_stage_loaded", stages_amount, stages_amount)
	emit_signal("resource_loaded", resource)
	_loader = null
