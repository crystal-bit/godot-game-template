extends Node


func set_main_node(node: Main):
	Scenes.main = node


func change_scene(new_scene, params= {}):
	Scenes._change_scene(new_scene, params)
