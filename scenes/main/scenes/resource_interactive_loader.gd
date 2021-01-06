extends Node

signal resource_loaded(res)
signal resource_stage_loaded(current_stage, total_stages)

const SIMULATED_DELAY_MS = 100 # ms

var _path
var _loader
var _stages_amount
var _loading_start_time = 0


func load_scene(p):
	_path = p
	_loading_start_time = OS.get_ticks_msec()
	_loader = ResourceLoader.load_interactive(_path)
	_stages_amount = float(_loader.get_stage_count())
	set_process(true)


func _process(_delta):
	if _loader == null:
		return
	while true:
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
			return
		OS.delay_msec(SIMULATED_DELAY_MS)



func _update_progress():
	var stage = _loader.get_stage()
	_stages_amount = _loader.get_stage_count()
	emit_signal("resource_stage_loaded", stage, _stages_amount)


func _on_background_loading_completed(resource):
	emit_signal("resource_stage_loaded", _stages_amount, _stages_amount)
	emit_signal("resource_loaded", resource)
	_loader = null
