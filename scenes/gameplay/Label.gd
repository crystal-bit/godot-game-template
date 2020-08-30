extends Label

func _ready():
	rect_position.x = 300
	rect_position.y = 300

func _process(delta):
	text = str(get_node("../Player").h_speed)
