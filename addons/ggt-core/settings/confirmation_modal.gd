extends Control
class_name ConfirmationModal

signal confirmed
signal cancelled

@export var label: Label
@export var confirm_button: Button
@export var cancel_button: Button

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	hide()


func show_with_text(text: String) -> void:
	label.text = text
	show()
	confirm_button.grab_focus()


func _on_confirm_pressed() -> void:
	confirmed.emit()
	hide()


func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide()
