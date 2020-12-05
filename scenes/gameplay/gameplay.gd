extends Node2D


func pre_start(params):
	print("")
	print("pre_start called with params = ")
	for key in params:
		var val = params[key]
		printt("", key, val)


func start():
	# Tree is un-paused when this function is called
	print("")
	print("Start game logic!")
