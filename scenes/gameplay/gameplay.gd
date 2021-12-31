extends Node

var elapsed = 0

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	print("\ngameplay.gd:pre_start() called with params = ")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
	$Sprite.position = Game.size / 2
	set_process(false)


# `start()` is called when the graphic transition ends.
func start():
	print("\ngameplay.gd:start() called")
	var active_scene: Node = Game.get_active_scene()
	print("\nCurrent active scene is: ",
		active_scene.name, " (", active_scene.filename, ")")
	set_process(true)


func _process(delta):
	elapsed += delta
	$Sprite.position.x = Game.size.x / 2 + 150 * sin(2 * 0.4 * PI * elapsed)
	$Sprite.position.y = Game.size.y / 2 + 100 * sin(2 * 0.2 *  PI * elapsed)
