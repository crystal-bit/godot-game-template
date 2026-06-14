extends Control

const CONFIG_FILE_PATH = GGT_GameConfig.CONFIG_FILE_PATH

signal cancel_button_clicked
signal confirm_button_clicked

const FPS_MAX_HARD_CAP = 400

@export var sound_master_slider: HSlider
@export var sound_sfx_slider: HSlider
@export var sound_music_slider: HSlider
@export var resolution_scale_slider: HSlider
@export var resolution_scale_value: Label
@export var v_sync_checkbox: CheckButton
@export var fps_limit_enabled_checkbox: CheckButton
@export var fps_limit_2: HBoxContainer
@export var fps_limit_slider: HSlider
@export var fps_limit_label: Label
@export var fullscreen_checkbox: CheckButton
@export var locale_option_button: OptionButton
@export var reset_confirmation_dialog: ConfirmationModal
@export var cancel_confirmation_dialog: ConfirmationModal
@export var cancel_button: Button

enum AudioBus {
	MASTER,
	SFX,
	BGM
}

var previous_config: ConfigFile


func _ready() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_LOCALE
	sound_master_slider.value_changed.connect(on_sound_master_slider)
	sound_sfx_slider.value_changed.connect(on_sound_sfx_slider)
	sound_music_slider.value_changed.connect(on_sound_music_slider)
	resolution_scale_slider.value_changed.connect(on_resolution_scale_slider)
	v_sync_checkbox.toggled.connect(on_vsync_toggled)
	fps_limit_enabled_checkbox.toggled.connect(on_fps_limit_enabled_checkbox)
	fps_limit_slider.value_changed.connect(on_fps_limit_slider)
	fullscreen_checkbox.toggled.connect(on_fullscreen_checkbox)
	locale_option_button.item_selected.connect(on_locale_option_button_item_selected)
	reset_confirmation_dialog.confirmed.connect(_on_reset_confirmed)
	cancel_confirmation_dialog.confirmed.connect(_on_cancel_confirmed)

	sound_master_slider.value_changed.connect(_on_setting_changed)
	sound_sfx_slider.value_changed.connect(_on_setting_changed)
	sound_music_slider.value_changed.connect(_on_setting_changed)
	resolution_scale_slider.value_changed.connect(_on_setting_changed)
	v_sync_checkbox.toggled.connect(_on_setting_changed)
	fps_limit_enabled_checkbox.toggled.connect(_on_setting_changed)
	fps_limit_slider.value_changed.connect(_on_setting_changed)
	fullscreen_checkbox.toggled.connect(_on_setting_changed)
	locale_option_button.item_selected.connect(_on_setting_changed)

	initialize()

	for control in get_tree().get_nodes_in_group("settings_desktop_only"):
		control.visible = OS.has_feature('pc')

	visibility_changed.connect(on_visibility_changed)


func _on_setting_changed(_v = null) -> void:
	cancel_button.disabled = false



func on_visibility_changed() -> void:
	if is_visible_in_tree():
		previous_config = ConfigFile.new()
		previous_config.parse(GGT_GameConfig.config.encode_to_text())
		cancel_button.disabled = true
	else:
		previous_config = null


func initialize(cfg: ConfigFile = GGT_GameConfig.config):
	sound_master_slider.value = cfg.get_value("audio", "master")
	sound_sfx_slider.value = cfg.get_value("audio", "sfx")
	sound_music_slider.value = cfg.get_value("audio", "music")
	resolution_scale_slider.value = cfg.get_value("gfx", "resolution_scale")
	v_sync_checkbox.button_pressed = cfg.get_value("gfx", "vsync")
	fps_limit_enabled_checkbox.button_pressed = cfg.get_value("gfx", "fps_limit_enabled")
	fps_limit_slider.value = cfg.get_value("gfx", "fps_limit")
	Engine.max_fps = cfg.get_value("gfx", "fps_limit")
	fullscreen_checkbox.button_pressed = cfg.get_value("gfx", "fullscreen")

	# locale
	locale_option_button.clear()
	var locales = GGT_GameConfig.SUPPORTED_LOCALES
	for locale_code in locales:
		locale_option_button.add_item(locales[locale_code])
		locale_option_button.set_item_metadata(locale_option_button.get_item_count() - 1, locale_code)
	var current_locale = cfg.get_value("game", "locale", "en")
	for i in range(locale_option_button.get_item_count()):
		if locale_option_button.get_item_metadata(i) == current_locale:
			locale_option_button.selected = i
			locale_option_button.item_selected.emit(i) # let the callback update the language
			break


func on_sound_master_slider(value: float):
	AudioServer.set_bus_volume_db(AudioBus.MASTER, value)


func on_sound_sfx_slider(value: float):
	AudioServer.set_bus_volume_db(AudioBus.SFX, value)


func on_sound_music_slider(value: float):
	AudioServer.set_bus_volume_db(AudioBus.BGM, value)


func on_resolution_scale_slider(value: float):
	GGT_GameConfig.set_resolution_scale(value)
	resolution_scale_value.text = str(value)


# TODO: add support for other 2 kinds of vsync?
func on_vsync_toggled(value: bool):
	# TODO: check what happens on monitor change?
	var window_id = get_window().get_window_id()
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED,
		window_id
	)


func on_fps_limit_enabled_checkbox(value: bool):
	fps_limit_2.visible = value
	if value:
		Engine.max_fps = int(fps_limit_slider.value)
	else:
		Engine.max_fps = FPS_MAX_HARD_CAP


func on_fps_limit_slider(value: float):
	if fps_limit_enabled_checkbox.button_pressed:
		Engine.max_fps = int(value)
	fps_limit_label.text = str(int(value))


func on_fullscreen_checkbox(value: bool) -> void:
	get_window().mode = Window.MODE_FULLSCREEN if value else Window.MODE_WINDOWED


func on_locale_option_button_item_selected(index: int) -> void:
	var locale_code = locale_option_button.get_item_metadata(index)
	TranslationServer.set_locale(locale_code)


func _on_settings_cancel_button_pressed() -> void:
	cancel_confirmation_dialog.show_with_text(tr("Are you sure you want to discard your changes?", "settings"))


func _on_cancel_confirmed() -> void:
	if previous_config:
		initialize(previous_config)
	else:
		initialize()
	cancel_button_clicked.emit()


func _on_settings_confirm_button_pressed() -> void:
	var config: ConfigFile = GGT_GameConfig.config
	config.set_value("audio", "master", sound_master_slider.value)
	config.set_value("audio", "sfx", sound_sfx_slider.value)
	config.set_value("audio", "music", sound_music_slider.value)
	config.set_value("gfx", "resolution_scale", resolution_scale_slider.value)
	config.set_value("gfx", "fps_limit_enabled", fps_limit_enabled_checkbox.button_pressed)
	config.set_value("gfx", "fps_limit", fps_limit_slider.value)
	if not OS.has_feature('web'):
		config.set_value("gfx", "fullscreen", fullscreen_checkbox.button_pressed)
		config.set_value("gfx", "vsync", v_sync_checkbox.button_pressed)

	var locale_code = locale_option_button.get_item_metadata(locale_option_button.selected)
	config.set_value("game", "locale", locale_code)

	config.save(CONFIG_FILE_PATH)
	confirm_button_clicked.emit()


func _on_settings_reset_button_pressed() -> void:
	reset_confirmation_dialog.show_with_text(tr("Are you sure you want to reset all settings to their default values?", "settings"))


func _on_reset_confirmed() -> void:
	GGT_GameConfig.reset()
	initialize(GGT_GameConfig.config)
	cancel_button.disabled = false
