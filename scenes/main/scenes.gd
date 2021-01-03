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
const minimum_transition_duration = 50 #ms

# Reference to the Main node, set by main.tscn
var main

# params caching
var _params = {}
var _loading_start_time = 0

onready var _resource_interactive_loader = preload("res://scenes/main/scenes/resource_interactive_loader.gd").new()
onready var _resource_multithread_loader = preload("res://scenes/main/scenes/resource_multithread_loader.gd").new()


func _ready():
	_resource_multithread_loader.name = "ResourceLoaderMultithread"
	add_child(_resource_multithread_loader)
	_resource_interactive_loader.name = "ResourceInteractiveLoader"
	add_child(_resource_interactive_loader)


	pause_mode = Node.PAUSE_MODE_PROCESS


func _get_current_scene_node() -> Node:
	return main.get_active_scene()


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


func _transition_appear(transitions: Transition, params):
	transitions.fade_in({
		'show_progress_bar': params.get('show_progress_bar')
	})


func _transition_disappear():
	pass


# Multithread interactive loading
func _change_scene_multithread(new_scene: String, params = {}):
	emit_signal("change_started")
	_params = params
	_loading_start_time = OS.get_ticks_msec()
	var transitions: Transition = main.transitions
	_transition_appear(transitions, params)
	# TODO: start loading resources while starting the transition
	yield(transitions.anim, "animation_finished")
	_resource_multithread_loader.connect("resource_loaded", self, "_on_resource_loaded", [], CONNECT_ONESHOT)
	if not _resource_multithread_loader.is_connected("resource_stage_loaded", transitions, "_on_resource_stage_loaded"):
		_resource_multithread_loader.connect("resource_stage_loaded", transitions, "_on_resource_stage_loaded")
	_resource_multithread_loader.load_scene(new_scene)


# Single thread interactive loading
func _change_scene_background_loading(new_scene: String, params = {}):
	var transitions: Transition = main.transitions
	var _loader = _resource_interactive_loader
	_loader.connect("resource_loaded", self, "_on_resource_loaded", [], CONNECT_ONESHOT)
	if not _loader.is_connected("resource_stage_loaded", transitions, "_on_resource_stage_loaded"):
		_loader.connect("resource_stage_loaded", transitions, "_on_resource_stage_loaded")
	if _loader == null: # Check for errors.
		print("Error while initializing ResourceLoader")
		return
	emit_signal("change_started")
	_params = params
	_loading_start_time = OS.get_ticks_msec()
	_transition_appear(transitions, params)
	yield(transitions.anim, "animation_finished")
	_loader.load_scene(new_scene)


func _on_resource_loaded(resource):
	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({ 'scn': resource.resource_path, 'elapsed': load_time }))
	# artificially wait some time in order to have a gentle scene transition
	if load_time < minimum_transition_duration:
		yield(get_tree().create_timer((minimum_transition_duration - load_time) / 1000.0), "timeout")
	_set_new_scene(resource)
