@tool
extends EditorPlugin

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("autoload/DebugMenu"):
		add_autoload_singleton("DebugMenu", "res://addons/debug_menu/debug_menu.tscn")

	if not ProjectSettings.has_setting("application/config/version") or ProjectSettings.get_setting("application/config/version") == "":
		ProjectSettings.set_setting("application/config/version", "1.0.0")
		print('Debug Menu: Setting "application/config/version" was missing or empty and has been set to "1.0.0".')

	ProjectSettings.add_property_info({
		name = "application/config/version",
		type = TYPE_STRING,
	})

	ProjectSettings.save()

	# Add new Project Setting for font_size
	if not ProjectSettings.has_setting("DebugMenu/settings/font_size"):
		ProjectSettings.set_setting("DebugMenu/settings/font_size", 12)

	var property_info = {
		"name": "DebugMenu/settings/font_size",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string" : "3,72"
	}
	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value("DebugMenu/settings/font_size", 12)
	ProjectSettings.save()

# Add new Project Setting for startup visibility
	if not ProjectSettings.has_setting("DebugMenu/settings/startup_visibility"):
		ProjectSettings.set_setting("DebugMenu/settings/startup_visibility", 0)

	property_info = {
		"name": "DebugMenu/settings/startup_visibility",
		"type": TYPE_INT ,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string" : "hidden,visible compact,visible detailed"
	}
	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value("DebugMenu/settings/startup_visibility", 0)
	ProjectSettings.save()

func _exit_tree() -> void:
	remove_autoload_singleton("DebugMenu")
	# Don't remove the project setting's value and input map action,
	# as the plugin may be re-enabled in the future.
