@tool
extends EditorPlugin


func _enter_tree():
	pass


func _enable_plugin():
	add_autoload_singleton("GGT", "res://addons/ggt-core/ggt.gd")


func _exit_tree():
	pass


func _disable_plugin():
	remove_autoload_singleton("GGT")
