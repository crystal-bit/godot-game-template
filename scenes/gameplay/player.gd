extends KinematicBody2D

export(float, 100, 1000, 0.5) var h_speed = 2000 # max speed
export(float, 1, 100, 0.5) var gravity = 15
export(float, 200, 1000, 0.5) var jump_speed = 800

var velocity = Vector2()

# state variables
var input_vec = Vector2()
var powerup = false


func _ready():
	pass


func _physics_process(delta):
	handle_input()
	velocity = calculate_velocity(input_vec, velocity)
	velocity = move_and_slide(velocity, Vector2.UP)


func handle_input():
	if Input.is_action_pressed("ui_right"):
		input_vec.x = 1
	elif Input.is_action_pressed("ui_left"):
		input_vec.x = -1
	else:
		input_vec.x = 0
	if Input.is_action_pressed("ui_up"):
		input_vec.y = -1
	else:
		input_vec.y = 0


func calculate_velocity(input: Vector2, prev_vel):
	# x axis
	if input.x != 0:
		# accelerattion
		prev_vel.x =lerp(prev_vel.x, h_speed * input.x, 0.6)
	else:
		# deceleration
		prev_vel.x =lerp(prev_vel.x, h_speed * input.x, 0.15)
	# y axis
	if is_on_floor():
		prev_vel.y = 0
		if input.y == -1:
			prev_vel.y = -jump_speed
	else:
		# is jumping/falling
		var modified_gravity = gravity
		if prev_vel.y > 0:
			modified_gravity *= 2
		prev_vel.y += modified_gravity * 2
	return prev_vel
