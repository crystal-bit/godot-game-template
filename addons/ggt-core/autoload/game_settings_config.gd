## GGT_GameConfig autoload
extends Node

const CONFIG_FILE_PATH = &"user://settings.cfg"

var config = ConfigFile.new()

signal resolution_scale_changed

const SUPPORTED_LOCALES = {
	"en": "English",
	"it": "Italiano",
	#"ja": "日本語",
	#"zh": "简体中文",
	#"ar": "العربية",
	#"ru": "Русский",
}


func _ready() -> void:
	# load config file
	if FileAccess.file_exists(CONFIG_FILE_PATH):
		var err = config.load(CONFIG_FILE_PATH)
		if err != OK:
			reset()
			return
	else:
		reset()

	_apply_settings()


func reset() -> void:
	initialize_default_file()
	config.save(CONFIG_FILE_PATH)
	_apply_settings()


func initialize_default_file():
	config.set_value("audio", "master", 0.0)
	config.set_value("audio", "sfx", 0.0)
	config.set_value("audio", "music", 0.0)
	config.set_value("gfx", "resolution_scale", 1.0)
	config.set_value("gfx", "fps_limit_enabled", true)
	config.set_value("gfx", "fps_limit", 60)
	if not OS.has_feature('web'):
		config.set_value("gfx", "fullscreen", true)
		config.set_value("gfx", "vsync", true)

	var os_locale = OS.get_locale_language()
	if os_locale in SUPPORTED_LOCALES:
		config.set_value("game", "locale", os_locale)
	else:
		config.set_value("game", "locale", "en")


func _apply_settings() -> void:
	var locale = config.get_value("game", "locale", "en")
	TranslationServer.set_locale(locale)
	Engine.max_fps = config.get_value("gfx", "fps_limit", 60)

	# TODO: check what happens on monitor change?
	var window_id = get_window().get_window_id()
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if config.get_value("gfx", "vsync") else DisplayServer.VSYNC_DISABLED,
		window_id
	)


#region setters
func set_resolution_scale(v: float) -> void:
	config.set_value("gfx", "resolution_scale", v)
	get_tree().root.scaling_3d_scale = v
	#for vp: Viewport in get_tree().get_nodes_in_group("viewports"):
		#vp.scaling_3d_scale = value
	#DebugMenu.update_settings_label() # update debug view
	resolution_scale_changed.emit()


func set_locale(locale: String) -> void:
	config.set_value("game", "locale", locale)
	TranslationServer.set_locale(locale)
#endregion


#region getters

func get_resolution_scale() -> float:
	return float(config.get_value("gfx", "resolution_scale"))


func get_locale() -> String:
	return config.get_value("game", "locale", "en")
#endregion
