extends Node

signal resource_loaded(res)
signal resource_stage_loaded(progress_percentage)

const SIMULATED_DELAY_MS = 32  # ms

var thread: Thread
var stages_amount: int


func _ready() -> void:
	thread = Thread.new() as Thread


func load_scene(path):
	var state = thread.start(Callable(self, "_thread_load").bind(path))
	if state != OK:
		print("Error while starting thread: " + str(state))


func _thread_load(path):
	var status = ResourceLoader.load_threaded_request(path)
	if status != OK:
		push_error(status, "threaded resource failed")
		return
#	stages_amount = ril.get_stage_count()
	var res = null
	var progress_arr = []
	var loading_status  # ThreadLoadStatus

	while true:
		loading_status = ResourceLoader.load_threaded_get_status(path, progress_arr)
		call_deferred("emit_signal", "resource_stage_loaded", float(progress_arr[0]))
		if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
			res = ResourceLoader.load_threaded_get(path)
			break
		elif loading_status == ResourceLoader.THREAD_LOAD_FAILED:
			print("There was an error loading")
			break
		elif loading_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Invalid resource: {0}".format(path))
		else:
			# loading ...
			pass
		OS.delay_msec(SIMULATED_DELAY_MS)
	call_deferred("_thread_done", res)


func _thread_done(resource):
	assert(resource)
	# Always wait for threads to finish, this is required on Windows.
	thread.wait_to_finish()
	emit_signal("resource_loaded", resource)


func _exit_tree() -> void:
	if thread and thread.is_alive():
		thread.wait_to_finish()
