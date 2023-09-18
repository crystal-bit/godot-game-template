# Game autoload. Use `Game` global variable as a shortcut to access features.
# Eg: `Game.change_scene("res://scenes/gameplay/gameplay.tscn)`
extends Node


@onready var transitions = get_node_or_null("/root/Transitions")

var pause_scenes_on_transitions = false
var prevent_input_on_transitions = true
var scenes: Scenes
var size : get = get_size  


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # needed to make "prevent_input_on_transitions" work even if the game is paused
	if transitions:
		transitions.connect("transition_started", Callable(self, "_on_Transitions_transition_started"))
		transitions.connect("transition_finished", Callable(self, "_on_Transitions_transition_finished"))


func _ready() -> void:
	scenes = preload("res://addons/game-template/scenes.gd").new()
	scenes.name = "Scenes"
	get_node("/root/").call_deferred("add_child", scenes)


func change_scene_to_file(new_scene: String, params = {}):
	if not ResourceLoader.exists(new_scene):
		push_error("Scene resource not found: ", new_scene)
		return
	scenes.change_scene_multithread(new_scene, params) # multi-thread


# Restart the current scene
func restart_scene():
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene_to_file(scene_data.path, scene_data.params)


# Restart the current scene, but use given params
func restart_scene_with_params(override_params):
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene_to_file(scene_data.path, override_params)


func get_size():
	return get_viewport().get_visible_rect().size
	

# Prevents all inputs while a graphic transition is playing.
func _input(_event: InputEvent):
	if transitions and prevent_input_on_transitions and transitions.is_displayed():
		# prevent all input events
		get_viewport().set_input_as_handled()


func _on_Transitions_transition_started(anim_name):
	if pause_scenes_on_transitions:
		get_tree().paused = true


func _on_Transitions_transition_finished(anim_name):
	if pause_scenes_on_transitions:
		get_tree().paused = false

