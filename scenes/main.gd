class_name Main
extends Node

onready var anims: AnimationPlayer = $Transitions/AnimationPlayer
onready var active_scene = $ActiveScene


func _init():
	Game.init(self)


func _ready():
	anims.stop()
	anims.play("fade-from-black")
