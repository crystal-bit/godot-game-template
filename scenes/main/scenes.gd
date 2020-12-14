# Scene manager.
# When the loading of a new scene is completed, it calls
# two methods on the new loaded scene (if they are defined):
# 1. `pre_start(params)`: called as soon as the scene is loaded in memory.
#   It passes the `params` object received by
#   `Game.change_scene(new_scene, params)`.
# 2. `start()`: called when the scene transition is finished and when the
#  gameplay input is unlocked
class_name Scenes
extends Node

signal change_started
signal change_finished

# Scenes which are prevented to be loaded.
# Eg: if you try to call Game.change_scene("res://scenes/main.tscn")
# the scene manager will load `fallback_scene` instead.
const scenes_denylist = [
	"res://scenes/main.tscn"
]
# Fallback scene loaded if you try to load a scene contained in `scenes_denylist`.
const fallback_scene = "res://scenes/menu/menu.tscn"
const minimum_transition_duration = 350 #ms

# Reference to the Main node, set by main.tscn
var main
var _params = {}

var _loader: ResourceInteractiveLoader
var _loading_start_time = 0
var _time_max = 400 # msec

onready var _resource_multithread_loader = preload("res://scenes/main/scenes/resource_multithread_loader.gd").new()


func _ready():
	_resource_multithread_loader.name = "ResourceLoaderMultithread"
	add_child(_resource_multithread_loader)
	pause_mode = Node.PAUSE_MODE_PROCESS


func _get_current_scene_node() -> Node:
	return main.get_active_scene()


func _change_scene_background_loading(new_scene: String, params = {}):
	_loader = ResourceLoader.load_interactive(new_scene)
	if _loader == null: # Check for errors.
		print("Error while initializing ResourceLoader")
		return
	emit_signal("change_started")
	_params = params
	_loading_start_time = OS.get_ticks_msec()
	var transitions: Transition = main.transitions
	transitions.fade_in()
	yield(transitions.anim, "animation_finished")
	set_process(true)


func _process(delta: float) -> void:
	if _loader == null:
		set_process(false)
		return
	var t = OS.get_ticks_msec()
	# Use "_time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + _time_max:
		var err = _loader.poll()
		if err == ERR_FILE_EOF:
			_on_background_loading_completed()
			return
		elif err == OK:
			_update_progress()
		else: # Error during loading.
			print("Error while loading new scene.")
			_loader = null
			return


func _update_progress():
	# use load_ratio to update your Loading screen
	var load_ratio = float(_loader.get_stage()) / float(_loader.get_stage_count())


func _on_background_loading_completed():
	var resource = _loader.get_resource()
	_loader = null
	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({ 'scn': resource.resource_path, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle scene transition
	if load_time < minimum_transition_duration:
		yield(get_tree().create_timer((minimum_transition_duration - load_time) / 1000.0), "timeout")
	_set_new_scene(resource)


func _set_new_scene(resource: PackedScene):
	var current_scene = _get_current_scene_node()
	current_scene.queue_free()
	var instanced_scn = resource.instance() # triggers _init
	main.active_scene_container.add_child(instanced_scn) # triggers _ready

	var transitions: Transition = main.transitions
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(_params)
	yield(transitions.anim, "animation_finished")
	if instanced_scn.has_method("start"):
		instanced_scn.start()
	emit_signal("change_finished")


func _change_scene(new_scene: String, params= {}):
	emit_signal("change_started")

	var current_scene = _get_current_scene_node()
	var transitions: Transition = main.transition

	# prevent inputs during scene change
	get_tree().paused = true
	if new_scene in scenes_denylist:
		print_debug("WARNING: ", new_scene, " is in the denylist. Loading a default scene")
		new_scene = fallback_scene
	transitions.fade_in()
	yield(transitions.anim, "animation_finished")
	var _loading_start_time = OS.get_ticks_msec()
	var scn = load(new_scene)
	current_scene.queue_free()
	var instanced_scn = scn.instance() # triggers _init
	main.active_scene_container.add_child(instanced_scn) # triggers _ready
	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({ 'scn': new_scene, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle game transition
	if load_time < minimum_transition_duration:
		yield(get_tree().create_timer((minimum_transition_duration - load_time) / 1000.0), "timeout")
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(params)
	yield(transitions.anim, "animation_finished")
	get_tree().paused = false
	if instanced_scn.has_method("start"):
		instanced_scn.start()
	emit_signal("change_finished")


# --- MULTITHREAD STUFF

func _change_scene_multithread(new_scene: String, params = {}):
	emit_signal("change_started")
	_params = params
	_loading_start_time = OS.get_ticks_msec()
	var transitions: Transition = main.transitions
	transitions.fade_in()
	# TODO: start loading resources while starting the transition
	yield(transitions.anim, "animation_finished")
	_resource_multithread_loader.connect("resource_loaded", self, "_on_resource_loaded", [], CONNECT_ONESHOT)
	_resource_multithread_loader.load_scene(new_scene)


func _on_resource_loaded(resource):
	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({ 'scn': resource.resource_path, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle scene transition
	if load_time < minimum_transition_duration:
		yield(get_tree().create_timer((minimum_transition_duration - load_time) / 1000.0), "timeout")
	_set_new_scene(resource)
