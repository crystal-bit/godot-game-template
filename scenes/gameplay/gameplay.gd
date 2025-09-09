extends Node
var card_config = preload("res://config/card_config.gd").new()
var card_scene = preload("res://scenes/components/card.tscn")
var cards_list = []
var current_cards = 0
var max_cards = 0  # Will be set in _ready()
var initial_hand_size = 2



func _ready() -> void:
	
	# Load deck and set max_cards
	var deck = card_config.get_starter_deck("basic")
	
	var collection = []	

	deck.map(func(cardset) -> void:
		for i in cardset["quantity"]:
			collection.append(card_config.get_card(cardset["cardId"]))
	)
	
	max_cards = collection.size()
	
	# Initialize cards list
	for i in range(max_cards):
		var card_instance = card_scene.instantiate()
		card_instance.title = collection[i].name
		card_instance.description = collection[i].description
		card_instance.type = collection[i].type
		card_instance.cost = collection[i].cost
		card_instance.effect = collection[i].effect
		card_instance.flavorText = collection[i].flavorText
		card_instance.size = Vector2(400, 650)
		card_instance.pivot_offset = Vector2(0, 20)
		
		# Try to load card art, use default if not found
		var image_path = "res://assets/sprites/cards/" + collection[i].art
		if ResourceLoader.exists(image_path):
			card_instance.art = load(image_path) as Texture2D
		else:
			push_warning("Image not found: " + image_path)
		
		cards_list.append(card_instance)

	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	if GGT.is_changing_scene(): # this will be false if starting the scene with "Run current scene" or F6 shortcut
		await GGT.change_finished

	print("GGT/Gameplay: scene transition animation finished")


func _process(_delta: float) -> void:
	$CanvasLayer/Control/Deck/DeckCount.text = str(max_cards - current_cards)


func _on_timer_timeout() -> void:
	if current_cards < initial_hand_size:
		add_card()

func add_card() -> void:
	if current_cards >= max_cards:
		print("Maximum number of cards reached!")
		$CanvasLayer/Timer.stop()
		return
		
	# Create a new card instance
	var card_index = current_cards % cards_list.size()
	var new_card = cards_list[card_index].duplicate()
	
	# Add the card to the scene
	$CanvasLayer/Control/GCardHandLayout.add_child(new_card)
	
	# Position will be handled by the layout
	new_card.visible = true
	
	# Increment the card counter
	current_cards += 1

func _on_deck_pressed() -> void:
	if current_cards < initial_hand_size:
		$CanvasLayer/Timer.start()
	elif current_cards < max_cards:
		add_card()
	else:
		print("No more cards to draw.")

func remove_card(card_node: Node) -> void:
	var hand_layout = $CanvasLayer/Control/GCardHandLayout
	if hand_layout.has_node(card_node.get_path()):
		hand_layout.remove_child(card_node)
		card_node.queue_free()
		current_cards = max(0, current_cards - 1)
	else:
		push_warning("Card node not found in hand layout.")
