extends Node

# scenes which are prevented to be loaded.
# `fallback_scene` will be loaded instead.
const scenes_denylist = [
	"res://scenes/main.tscn"
]
const fallback_scene = "res://scenes/menu/menu.tscn"
const minimum_load_time = 300 #ms

var main: Main
var loader
var wait_frames := 0
var time_max = 100 # msec
var loading_start_time = 0
var _params = {}

func _ready():
	if main == null:
		call_deferred("_force_load")


func _set_main_node(node: Main):
	main = node


func _force_load():
	""" Needed when starting a specific scene with Play Scene with F6,
	instead of starting the game from main.tscn"""
	var played_scene = get_tree().current_scene
	var root = get_node("/root")
	main = load("res://scenes/main.tscn").instance()
	main.initial_fade_active = false
	root.remove_child(played_scene)
	root.add_child(main)
	main.active_scene_container.get_child(0).queue_free()
	main.active_scene_container.add_child(played_scene)
	if played_scene.has_method("pre_start"):
		played_scene.pre_start({})
	if played_scene.has_method("start"):
		played_scene.start()
	played_scene.owner = main


func _change_scene_multithread(new_scene: String, params = {}):
	_params = params
	loading_start_time = OS.get_ticks_msec()
	var transitions: Transitions = main.transitions
	loader = ResourceLoader.load_interactive(new_scene)
	if loader == null: # Check for errors.
		print("Error while initializing ResourceLoader")
		return
	get_tree().paused = true
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_process(true)
	transitions.fade_in()
	wait_frames = 1


func _process(delta: float) -> void:
	if loader == null:
		set_process(false)
		return
	# let the "loading" animation show up.
	if wait_frames > 0:
		wait_frames -= 1
		return
	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			_on_multithread_loading_completed()
			break
		elif err == OK:
			# update_progress()
			pass
		else: # Error during loading.
			print("Error while loading new scene.")
			loader = null
			break


func _on_multithread_loading_completed():
	var resource = loader.get_resource()
	loader = null
	if main.transitions.playing():
		yield(main.transitions.anim, "animation_finished")
	var load_time = OS.get_ticks_msec() - loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({ 'scn': resource, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle scene transition
	if load_time < minimum_load_time:
		yield(get_tree().create_timer((minimum_load_time - load_time) / 1000.0), "timeout")
	_set_new_scene(resource)


func _set_new_scene(resource: PackedScene):
	var current_scene = get_current_scene_node()
	current_scene.queue_free()
	var instanced_scn = resource.instance() # triggers _init
	main.active_scene_container.add_child(instanced_scn) # triggers _ready

	var transitions: Transitions = main.transitions
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(_params)
	yield(transitions.anim, "animation_finished")
	get_tree().paused = false
	if instanced_scn.has_method("start"):
		instanced_scn.start()


func _change_scene(new_scene: String, params= {}):
	var current_scene = get_current_scene_node()
	var transitions: Transitions = main.transitions
	# prevent inputs during scene change
	get_tree().paused = true
	if new_scene in scenes_denylist:
		print_debug("WARNING: ", new_scene, " is in the denylist. Loading a default scene")
		new_scene = fallback_scene
	transitions.fade_in()
	yield(transitions.anim, "animation_finished")
	var loading_start_time = OS.get_ticks_msec()
	var scn = load(new_scene)
	current_scene.queue_free()
	var instanced_scn = scn.instance() # triggers _init
	main.active_scene_container.add_child(instanced_scn) # triggers _ready
	var load_time = OS.get_ticks_msec() - loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({ 'scn': new_scene, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle game transition
	if load_time < minimum_load_time:
		yield(get_tree().create_timer((minimum_load_time - load_time) / 1000.0), "timeout")
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(params)
	yield(transitions.anim, "animation_finished")
	get_tree().paused = false
	if instanced_scn.has_method("start"):
		instanced_scn.start()


func get_current_scene_node() -> Node:
	return main.active_scene_container.get_child(0)
