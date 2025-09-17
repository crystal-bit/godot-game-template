extends Control

var card_config = preload("res://config/card_config.gd").new()

@export var title: String = "Title Here"
@export var description: String = "Description Here"
@export_enum("aksyon", "gabay", "kaalaman", "tulong") var type: int
@export var cardId: String
@export var art: Texture2D
@export var background_aksyon: Texture2D
@export var background_gabay: Texture2D
@export var background_kaalaman: Texture2D
@export var background_tulong: Texture2D
@export var background_default: Texture2D
@export var cost: int
@export var effect: Dictionary
@export var flavorText: String

#func _get_drag_data(at_position) -> Dictionary:
	#var preview = TextureRect.new()
	#preview.texture = self.texture
	#set_drag_preview(preview)
	#return card_config.get_card(cardId)

func _ready() -> void:
	if type == 0:
		self.texture = background_aksyon
	elif type == 1:
		self.texture = background_gabay
	elif type == 2:
		self.texture = background_kaalaman
	elif type == 3:
		self.texture = background_tulong
	else:
		self.texture = background_default
	$MarginContainer/VBoxContainer/MarginContainer2/Title.text = title
	$MarginContainer/VBoxContainer/Art.texture = art
	$MarginContainer/VBoxContainer/MarginContainer/Description.text = description
	$Cost.text = str(cost)
