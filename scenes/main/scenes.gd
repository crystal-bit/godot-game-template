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

const MINIMUM_TRANSITION_DURATION = 300 # ms

# Reference to the Main node, set by main.tscn
var main
var transitions: Transition

# params caching
var _params = {}
var _loading_start_time = 0


onready var _history = preload("res://scenes/main/scenes/scenes-history.gd").new()

onready var _loader_ri = \
  preload("res://scenes/main/scenes/resource_interactive_loader.gd").new()
onready var _loader_mt = \
  preload("res://scenes/main/scenes/resource_multithread_loader.gd").new()


func _ready():
	transitions = main.transitions
	_loader_mt.name = "ResourceLoaderMultithread"
	add_child(_loader_mt)
	_loader_ri.name = "ResourceInteractiveLoader"
	add_child(_loader_ri)
	_loader_mt.connect(
		"resource_stage_loaded",
		transitions,
		"_on_resource_stage_loaded"
	)
	_loader_ri.connect(
		"resource_stage_loaded",
		transitions,
		"_on_resource_stage_loaded"
	)
	connect("change_started", self, "_on_change_started")
	pause_mode = Node.PAUSE_MODE_PROCESS
	_history.add(_get_current_scene_node().filename, null)


func get_last_loaded_scene_data() -> SceneData:
	return _history.get_last_loaded_scene_data()


func _get_current_scene_node() -> Node:
	return main.get_active_scene()


func _set_new_scene(resource: PackedScene):
	var current_scene = _get_current_scene_node()
	current_scene.queue_free()
	var instanced_scn = resource.instance() # triggers _init
	main.active_scene_container.add_child(instanced_scn) # triggers _ready
	transitions.fade_out()
	if instanced_scn.has_method("pre_start"):
		instanced_scn.pre_start(_params)
	yield(transitions.anim, "animation_finished")
	if instanced_scn.has_method("start"):
		instanced_scn.start()
	emit_signal("change_finished")


func _transition_appear(params):
	transitions.fade_in(params)


# Multithread interactive loading
func change_scene_multithread(new_scene: String, params = {}):
	emit_signal("change_started", new_scene, params)
	_params = params
	_loading_start_time = OS.get_ticks_msec()
	_transition_appear(params)
	_loader_mt.connect(
		"resource_loaded",
		self,
		"_on_resource_loaded",
		[],
		CONNECT_ONESHOT
	)
	_loader_mt.load_scene(new_scene)


# Single thread interactive loading
func change_scene_background_loading(new_scene: String, params = {}):
	_loader_ri.connect(
		"resource_loaded",
		self,
		"_on_resource_loaded",
		[],
		CONNECT_ONESHOT
	)
	emit_signal("change_started", new_scene, params)
	_params = params
	_loading_start_time = OS.get_ticks_msec()
	_transition_appear(params)
	yield(transitions.anim, "animation_finished")
	_loader_ri.load_scene(new_scene)


func _on_change_started(new_scene, params):
	_history.add(new_scene, params)


func _on_resource_loaded(resource):
	if main.transitions.is_transition_in_playing():
		yield(transitions.anim, "animation_finished")
	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({
		'scn': resource.resource_path,
		'elapsed': load_time
	}))
	# artificially wait some time in order to have a gentle scene transition
	if load_time < MINIMUM_TRANSITION_DURATION:
		yield(get_tree().create_timer((MINIMUM_TRANSITION_DURATION - load_time) / 1000.0), "timeout")
	_set_new_scene(resource)
