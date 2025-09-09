extends Node

# --- resources / config ---
var card_config = preload("res://config/card_config.gd").new()
var card_scene = preload("res://scenes/components/card.tscn")

# --- state ---
var deck: Array = []         # remaining cards to draw
var hand_nodes: Array = []   # references to card nodes currently in hand layout
var max_cards: int = 0
var initial_hand_size: int = 4
var last_active_card = null

func _ready() -> void:
	# Build the deck (store plain data + preloaded texture if available)
	var starter_deck = card_config.get_starter_deck("basic")
	Globals.CURRENT_BAYANIHAN_SPIRIT = Globals.MAX_BAYANIHAN_SPIRIT
	$CanvasLayer/Control/BayanihanSpirit/Spirit.text = str(Globals.CURRENT_BAYANIHAN_SPIRIT)
	
	for cardset in starter_deck:
		var card_def = card_config.get_card(cardset["cardId"])
		for _i in range(cardset["quantity"]):
			var data := {
				"name": card_def.name,
				"id": card_def.id,
				"description": card_def.description,
				"type": card_def.type,
				"cost": card_def.cost,
				"effect": card_def.effect,
				"flavorText": card_def.flavorText,
				"art": null
			}
			# try to load art (silently keep null if missing)
			if card_def.art != null and str(card_def.art) != "":
				var image_path: String = "res://assets/sprites/cards/" + str(card_def.art)
				var tex: Resource = load(image_path)
				if tex is Texture2D:
					data.art = tex
				else:
					push_warning("Could not load texture: " + image_path)
			deck.append(data)
	max_cards = deck.size()
	deck.shuffle() # optional shuffle
	# update UI deck counter
	$CanvasLayer/Control/Deck/DeckCount.text = str(deck.size())

func _process(_delta: float) -> void:
	# keep deck counter up to date
	$CanvasLayer/Control/Deck/DeckCount.text = str(deck.size())

func _on_timer_timeout() -> void:
	if hand_nodes.size() < initial_hand_size:
		add_card()

func add_card() -> void:
	if deck.size() == 0:
		print("No cards left in deck.")
		$CanvasLayer/Timer.stop()
		return
	# pop the top card data from the deck
	var card_data = deck[0]
	deck.remove_at(0)
	# instantiate the visible card and copy data
	var new_card = card_scene.instantiate()
	new_card.title = card_data.name
	new_card.cardId = card_data.id
	new_card.description = card_data.description
	new_card.type = card_data.type
	new_card.cost = card_data.cost
	new_card.effect = card_data.effect
	new_card.flavorText = card_data.flavorText
	new_card.pivot_offset = Vector2(0, 20)
	if card_data.art:
		new_card.art = card_data.art
	# add to hand
	var hand_layout: Control = $CanvasLayer/Control/GCardHandLayout
	hand_layout.add_child(new_card)
	new_card.visible = true
	new_card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	new_card.set_deferred("size", Vector2(400, 650))
	hand_nodes.append(new_card)

func _on_deck_pressed() -> void:
	if hand_nodes.size() < initial_hand_size:
		$CanvasLayer/Timer.start()
	elif deck.size() > 0:
		add_card()
	else:
		print("No more cards to draw.")

func remove_card(card_node: Node) -> void:
	var hand_layout: Node = $CanvasLayer/Control/GCardHandLayout
	var root_card = _get_card_root_in_hand(card_node, hand_layout)
	if root_card == null:
		push_warning("Card node not found in hand layout.")
		return
	if is_instance_valid(root_card) and root_card.get_parent() == hand_layout:
		var idx = hand_nodes.find(root_card)
		last_active_card = card_node.cardId
		if idx != -1:
			hand_nodes.remove_at(idx)
		hand_layout.remove_child(root_card)
		root_card.queue_free()
		# ✅ Do NOT draw another card here — player must press the deck
	else:
		push_warning("Card node not found in hand layout.")

# helper: given any descendant node, return the node that is a direct child of hand_layout (or null)
func _get_card_root_in_hand(node: Node, hand_layout: Node) -> Node:
	var cur := node
	while cur:
		if cur.get_parent() == hand_layout:
			return cur
		cur = cur.get_parent()
	return null

func _on_g_card_hand_layout_card_dragging_finished(card, index) -> void:
	# Make sure we find the root card node that is an actual child of the hand layout
	var hand_layout: Node = $CanvasLayer/Control/GCardHandLayout
	var root_card := _get_card_root_in_hand(card, hand_layout)
	if root_card == null:
		push_warning("Dragged card not recognized.")
		return
	Globals.ACTIVE_CARD = root_card
	print("Active card set to: ", Globals.ACTIVE_CARD)
	# Detect drop inside the drop box
	var drop_box: Control = $CanvasLayer/Control/CardDropBox
	var mouse_pos: Vector2 = drop_box.get_local_mouse_position()
	var drop_box_rect = Rect2(Vector2.ZERO, drop_box.size)
	if drop_box_rect.has_point(mouse_pos):
		print("Card dropped inside the drop box!")
		var display = $CanvasLayer/Control/CardDropBox/PanelContainer/ActiveCard
		if display:
			display.texture = Globals.ACTIVE_CARD.art
		# consume the card
		remove_card(root_card)
		# consume a spirit based on the cost of the card.
		if Globals.CURRENT_BAYANIHAN_SPIRIT >= Globals.ACTIVE_CARD.cost:
			Globals.CURRENT_BAYANIHAN_SPIRIT -= Globals.ACTIVE_CARD.cost
			$CanvasLayer/Control/BayanihanSpirit/Spirit.text = str(Globals.CURRENT_BAYANIHAN_SPIRIT)
		else:
			print("Not enough Bayanihan Spirit to play this card.")
	else:
		print("Card dropped outside the drop box.")
	Globals.ACTIVE_CARD = null

func _on_active_card_gui_input(event):
	# Check if the event is a left mouse button press
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if there is an active card (i.e., a card was recently removed)
		if last_active_card != null:
			# Re-add the card to the hand
			add_card_from_data(last_active_card) # Use the stored card ID
			print("Pressed")
			# Clear the active card reference
			Globals.ACTIVE_CARD = null
			# Optionally, clear the display in the drop box
			var display = $CanvasLayer/Control/CardDropBox/PanelContainer/ActiveCard
			if display:
				display.texture = null
			# Restore Bayanihan Spirit (for simplicity, restore full cost)
			var card_def = card_config.get_card(last_active_card)
			if card_def and Globals.CURRENT_BAYANIHAN_SPIRIT + card_def.cost <= Globals.MAX_BAYANIHAN_SPIRIT:
				Globals.CURRENT_BAYANIHAN_SPIRIT += card_def.cost
				$CanvasLayer/Control/BayanihanSpirit/Spirit.text = str(Globals.CURRENT_BAYANIHAN_SPIRIT)
			else:
				print("Cannot restore Bayanihan Spirit beyond max limit.")
			last_active_card = null

# Helper function to re-add a card from its data
func add_card_from_data(card_id: String) -> void:
	# Look up the card definition from config using the card_id
	var card_def = card_config.get_card(card_id)
	if card_def.is_empty():
		push_warning("Card definition not found for id: " + str(card_id))
		return

	# Build the card data dictionary (including art)
	var card_data := {
		"name": card_def.name,
		"id": card_def.id,
		"description": card_def.description,
		"type": card_def.type,
		"cost": card_def.cost,
		"effect": card_def.effect,
		"flavorText": card_def.flavorText,
		"art": null
	}
	if card_def.art != null and str(card_def.art) != "":
		var image_path: String = "res://assets/sprites/cards/" + str(card_def.art)
		var tex: Resource = load(image_path)
		if tex is Texture2D:
			card_data.art = tex

	# Instantiate the visible card and copy data
	var new_card = card_scene.instantiate()
	new_card.title = card_data.name
	new_card.cardId = card_data.id
	new_card.description = card_data.description
	new_card.type = card_data.type
	new_card.cost = card_data.cost
	new_card.effect = card_data.effect
	new_card.flavorText = card_data.flavorText
	new_card.pivot_offset = Vector2(0, 20)
	if card_data.art:
		new_card.art = card_data.art

	# Add to hand
	var hand_layout: Control = $CanvasLayer/Control/GCardHandLayout
	hand_layout.add_child(new_card)
	new_card.visible = true
	new_card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	new_card.set_deferred("size", Vector2(400, 650))
	hand_nodes.append(new_card)
