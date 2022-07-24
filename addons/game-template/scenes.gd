# Scenes manager.
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

onready var transitions: Transition = get_node_or_null("/root/Transitions")
onready var _history = preload("res://addons/game-template/scenes/scenes-history.gd").new()
onready var _loader_ri = \
  preload("res://addons/game-template/scenes/resource_interactive_loader.gd").new()
onready var _loader_mt = \
  preload("res://addons/game-template/scenes/resource_multithread_loader.gd").new()

# params caching
var _params = {}
var _loading_start_time = 0


func _ready():
	_loader_mt.name = "ResourceLoaderMultithread"
	add_child(_loader_mt)
	_loader_ri.name = "ResourceInteractiveLoader"
	add_child(_loader_ri)
	if transitions:
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
	var cur_scene = get_tree().current_scene
	_history.add(cur_scene.filename, {})
	# if playing a specific scene
	if ProjectSettings.get("application/run/main_scene") != cur_scene.filename:
		# call pre_start and start method to ensure compatibility with "Play Scene"
		if cur_scene.has_method("pre_start"):
			cur_scene.pre_start({})
		if cur_scene.has_method("start"):
			cur_scene.start()


func get_last_loaded_scene_data() -> SceneData:
	return _history.get_last_loaded_scene_data()



func _set_new_scene(resource: PackedScene):
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	yield(current_scene, "tree_exited") # wait for the current scene to be fully removed
	var instanced_scn: Node = resource.instance() # triggers _init
	get_tree().root.add_child(instanced_scn) # triggers _ready
	get_tree().current_scene = instanced_scn
	if instanced_scn.has_method("pre_start"):
		var coroutine_state = instanced_scn.pre_start(_params)
		if (coroutine_state is GDScriptFunctionState) and (coroutine_state.is_valid()):
			yield(coroutine_state, "completed")
	if transitions:
		transitions.fade_out()
	if transitions:
		yield(transitions.anim, "animation_finished")
	if instanced_scn.has_method("start"):
		instanced_scn.start()
	emit_signal("change_finished")
	_params = {}
	_loading_start_time = 0


func _transition_appear(params):
	if transitions:
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
	if transitions:
		yield(transitions.anim, "animation_finished")
	_loader_ri.load_scene(new_scene)


func _on_change_started(new_scene, params):
	_history.add(new_scene, params)


func _on_resource_loaded(resource):
	if transitions and transitions.is_transition_in_playing():
		yield(transitions.anim, "animation_finished")
	var load_time = OS.get_ticks_msec() - _loading_start_time # ms
	print("{scn} loaded in {elapsed}ms".format({
		'scn': resource.resource_path,
		'elapsed': load_time
	}))
	# artificially wait some time in order to have a gentle scene transition
	if transitions and load_time < MINIMUM_TRANSITION_DURATION:
		yield(get_tree().create_timer((MINIMUM_TRANSITION_DURATION - load_time) / 1000.0), "timeout")
	_set_new_scene(resource)
