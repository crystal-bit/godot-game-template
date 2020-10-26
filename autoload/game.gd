extends Node


var size := Vector2.ZERO

func _ready() -> void:
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	_register_size()


func _on_screen_resized():
	_register_size()


func _register_size():
	size = get_viewport().get_visible_rect().size


func set_main_node(node: Main):
	Scenes.main = node


func change_scene(new_scene, params= {}):
	Scenes._change_scene(new_scene, params)
