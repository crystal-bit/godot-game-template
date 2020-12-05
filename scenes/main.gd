class_name Main
extends Node

onready var transitions: Transitions = $Transitions
onready var active_scene_container = $ActiveSceneContainer

var initial_fade_active = true


func _init():
	Game._set_main_node(self)


func _ready():
	var active_scene: Node = get_active_scene()

	if initial_fade_active:
		transitions.set_black()
		yield(get_tree().create_timer(0.3), "timeout")
		transitions.fade_out()


func get_active_scene() -> Node:
	return active_scene_container.get_child(0)


func _input(event: InputEvent):
	if transitions.playing():
		# prevent  all input events
		get_tree().set_input_as_handled()
