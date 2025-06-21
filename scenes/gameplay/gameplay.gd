extends Node

@onready var sprite_2d: Sprite2D = $Sprite2D

var t = 0

func _ready() -> void:
	var scene_data = Scenes.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	sprite_2d.position = Game.size / 2

	if Scenes.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await Scenes.change_finished

	print("GGT/Gameplay: scene transition animation finished")


func _process(delta):
	t += delta * 1.5
	sprite_2d.position.x = Game.size.x / 2.0 + 200.0 * sin(t * 0.8)
	sprite_2d.position.y = Game.size.y / 2.0 + 140.0 * sin(t)
