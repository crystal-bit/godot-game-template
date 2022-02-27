tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("Utils", "res://addons/game-template/utils.gd")
	add_autoload_singleton("Transitions", "res://addons/game-template/transition/transition.tscn")
	add_autoload_singleton("Game", "res://addons/game-template/game.gd")
#	if !ProjectSettings.has_setting("category/property_name"):
#		ProjectSettings.set("category/property_name", 0)
#	var property_info = {
#		"name": "category/property_name",
#		"type": TYPE_INT,
#		"hint": PROPERTY_HINT_ENUM,
#		"hint_string": "one,two,three"
#	}
#	ProjectSettings.add_property_info(property_info)
#

func _exit_tree():
	remove_autoload_singleton("Game")
	remove_autoload_singleton("Transitions")
	remove_autoload_singleton("Utils")
#	get_tree().root.get_node_or_null("Utils").queue_free()
