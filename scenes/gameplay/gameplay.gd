extends Node
var card_config = preload("res://config/card_config.gd").new()
var card_scene = preload("res://scenes/components/card.tscn")
var cards_list = []
var current_cards = 0
var max_cards = 0  # Will be set in _ready()
var initial_hand_size = 4



func _ready() -> void:
	
	# Load deck and set max_cards
	var deck = card_config.get_starter_deck("basic")
	
	var collection = []

	for cardset in deck:
		for _i in range(cardset["quantity"]):
			collection.append(card_config.get_card(cardset["cardId"]))
	
	max_cards = collection.size()
	
	# Initialize cards list
	for i in range(max_cards):
		var card_instance = card_scene.instantiate()
		card_instance.title = collection[i].name
		card_instance.cardId =  collection[i].id
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

	var card_index = current_cards % cards_list.size()
	var card_data = cards_list[card_index]
	var new_card = card_scene.instantiate()

	# Set card properties
	new_card.title = card_data.title
	new_card.cardId = card_data.cardId
	new_card.description = card_data.description
	new_card.type = card_data.type
	new_card.cost = card_data.cost
	new_card.effect = card_data.effect
	new_card.flavorText = card_data.flavorText
	new_card.pivot_offset = Vector2(0, 20)
	new_card.art = card_data.art

	$CanvasLayer/Control/GCardHandLayout.add_child(new_card)
	new_card.visible = true

	# Fix anchors and set size deferred to avoid override
	new_card.anchor_left = 0
	new_card.anchor_right = 0
	new_card.anchor_top = 0
	new_card.anchor_bottom = 0
	new_card.set_deferred("size", Vector2(400, 650))

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
	if is_instance_valid(card_node) and card_node.get_parent() == hand_layout:
		hand_layout.remove_child(card_node)
		card_node.queue_free()
		current_cards = max(0, current_cards - 1)
	else:
		push_warning("Card node not found in hand layout.")


func _on_g_card_hand_layout_card_dragging_finished(card, index):
	Globals.ACTIVE_CARD = card
	print("Active card set to: ", Globals.ACTIVE_CARD)
	print("Card mouse position: ", card.get_local_mouse_position())
	# check if the card mouse position is inside the $CanvasLayer/Control/CardDropBox
	var drop_box = $CanvasLayer/Control/CardDropBox
	var mouse_pos = get_viewport().get_mouse_position() - drop_box.global_position
	var drop_box_rect = Rect2(Vector2.ZERO, drop_box.get_size())
	if drop_box_rect.has_point(mouse_pos):
		print("Card dropped inside the drop box!")
		$CanvasLayer/Control/CardDropBox/PanelContainer/ActiveCard.texture = Globals.ACTIVE_CARD.art
		# Here you can add logic to handle the card being played
		remove_card(card)
	else:
		print("Card dropped outside the drop box.")
	# Reset ACTIVE_CARD after handling
	Globals.ACTIVE_CARD = null
