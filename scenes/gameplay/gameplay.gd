extends Node2D


# `pre_start()` is called when a scene is totally loaded. 
# Use this function to receive params from the scene which
# called `Game.change_scene(params)` and to init your 
# new scene. 
#
# At this point the game is paused (`get_tree().paused = true`).
func pre_start(params):
	print("\n gameplay.gd:pre_start() called with params = ")
	for key in params:
		var val = params[key]
		printt("", key, val)


# `start()` is called when the graphic transition ends. 
func start():
	print("\n gameplay.gd:start() called")
	var active_scene: Node = Game.get_active_scene()
	print("\nCurrent active scene is: ",
		active_scene.name, " (", active_scene.filename, ")")
