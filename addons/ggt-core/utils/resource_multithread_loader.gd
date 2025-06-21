extends RefCounted

signal resource_loaded(res)
signal resource_stage_loaded(progress_percentage)

const SIMULATED_DELAY_MS = 32

var thread
var stages_amount: int


func load_resource(path):
	if OS.has_feature("web"):
		_handle_load(path, true)
	else:
		if thread == null:
			thread = Thread.new()
		if ResourceLoader.has_cached(path):
			return ResourceLoader.load(path)
		else:
			_load_resource_threaded(path)


func _load_resource_threaded(path):
	var state = thread.start(Callable(self, "_handle_load").bind(path, false))
	if state != OK:
		push_error("Error while starting thread: " + str(state))


func _handle_load(path, runs_on_main_thread: bool):
	var status = ResourceLoader.load_threaded_request(path)
	if status != OK:
		push_error(status, "resource request failed")
		return

	var res = null
	var progress_arr = []

	while true:
		var loading_status = ResourceLoader.load_threaded_get_status(path, progress_arr)

		if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
			call_deferred("emit_signal", "resource_stage_loaded", float(progress_arr[0]))
			res = ResourceLoader.load_threaded_get(path)
			break
		elif loading_status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Load failed for: {0}".format([path]))
			return
		elif loading_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Invalid resource: {0}".format([path]))
			return

		if runs_on_main_thread:
			await Engine.get_main_loop().create_timer(SIMULATED_DELAY_MS / 1000.0).timeout
		else:
			OS.delay_msec(SIMULATED_DELAY_MS)
	call_deferred("_thread_done", res)


func _thread_done(resource):
	assert(resource)
	if thread:
		# Always wait for threads to finish, this is required on Windows.
		thread.wait_to_finish()
	emit_signal("resource_loaded", resource)
