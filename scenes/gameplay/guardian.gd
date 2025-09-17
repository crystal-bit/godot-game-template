extends Node2D
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	animated_sprite.play("idle")
