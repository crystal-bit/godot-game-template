@tool
extends EditorPlugin


# this will be loaded only on the first plugin activation. If you want to
# change the KEYS than use Project -> Project Settings -> Input Map
const default_debug_shortcuts = {
	"input/debug_restart_game": KEY_R,
	"input/debug_pause_game": KEY_P,
	"input/debug_quit_game": KEY_Q
}


func _enter_tree():
	if OS.is_debug_build():
		register_input_mappings(func(): save_project_settings())


func _enable_plugin():
	if OS.is_debug_build():
		add_autoload_singleton("DebugShortcuts", "res://addons/ggt-debug-shortcuts/autoload/debug_shortcuts.tscn")
		register_input_mappings(func(): save_project_settings())


func _exit_tree():
	pass


func _disable_plugin():
	remove_autoload_singleton("DebugShortcuts")
	unregister_input_mappings()
	save_project_settings()


func save_project_settings():
	var error = ProjectSettings.save()
	if error:
		push_error(error)


func create_input_action(keycode: Key):
	var trigger = InputEventKey.new()
	trigger.keycode = keycode
	return {
		"deadzone": 0.5,
		"events": [trigger]
	}


func register_input_mappings(on_project_settings_changed: Callable):
	var dirty = false
	for k in default_debug_shortcuts:
		var v = default_debug_shortcuts[k]
		if ProjectSettings.has_setting(k):
#			push_warning("{0} shortcut already set in ProjectSettings, skipping...".format([k]))
			pass # leave user configured action
		else:
			dirty = true
			ProjectSettings.set_setting(k, create_input_action(v)) # set default value
	if dirty:
		if on_project_settings_changed is Callable:
			print("saving projsettings")
			on_project_settings_changed.call()


func unregister_input_mappings():
	for k in default_debug_shortcuts:
		ProjectSettings.set_setting(k, null)
