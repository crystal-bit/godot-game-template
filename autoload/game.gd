extends Node


var size := Vector2()


func _ready() -> void:
	Scenes.connect("change_finished", self, "_on_Scenes_change_finished")
	Scenes.connect("change_started", self, "_on_Scenes_change_started")
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	_register_size()


func _set_main_node(node: Main):
	""" You shouldn't call this. It's already handled by the game template. """
	Scenes.main = node


func _on_screen_resized():
	_register_size()


func _register_size():
	size = get_viewport().get_visible_rect().size


func change_scene(new_scene, params= {}):
#	Scenes._change_scene(new_scene, params)
#	Scenes._change_scene_background_loading(new_scene, params)
	Scenes._change_scene_multithread(new_scene, params)


func _on_Scenes_change_started():
	get_tree().paused = true


func _on_Scenes_change_finished():
	get_tree().paused = false


func reparent_node(node: Node2D, new_parent, update_transform = true):
	var previous_xform = node.global_transform
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	node.global_transform = previous_xform
