# Game autoload. Use `Game` global variable as a shortcut to access features.
# Eg: `Game.change_scene("res://scenes/gameplay/gameplay.tscn)`
extends Node


var size: get = get_size


func change_scene_to_file(new_scene: String, params = {}):
	if not ResourceLoader.exists(new_scene):
		push_error("Scene resource not found: ", new_scene)
		return
	Scenes.change_scene_multithread(new_scene, params)  # multi-thread


# Restart the current scene
func restart_scene():
	var scene_data = Scenes.get_last_loaded_scene_data()
	change_scene_to_file(scene_data.path, scene_data.params)


# Restart the current scene, but use given params
func restart_scene_with_params(override_params):
	var scene_data = Scenes.get_last_loaded_scene_data()
	change_scene_to_file(scene_data.path, override_params)


func get_size():
	return get_viewport().get_visible_rect().size

