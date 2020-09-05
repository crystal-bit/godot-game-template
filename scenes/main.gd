class_name Main
extends Node

onready var anims: AnimationPlayer = $Transitions/AnimationPlayer
onready var active_scene_container = $ActiveSceneContainer

var initial_fade_active = true


func _init():
	Game.init(self)


func _ready():
	var active_scene: Node = get_active_scene()
	active_scene.set_process_input(false)
	active_scene.set_process_unhandled_input(false)

	if initial_fade_active:
		anims.play("black")
		yield(get_tree().create_timer(1), "timeout")
		anims.play("fade-from-black")


func get_active_scene():
	return active_scene_container.get_child(0)


func _input(event):
	# if there is a transition playing
	if anims.is_playing():
		# prevent  all input events
		get_tree().set_input_as_handled()

