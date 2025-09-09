extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	print(data)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
