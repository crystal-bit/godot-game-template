extends Node2D


func pre_start(params):
	print("\npre_start called with params = ")
	for key in params:
		var val = params[key]
		printt("", key, val)


func start():
	print("\nStart game logic!")
