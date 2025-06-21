extends Node

@onready var sprite_2d: Sprite2D = $Sprite2D

var t = 0

func _ready() -> void:
	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	sprite_2d.position = get_viewport().get_visible_rect().size / 2

	if GGT.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await GGT.change_finished

	print("GGT/Gameplay: scene transition animation finished")


func _process(delta):
	var size = get_viewport().get_visible_rect().size
	t += delta * 1.5
	sprite_2d.position.x = size.x / 2.0 + 200.0 * sin(t * 0.8)
	sprite_2d.position.y = size.y / 2.0 + 140.0 * sin(t)
