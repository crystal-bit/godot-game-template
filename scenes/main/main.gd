# Handles scene transitions and other utilities such as input locking.
class_name Main
extends Node

onready var transitions: Transition = $Transitions
onready var active_scene_container = $ActiveSceneContainer

var initial_fade_active = true
var size := Vector2()
var scenes: Scenes


func _ready() -> void:
	# setup Scenes node
	scenes = preload("res://scenes/main/scenes.gd").new()
	scenes.name = "Scenes"
	scenes.main = self
	scenes.connect("change_finished", self, "_on_Scenes_change_finished")
	scenes.connect("change_started", self, "_on_Scenes_change_started")
	get_node("/root/").call_deferred("add_child", scenes)
	# setup
	if initial_fade_active:
		transitions.set_black()
		yield(get_tree().create_timer(0.3), "timeout")
		transitions.fade_out()
	# size property
	_register_size()
	get_tree().connect("screen_resized", self, "_on_screen_resized")


func _on_screen_resized():
	_register_size()


func _register_size():
	size = get_viewport().get_visible_rect().size


func _on_Scenes_change_started():
	get_tree().paused = true


func _on_Scenes_change_finished():
	get_tree().paused = false


func change_scene(new_scene, params= {}):
#	scenes._change_scene(new_scene, params)
#	scenes._change_scene_background_loading(new_scene, params)
	scenes._change_scene_multithread(new_scene, params)

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


func _input(event: InputEvent):
	if transitions.is_playing():
		# prevent all input events
		get_tree().set_input_as_handled()
