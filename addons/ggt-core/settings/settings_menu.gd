extends Control

const CONFIG_FILE_PATH = GGT_GameConfig.CONFIG_FILE_PATH

signal cancel_button_clicked
signal confirm_button_clicked

@export var sound_master_slider: HSlider
@export var sound_sfx_slider: HSlider
@export var sound_music_slider: HSlider
@export var resolution_scale_slider: HSlider
@export var resolution_scale_value: Label
@export var v_sync_checkbox: CheckButton
@export var fps_limit_option_button: OptionButton
@export var fullscreen_checkbox: CheckButton
@export var locale_option_button: OptionButton
@export var reset_confirmation_dialog: ConfirmationModal
@export var cancel_confirmation_dialog: ConfirmationModal
@export var cancel_button: Button

const FPS_OPTIONS = [0, 30, 45, 60, 75, 90, 120, 144, 165, 240]

var previous_config: ConfigFile # null if no value changed since last visit to the settings page.
var _focus_before_modal: Control


func _ready() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_LOCALE
	sound_master_slider.value_changed.connect(on_sound_master_slider)
	sound_sfx_slider.value_changed.connect(on_sound_sfx_slider)
	sound_music_slider.value_changed.connect(on_sound_music_slider)
	resolution_scale_slider.value_changed.connect(on_resolution_scale_slider)
	v_sync_checkbox.toggled.connect(on_vsync_toggled)
	fps_limit_option_button.item_selected.connect(on_fps_limit_option_button_item_selected)
	fullscreen_checkbox.toggled.connect(on_fullscreen_checkbox)
	locale_option_button.item_selected.connect(on_locale_option_button_item_selected)
	reset_confirmation_dialog.confirmed.connect(_on_reset_confirmed)
	cancel_confirmation_dialog.confirmed.connect(_on_cancel_confirmed)
	reset_confirmation_dialog.cancelled.connect(_on_modal_canceled)
	cancel_confirmation_dialog.cancelled.connect(_on_modal_canceled)

	sound_master_slider.value_changed.connect(_on_setting_changed)
	sound_sfx_slider.value_changed.connect(_on_setting_changed)
	sound_music_slider.value_changed.connect(_on_setting_changed)
	resolution_scale_slider.value_changed.connect(_on_setting_changed)
	v_sync_checkbox.toggled.connect(_on_setting_changed)
	fps_limit_option_button.item_selected.connect(_on_setting_changed)
	fullscreen_checkbox.toggled.connect(_on_setting_changed)
	locale_option_button.item_selected.connect(_on_setting_changed)

	initialize()

	for control in get_tree().get_nodes_in_group("settings_desktop_only"):
		control.visible = OS.has_feature('pc')

	visibility_changed.connect(on_visibility_changed)


func _unhandled_input(event: InputEvent) -> void:
	if !visible: return
	if event is InputEventJoypadButton:
		if event.is_action_released("pause"):
			_on_settings_confirm_button_pressed()
			get_viewport().set_input_as_handled()
		elif event.is_action_released("ui_cancel"):
			if cancel_button.disabled:
				_on_settings_confirm_button_pressed() # just close the settings menu, no edits were made
			else:
				_on_settings_cancel_button_pressed() # asks confirmation before closing the settings menu


func _on_setting_changed(_v=null) -> void:
	cancel_button.disabled = false


func on_visibility_changed() -> void:
	if is_visible_in_tree():
		previous_config = ConfigFile.new()
		previous_config.parse(GGT_GameConfig.config.encode_to_text())
		cancel_button.disabled = true
		locale_option_button.grab_focus()
	else:
		previous_config = null


func initialize(cfg: ConfigFile = GGT_GameConfig.config) -> void:
	sound_master_slider.set_value_no_signal(cfg.get_value("audio", "master"))
	sound_sfx_slider.set_value_no_signal(cfg.get_value("audio", "sfx"))
	sound_music_slider.set_value_no_signal(cfg.get_value("audio", "music"))

	resolution_scale_slider.set_value_no_signal(cfg.get_value("gfx", "resolution_scale"))
	resolution_scale_value.text = str(resolution_scale_slider.value)

	v_sync_checkbox.set_pressed_no_signal(cfg.get_value("gfx", "vsync", true))

	fps_limit_option_button.clear()
	var current_fps_limit: int = cfg.get_value("gfx", "fps_limit", 60)
	for fps in FPS_OPTIONS:
		fps_limit_option_button.add_item("Disabled" if fps == 0 else str(fps))
		fps_limit_option_button.set_item_metadata(fps_limit_option_button.get_item_count() - 1, fps)
	for i in range(fps_limit_option_button.get_item_count()):
		if fps_limit_option_button.get_item_metadata(i) == current_fps_limit:
			fps_limit_option_button.select(i)
			break

	fullscreen_checkbox.set_pressed_no_signal(cfg.get_value("gfx", "fullscreen", true))

	# locale
	locale_option_button.clear()
	var locales = GGT_GameConfig.SUPPORTED_LOCALES
	for locale_code in locales:
		locale_option_button.add_item(locales[locale_code])
		locale_option_button.set_item_metadata(locale_option_button.get_item_count() - 1, locale_code)
	var current_locale = cfg.get_value("game", "locale", "en")
	for i in range(locale_option_button.get_item_count()):
		if locale_option_button.get_item_metadata(i) == current_locale:
			locale_option_button.select(i)
			break


func on_sound_master_slider(value: float) -> void:
	GGT_GameConfig.set_master_volume(value)


func on_sound_sfx_slider(value: float) -> void:
	GGT_GameConfig.set_sfx_volume(value)


func on_sound_music_slider(value: float) -> void:
	GGT_GameConfig.set_music_volume(value)


func on_resolution_scale_slider(value: float) -> void:
	GGT_GameConfig.set_resolution_scale(value)
	resolution_scale_value.text = str(value)


func on_vsync_toggled(value: bool) -> void:
	GGT_GameConfig.set_vsync(value)


func on_fps_limit_option_button_item_selected(index: int) -> void:
	GGT_GameConfig.set_fps_limit(fps_limit_option_button.get_item_metadata(index))


func on_fullscreen_checkbox(value: bool) -> void:
	GGT_GameConfig.set_fullscreen(value)


func on_locale_option_button_item_selected(index: int) -> void:
	var locale_code = locale_option_button.get_item_metadata(index)
	GGT_GameConfig.set_locale(locale_code)


func _on_settings_cancel_button_pressed() -> void:
	_focus_before_modal = get_viewport().gui_get_focus_owner()
	cancel_button_clicked.emit()
	cancel_confirmation_dialog.show_with_text(tr("Are you sure you want to discard your changes?", "settings"))


func _on_cancel_confirmed() -> void:
	if previous_config:
		GGT_GameConfig.revert_to(previous_config)
		initialize(previous_config)
	else:
		initialize()
	if _focus_before_modal:
		_focus_before_modal.grab_focus()


func _on_modal_canceled() -> void:
	if _focus_before_modal:
		_focus_before_modal.grab_focus()


func _on_settings_confirm_button_pressed() -> void:
	GGT_GameConfig.persist()
	confirm_button_clicked.emit()


func _on_settings_reset_button_pressed() -> void:
	_focus_before_modal = get_viewport().gui_get_focus_owner()
	reset_confirmation_dialog.show_with_text(tr("Are you sure you want to reset all settings to their default values?", "settings"))


func _on_reset_confirmed() -> void:
	GGT_GameConfig.reset()
	initialize(GGT_GameConfig.config)
	cancel_button.disabled = false
	if _focus_before_modal:
		_focus_before_modal.grab_focus()
