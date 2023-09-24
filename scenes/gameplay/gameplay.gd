extends Node

var elapsed = 0


# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
	$Sprite2D.position = Game.size / 2


# `start()` is called after pre_start and after the graphic transition ends.
func start():
	print("gameplay.gd: start() called")


func _process(delta):
	elapsed += delta
	$Sprite2D.position.x = Game.size.x / 2 + 150 * sin(2 * 0.4 * PI * elapsed)
	$Sprite2D.position.y = Game.size.y / 2 + 100 * sin(2 * 0.2 * PI * elapsed)
