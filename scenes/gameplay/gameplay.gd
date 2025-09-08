extends Node

# Preload textures at compile time
const CARD_TEXTURES = {
	"card1": preload("res://assets/sprites/cards/Collective Effort.png"),
	"card2": preload("res://assets/sprites/cards/Divine Shield.png"),
	"card3": preload("res://assets/sprites/cards/Evacuation Order.png"),
	"card4": preload("res://assets/sprites/cards/People Resolve.png"),
	"card5": preload("res://assets/sprites/cards/Sagip-Bahay.png")
}

var cards_list = []
var card:TextureRect
var max_cards = 5
var current_cards = 0

func _ready() -> void:
	# Initialize cards list with preloaded textures
	for i in range(1, 6):
		cards_list.append({
			"name": "card" + str(i),
			"texture": CARD_TEXTURES["card" + str(i)]
		})

	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	if GGT.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await GGT.change_finished

	print("GGT/Gameplay: scene transition animation finished")


func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if current_cards < max_cards:
		add_card()

func add_card() -> void:
	if current_cards >= max_cards:
		print("Maximum number of cards reached!")
		$Timer.stop()
		return
	
	# Create a new TextureRect for the card
	var new_card = TextureRect.new()
	
	# Set card properties
	new_card.name = "Card_" + str(current_cards + 1)
	new_card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_card.custom_minimum_size = Vector2(205.0, 330.0)
	new_card.pivot_offset = Vector2(80.0, 0.0)
	
	# Set the preloaded texture
	new_card.texture = cards_list[current_cards % cards_list.size()]["texture"]
	
	# Add the card to the scene
	$Control/GCardHandLayout.add_child(new_card)
	
	# Position the card (you might want to adjust this based on your layout needs)
	new_card.position = Vector2(100 + (current_cards * 50), 100)
	
	# Increment the card counter
	current_cards += 1


func _on_deck_pressed() -> void:
	$Timer.start()
