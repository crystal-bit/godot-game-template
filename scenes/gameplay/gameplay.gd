extends Node2D


func pre_start(params):
	print("")
	print("pre_start called with params = ")
	for key in params:
		var val = params[key]
		printt("", key, val)


func start():
	print("")
	print("Start game logic!")
