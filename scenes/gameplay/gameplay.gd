extends Node2D


func pre_start(params):
	print_debug("Gameplay started with params = ")

	for key in params:
		var val = params[key]
		print(key, ": ", val)


func start():
	print("Start game logic!")
