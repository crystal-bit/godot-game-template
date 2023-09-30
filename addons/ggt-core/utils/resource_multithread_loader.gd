extends RefCounted

signal resource_loaded(res)
signal resource_stage_loaded(progress_percentage)

const SIMULATED_DELAY_MS = 32

var thread
var stages_amount: int


func load_resource(path):
	if thread == null:
		thread = Thread.new()
	if ResourceLoader.has_cached(path):
		return ResourceLoader.load(path)
	else:
		var state = thread.start(Callable(self, "_thread_load").bind(path))
		if state != OK:
			push_error("Error while starting thread: " + str(state))


func _thread_load(path):
	var status = ResourceLoader.load_threaded_request(path)
	if status != OK:
		push_error(status, "threaded resource failed")
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
			push_error("Thread load failed for: {0}".format([path]))
			break
		elif loading_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Thread invalid resource: {0}".format([path]))
		else:
			call_deferred("emit_signal", "resource_stage_loaded", float(progress_arr[0]))
			pass
		OS.delay_msec(SIMULATED_DELAY_MS)
	call_deferred("_thread_done", res)


func _thread_done(resource):
	assert(resource)
	# Always wait for threads to finish, this is required on Windows.
	thread.wait_to_finish()
	emit_signal("resource_loaded", resource)


#func _exit_tree():
#	if thread and thread.is_alive():
#		thread.wait_to_finish()
