@tool
extends EditorPlugin


func _enter_tree():
	pass


func _enable_plugin():
	add_autoload_singleton("Utils", "res://addons/game-template/utils.gd")
	add_autoload_singleton("Transitions", "res://addons/game-template/transition/transition.tscn")
	add_autoload_singleton("Game", "res://addons/game-template/game.gd")


func _exit_tree():
	pass


func _disable_plugin():
	remove_autoload_singleton("Game")
	remove_autoload_singleton("Transitions")
	remove_autoload_singleton("Utils")
