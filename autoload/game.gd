# Game autoload. Use `Game` global variable as a shortcut to access
# features.
# Eg: `Game.change_scene("res://scenes/gameplay/gameplay.tscn)`
# Handles also the main game architecture when playing
# a specific scene.
extends Node


var size: Vector2 setget , get_size

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
	main = load("res://scenes/main/main.tscn").instance()
	main.splash_transition_on_start = false
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


func restart_scene():
	main.restart_scene()


func restart_scene_with_params(override_params):
	main.restart_scene_with_params(override_params)


func reparent_node(node: Node2D, new_parent, update_transform = true):
	main.reparent_node(node, new_parent, update_transform)


func get_active_scene() -> Node:
	return main.get_active_scene()


func get_size():
	return main.size
