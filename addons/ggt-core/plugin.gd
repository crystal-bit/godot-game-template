@tool
extends EditorPlugin


func _enter_tree():
	pass


func _enable_plugin():
	add_autoload_singleton("GGT", "res://addons/ggt-core/ggt.gd")
	add_autoload_singleton("GGT_GameConfig", "res://addons/ggt-core/autoload/game_settings_config.gd")


func _exit_tree():
	pass


func _disable_plugin():
	remove_autoload_singleton("GGT")
	remove_autoload_singleton("GGT_GameConfig")
