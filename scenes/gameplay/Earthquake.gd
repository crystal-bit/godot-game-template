extends AnimatedSprite2D
@onready var animated_sprite = $"."

func _process(delta):
	# Only ensure an idle animation if nothing is currently playing.
	# This prevents overriding other animations like "attack" triggered by gameplay.gd.
	if not animated_sprite.is_playing():
		animated_sprite.play("idle")
