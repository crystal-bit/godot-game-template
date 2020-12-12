# Game autoload, used to setup the main game template architecture.
# It's used also as a shortcut to access some features such as Game.change_scene
extends Node


onready var main: Main = get_node_or_null("/root/Main")


func _ready():
	if main == null:
		call_deferred("_force_main_scene_load")


func _force_main_scene_load():
	# Loads scenes/main.tscn and set the currently played
	# scene as ActiveSceneContainer node.
	# Needed when playing a scene which is not
	# scenes/main.tscn (eg:with Play Scene with F6)
	var played_scene = get_tree().current_scene
	var root = get_node("/root")
	main = load("res://scenes/main.tscn").instance()
	main.initial_fade_active = false
	root.remove_child(played_scene)
	root.add_child(main)
	main.active_scene_container.get_child(0).queue_free()
	main.active_scene_container.add_child(played_scene)
	if played_scene.has_method("pre_start"):
		played_scene.pre_start({})
	if played_scene.has_method("start"):
		played_scene.start()
	played_scene.owner = main


func change_scene(new_scene, params= {}):
	main.change_scene(new_scene, params)


func reparent_node(node: Node2D, new_parent, update_transform = true):
	main.reparent_node(node, new_parent, update_transform)
