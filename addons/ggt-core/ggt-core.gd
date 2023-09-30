@tool
extends EditorPlugin


func _enter_tree():
	pass


func _enable_plugin():
	add_autoload_singleton("Game", "res://addons/ggt-core/game.gd")
	add_autoload_singleton("Transitions", "res://addons/ggt-core/transitions/transitions.tscn")
	add_autoload_singleton("Scenes", "res://addons/ggt-core/scenes/scenes.gd")
	add_autoload_singleton("Utils", "res://addons/ggt-core/utils/utils.gd")


func _exit_tree():
	pass


func _disable_plugin():
	remove_autoload_singleton("Game")
	remove_autoload_singleton("Transitions")
	remove_autoload_singleton("Scenes")
	remove_autoload_singleton("Utils")
