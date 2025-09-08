@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

func _add_layout_nodes():
	add_custom_type("GCardHandLayout", "Control", preload("res://addons/godot_card_layout/layouts/hand_layout/gcard_hand_layout.gd"), preload("res://addons/godot_card_layout/resources/icons/hand_layout_icon.svg"))
