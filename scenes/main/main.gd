# Handles scene transitions and other utilities such as input locking.
class_name Main
extends Node

# Scenes which are prevented to be loaded.
# Eg: if you try to call Game.change_scene("res://scenes/main.tscn")
# the scene manager will load `fallback_scene` instead.
const SCENES_DENYLIST = [
	"res://scenes/main/main.tscn"
]
# Fallback scene loaded if you try to load a scene contained in `SCENES_DENYLIST`.
const FALLBACK_SCENE = "res://scenes/menu/menu.tscn"

# Toggles initial graphic transition when starting the game.
# Scenes run with "Play Scene" never use transitions (to speed up development).
# Note: this may be replaced with custom splash screens in the future
export var splash_transition_on_start = false

var size := Vector2()
var scenes: Scenes

onready var transitions: Transition = $Transitions
onready var active_scene_container = $ActiveSceneContainer


func _enter_tree() -> void:
	_register_size()
	get_tree().connect("screen_resized", self, "_on_screen_resized")


func _ready() -> void:
	scenes = preload("res://scenes/main/scenes.gd").new()
	scenes.name = "Scenes"
	scenes.main = self
	scenes.connect("change_finished", self, "_on_Scenes_change_finished")
	get_node("/root/").call_deferred("add_child", scenes)


func _on_screen_resized():
	_register_size()


func _register_size():
	size = get_viewport().get_visible_rect().size


func change_scene(new_scene: String, params = {}):
	var scene_to_load = new_scene if not(new_scene in SCENES_DENYLIST) else FALLBACK_SCENE

	if not is_scene_valid(new_scene):
		printerr("Scene file not found: ", new_scene)
		return

	if OS.has_feature('HTML5'): # Godot 3.2.3 HTML5 export template does not support multithreading
		scenes.change_scene_background_loading(scene_to_load, params) # single-thread
	else:
		scenes.change_scene_multithread(scene_to_load, params) # multi-thread


# Restart the current scene
func restart_scene():
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene(scene_data.path, scene_data.params)


# Restart the current scene, but use given params
func restart_scene_with_params(override_params):
	var scene_data = scenes.get_last_loaded_scene_data()
	change_scene(scene_data.path, override_params)


func is_scene_valid(path) -> bool:
	var f = File.new()
	return f.file_exists(path)


# Reparent a node under a new parent.
# Optionally updates the transform to mantain the current
# position, scale and rotation values.
func reparent_node(node: Node2D, new_parent, update_transform = false):
	var previous_xform = node.global_transform
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	if update_transform:
		node.global_transform = previous_xform


func get_active_scene() -> Node:
	return active_scene_container.get_child(0)


# Prevents all inputs while a graphic transition is playing.
func _input(_event: InputEvent):
	if transitions.is_displayed():
		# prevent all input events
		get_tree().set_input_as_handled()


# Unpause the game when the transition finishes.
func _on_Scenes_change_finished():
	get_tree().paused = false
