extends Control

@export var title: String = "Title Here"
@export var description: String = "Description Here"
@export_enum("aksyon", "gabay", "kaalaman") var type: String
@export var art: Texture2D
@export var background_aksyon: Texture2D
@export var background_gabay: Texture2D
@export var background_kaalaman: Texture2D
@export var background_default: Texture2D


func _ready() -> void:
	if type == "aksyon":
		$Background.texture = background_aksyon
	elif type == "gabay":
		$Background.texture = background_gabay
	elif type == "kaalaman":
		$Background.texture = background_kaalaman
	else:
		$Background.texture = background_default
	$Title.text = title
	$Art.texture = art
	$Description.text = description
