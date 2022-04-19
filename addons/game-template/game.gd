# Game autoload. Use `Game` global variable as a shortcut to access features.
# Eg: `Game.change_scene("res://scenes/gameplay/gameplay.tscn)`
extends Node


onready var transitions = get_node_or_null("/root/Transitions")

var pause_scenes_on_transitions = false
var prevent_input_on_transitions = true
var scenes: Scenes
var size: Vector2


func _enter_tree() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS # needed to make "prevent_input_on_transitions" work even if the game is paused
	_register_size()
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	if transitions:
		transitions.connect("transition_started", self, "_on_Transitions_transition_started")
		transitions.connect("transition_finished", self, "_on_Transitions_transition_finished")
#	add_script("Utils", "utils", "res://addons/game-template/utils.gd")


func _ready() -> void:
	scenes = preload("res://addons/game-template/scenes.gd").new()
	scenes.name = "Scenes"
	get_node("/root/").call_deferred("add_child", scenes)


func _on_screen_resized():
	_register_size()


func _register_size():
	size = get_viewport().get_visible_rect().size


func change_scene(new_scene: String, params = {}):
	if not Utils.file_exists(new_scene):
		printerr("Scene file not found: ", new_scene)
		return

	if OS.has_feature('HTML5'): # See https://github.com/crystal-bit/godot-game-template/wiki/2.-Features#single-thread-vs-multihtread
		scenes.change_scene_background_loading(new_scene, params) # single-thread
	else:
		scenes.change_scene_multithread(new_scene, params) # multi-thread


# Restart the current scene
func restart_scene():
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene(scene_data.path, scene_data.params)


# Restart the current scene, but use given params
func restart_scene_with_params(override_params):
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene(scene_data.path, override_params)


# Prevents all inputs while a graphic transition is playing.
func _input(_event: InputEvent):
	if transitions and prevent_input_on_transitions and transitions.is_displayed():
		# prevent all input events
		get_tree().set_input_as_handled()


func _on_Transitions_transition_started(anim_name):
	if pause_scenes_on_transitions:
		get_tree().paused = true


func _on_Transitions_transition_finished(anim_name):
	if pause_scenes_on_transitions:
		get_tree().paused = false


func add_script(script_name, self_prop_name, script_path):
	var new_script: Node = load(script_path).new()
	new_script.name = script_name
	call_deferred("add_script_node", new_script, self_prop_name)


func add_script_node(new_node, prop_name):
	get_tree().root.add_child(new_node)
	self[prop_name] = new_node
