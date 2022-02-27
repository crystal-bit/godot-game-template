extends Node

signal resource_loaded(res)
signal resource_stage_loaded(current_stage, total_stages)

var _path
var _loader
var _stages_amount
var _elapsed = 0
const LOAD_STEP_DELAY = 2 # `_process` calls.

func _ready() -> void:
	set_process(false)


func load_scene(p):
	_path = p
	_loader = ResourceLoader.load_interactive(_path)
	_stages_amount = float(_loader.get_stage_count())
	set_process(true)


func _process(_delta: float):
	_elapsed += 1
	if _elapsed >= LOAD_STEP_DELAY:
		load_step()
		_elapsed = 0


func load_step():
	if _loader == null:
		return
	var err = _loader.poll()
	if err == ERR_FILE_EOF:
		_update_progress()
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


func _update_progress():
	var stage = _loader.get_stage()
	_stages_amount = _loader.get_stage_count()
	emit_signal("resource_stage_loaded", stage + 1, _stages_amount)


func _on_background_loading_completed(resource):
	emit_signal("resource_loaded", resource)
	_loader = null
