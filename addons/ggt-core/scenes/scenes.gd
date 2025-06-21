# Scenes manager.
# When the loading of a new scene is completed, it calls
# two methods on the new loaded scene (if they are defined):
# 1. `pre_start(params)`: called as soon as the scene is loaded in memory.
#   It passes the `params` object received by
#   `Game.change_scene(new_scene, params)`.
# 2. `start()`: called when the scene transition is finished and when the
#  gameplay input is unlocked
extends Node

signal change_started
signal change_finished

var _loading_start_time = 0
var _changing_scene = false

@onready var transitions = get_node("/root/Transitions")
@onready var _history = preload("res://addons/ggt-core/scenes/scenes-history.gd").new()
@onready var _loader_mt = preload("res://addons/ggt-core/utils/resource_multithread_loader.gd").new()
const config = preload("res://addons/ggt-core/config.tres")


func _ready():
	if transitions:
		_loader_mt.connect("resource_stage_loaded", transitions._on_resource_stage_loaded)
	process_mode = Node.PROCESS_MODE_ALWAYS
	var cur_scene: Node = get_tree().current_scene
	_history.add(cur_scene.scene_file_path, {})
	# if playing a specific scene
	if ProjectSettings.get("application/run/main_scene") != cur_scene.scene_file_path:
		# call pre_start and start method to ensure compatibility with "Play Scene"
		if not cur_scene.is_node_ready():
			await cur_scene.ready
		if cur_scene.has_method("pre_start"):
			cur_scene.pre_start({})
		if cur_scene.has_method("start"):
			cur_scene.start()


func get_current_scene_data() -> GGT_SceneData:
	return _history.get_last_loaded_scene_data()


func _set_new_scene(resource: PackedScene):
	get_tree().change_scene_to_packed(resource)
	if transitions:
		transitions.fade_out()
	if transitions:
		await transitions.anim.animation_finished
	emit_signal("change_finished")
	_loading_start_time = 0
	_changing_scene = false


func _transition_appear(params):
	if transitions:
		transitions.fade_in(params)


func change_scene_multithread(new_scene: String, params = {}):
	_changing_scene = true
	emit_signal("change_started", new_scene, params)
	_history.add(new_scene, params)
	_loading_start_time = Time.get_ticks_msec()
	_transition_appear(params)
	_loader_mt.connect("resource_loaded", _on_resource_loaded, CONNECT_ONE_SHOT)
	await transitions.transition_covered_screen
	_loader_mt.load_resource(new_scene)


func _on_resource_loaded(resource):
	if transitions and transitions.is_transition_in_playing():
		await transitions.anim.animation_finished
	var load_time = Time.get_ticks_msec() - _loading_start_time # ms
	print(
		"GGT: {scn} loaded in {elapsed}ms".format({"scn": resource.resource_path, "elapsed": load_time})
	)
	# artificially wait some time in order to have a gentle scene transition
	if transitions and load_time < config.transitions_minimum_duration_ms:
		await get_tree().create_timer((config.transitions_minimum_duration_ms - load_time) / 1000.0).timeout
	_set_new_scene(resource)


func is_changing_scene() -> bool:
	return _changing_scene
