extends Node

# --- resources / config ---
var card_config = preload("res://config/card_config.gd").new()
var card_scene = preload("res://scenes/components/card.tscn")

# --- state ---
var deck: Array = []         # remaining cards to draw
var hand_nodes: Array = []   # references to card nodes currently in hand layout
var used_pile: Array = []    # played/discarded cards (no node, just code)
var max_cards: int = 0
var initial_hand_size: int = 4
var last_active_card = null
var current_turn_phase: String = "player"  # or "threat"
var turn_count: int = 0
var is_resting: bool = false
var deck_exhausted: bool = false
var current_resilience: int = Globals.MAX_RESILIENCE
var earthquake_setup_done: bool = false
var days_left: int = 7

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
	
	update_resilience_display(current_resilience)
	deck_exhausted = deck.size() == 0
	# Connect button signals
	$CanvasLayer/Control/ButtonEndDay.connect("pressed", Callable(self, "_on_end_turn_button_pressed"))
	$CanvasLayer/Control/ButtonPass.connect("pressed", Callable(self, "_on_rest_regroup_button_pressed"))
	start_player_turn()

	if $CanvasLayer/Control.has_node("DaysLeftLabel"):
		$CanvasLayer/Control/DaysLeftLabel.text = "Days Left: " + str(days_left)

func _process(_delta: float) -> void:
	# keep deck counter up to date
	$CanvasLayer/Control/Deck/DeckCount.text = str(deck.size())
	if last_active_card != null:
		var effect = card_config.get_card(last_active_card)["effect"]
		print(effect)
		
	

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
		# Add to used pile before removing (except Rubble cards)
		if root_card.cardId != "rubble":
			var card_data = {
				"name": root_card.title,
				"id": root_card.cardId,
				"description": root_card.description,
				"type": root_card.type,
				"cost": root_card.cost,
				"effect": root_card.effect,
				"flavorText": root_card.flavorText,
				"art": root_card.art
			}
			used_pile.append(card_data)
		var idx = hand_nodes.find(root_card)
		last_active_card = card_node.cardId
		if idx != -1:
			hand_nodes.remove_at(idx)
		hand_layout.remove_child(root_card)
		root_card.queue_free()
		# Do NOT draw another card here — player must press the deck
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

func process_card_effects(card) -> void:
	if not card or not card.effect:
		return
	
	var effect = card.effect
	Globals.cards_played_this_turn += 1
	
	# Handle block effects
	if effect.has("block"):
		if effect.get("blockEqualMissingHealth"):
			var missing_health = Globals.MAX_RESILIENCE - current_resilience
			if missing_health > 0:
				current_resilience = min(Globals.MAX_RESILIENCE, current_resilience + missing_health)
				update_resilience_display(current_resilience)
		else:
			current_resilience = min(Globals.MAX_RESILIENCE, current_resilience + effect.block)
			update_resilience_display(current_resilience)
	
	# Handle healing
	if effect.has("heal"):
		current_resilience = min(Globals.MAX_RESILIENCE, current_resilience + effect.heal)
		update_resilience_display(current_resilience)
	
	# Handle card draw
	if effect.has("draw"):
		var can_draw = true
		if effect.has("requiresCardsPlayed"):
			can_draw = (Globals.cards_played_this_turn >= effect.requiresCardsPlayed)
		if can_draw:
			draw_cards(effect.draw)
	
	# Handle hazard removal
	if effect.has("removeHazards"):
		remove_all_rubble_and_reset_setup()
	
	# Handle exhaust (deal 2 damage to player)
	if effect.has("exhaust"):
		apply_damage(2, "Exhaust")
	
	# Handle reveal intent
	if effect.has("revealIntent"):
		# This would show the exact next threat action
		Globals.revealed_intent = "Next threat action revealed"
		print(Globals.revealed_intent)
	
	if effect.has("revealRandomIntent"):
		# This would show a random possible threat action
		Globals.revealed_intent = "Random threat intent revealed"
		print(Globals.revealed_intent)
	
	# Handle scry effect
	if effect.has("scry"):
		# Store cards for scry UI to display
		var num_to_scry = min(effect.scry, deck.size())
		if num_to_scry > 0:
			Globals.scry_cards = deck.slice(0, num_to_scry)
			# Show scry UI - this would be implemented in your UI system
			print("Scrying ", num_to_scry, " cards: ", Globals.scry_cards.map(func(c): return c.name))
	
	# Handle cost modifications
	if effect.has("reduceNextCardCost"):
		Globals.next_card_cost_reduction = effect.reduceNextCardCost
		print("Next card cost reduced by ", Globals.next_card_cost_reduction)
	
	if effect.has("setHandCostToZero"):
		Globals.hand_cost_set_to_zero = true
		print("All cards in hand now cost 0 for this turn")
	
	if effect.has("makeCardCostZero"):
		# This would trigger a card selection UI
		print("Select a card to make cost 0 for this turn")
		# card_selection_ui.show_for_zero_cost_selection()
	
	# Handle delayed damage (e.g., Utang na Loob)
	if effect.has("delayedDamage"):
		var dmg = effect.delayedDamage
		# Accept both 'turns' (from config) and 'turns_remaining' (internal format)
		var turns_val = 0
		if dmg.has("turns_remaining"):
			turns_val = int(dmg.turns_remaining)
		elif dmg.has("turns"):
			turns_val = int(dmg.turns)
		Globals.delayed_damage = {
			"amount": int(dmg.amount),
			"turns_remaining": max(0, turns_val)
		}
		print("%d damage will be applied in %d turns" % [dmg.amount, dmg.turns_remaining])
	
	# Handle addTurn (extra day)
	if effect.has("addTurn"):
		# This would add an extra day to the remaining days
		days_left += 1
		if $CanvasLayer/Control.has_node("DaysLeftLabel"):
			$CanvasLayer/Control/DaysLeftLabel.text = "Days Left: " + str(days_left)
		print("Gained an extra day!")

func get_effective_card_cost(card) -> int:
	var cost = card.cost
	# Apply cost reductions
	cost = max(0, cost - Globals.next_card_cost_reduction)
	# If hand cost is set to zero, all cards cost 0
	if Globals.hand_cost_set_to_zero:
		cost = 0
	return cost

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
		
		# Calculate effective cost after all modifiers
		var effective_cost = get_effective_card_cost(Globals.ACTIVE_CARD)
		
		# Check if player can afford the card
		if Globals.CURRENT_BAYANIHAN_SPIRIT >= effective_cost:
			# Process card effects first
			process_card_effects(Globals.ACTIVE_CARD)
			# Then consume the card and spirit
			remove_card(root_card)
			Globals.CURRENT_BAYANIHAN_SPIRIT -= effective_cost
			$CanvasLayer/Control/BayanihanSpirit/Spirit.text = str(Globals.CURRENT_BAYANIHAN_SPIRIT)
			
			# Reset next card cost reduction after use
			if Globals.next_card_cost_reduction > 0:
				Globals.next_card_cost_reduction = 0
				print("Cost reduction reset")
		else:
			print("Not enough Bayanihan Spirit to play this card (cost: %d, have: %d)" % [effective_cost, Globals.CURRENT_BAYANIHAN_SPIRIT])
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



func update_resilience_display(val: int) -> void:
	# Clamp to valid range to avoid UI glitches
	var clamped := clampi(val, 0, Globals.MAX_RESILIENCE)
	# Keep AnimatedSprite2D-based Resilience Bar in sync (compat with existing API)
	if has_node("CanvasLayer/Resilience Bar"):
		$"CanvasLayer/Resilience Bar".set_frame_and_progress(clamped, 10)
	# Update the text label to show the real, clamped value
	if has_node("CanvasLayer/Control/Resilience HP"):
		$"CanvasLayer/Control/Resilience HP".text = str(clamped)
	# Also update the TextureProgressBar if present for consistency
	if has_node("CanvasLayer/Control/Resilience Bar"):
		var bar = $"CanvasLayer/Control/Resilience Bar"
		if bar:
			bar.min_value = 0
			bar.max_value = Globals.MAX_RESILIENCE
			bar.value = clamped

func start_player_turn() -> void:
	current_turn_phase = "player"
	turn_count += 1
	is_resting = false
	Globals.CURRENT_BAYANIHAN_SPIRIT = Globals.MAX_BAYANIHAN_SPIRIT
	$CanvasLayer/Control/BayanihanSpirit/Spirit.text = str(Globals.CURRENT_BAYANIHAN_SPIRIT)
	
	# Reset turn-based effects
	Globals.reset_turn_effects()
	
	# Check for delayed damage
	if Globals.delayed_damage.turns_remaining > 0:
		Globals.delayed_damage.turns_remaining -= 1
		if Globals.delayed_damage.turns_remaining <= 0 and Globals.delayed_damage.amount > 0:
			apply_damage(Globals.delayed_damage.amount, "Delayed Effect")
			Globals.delayed_damage = {"amount": 0, "turns_remaining": 0}
	
	draw_cards(initial_hand_size - hand_nodes.size())
	$CanvasLayer/Control/ButtonEndDay.disabled = false
	$CanvasLayer/Control/ButtonPass.disabled = false
	update_ui()

func _on_end_turn_button_pressed() -> void:
	if current_turn_phase == "player":
		end_player_turn()

func end_player_turn() -> void:
	$CanvasLayer/Control/ButtonEndDay.disabled = true
	$CanvasLayer/Control/ButtonPass.disabled = true
	current_turn_phase = "threat"
	start_threat_phase()

func start_threat_phase() -> void:
	print("Starting threat phase")
	# Get the threat sprite
	var threat_sprite = $CanvasLayer/Earthquake/AnimatedSprite2D
	if threat_sprite:
		# Store the current animation to return to later
		var current_anim = threat_sprite.animation
		var current_frame = threat_sprite.frame
		
		# Play attack animation (0.1s per frame for 10 frames = 1s total)
		threat_sprite.play("attack")
		
		# Wait for attack animation to complete (10 frames * 0.1s per frame = 1s)
		await get_tree().create_timer(1.0).timeout
		
		# Return to previous animation
		threat_sprite.play(current_anim)
		threat_sprite.frame = current_frame
		
		# Apply threat effects after a short delay
		await get_tree().create_timer(0.5).timeout
		_apply_threat_effects()
	else:
		print("Warning: Threat sprite not found")

func _apply_threat_effects() -> void:
	# Apply damage to resilience
	var damage = 2  # Default damage, adjust based on your game's balance
	current_resilience = max(0, current_resilience - damage)
	update_resilience_display(current_resilience)
	print("Applied ", damage, " damage from threat")
	
	# Handle any additional threat actions
	if has_method("threat_action"):
		threat_action()
	
	# Update days left
	days_left -= 1
	if $CanvasLayer/Control.has_node("DaysLeftLabel"):
		$CanvasLayer/Control/DaysLeftLabel.text = "Days Left: " + str(days_left)
	
	# Clean up any threat effects
	if has_method("remove_earthquake_skill_effect"):
		remove_earthquake_skill_effect()
	
	# Start next turn if game isn't over
	if days_left > 0:
		# Small delay before starting next turn
		await get_tree().create_timer(1.0).timeout
		start_player_turn()
	else:
		# Handle game over condition
		print("Game Over - No days left")
		if has_method("game_over"):
			game_over()

func _on_rest_regroup_button_pressed() -> void:
	if current_turn_phase == "player":
		if used_pile.size() == 0:
			return
		deck = used_pile.duplicate()
		deck.shuffle()
		used_pile.clear()
		deck_exhausted = false
		is_resting = true
		end_player_turn()

func draw_cards(count: int) -> void:
	for i in range(count):
		if deck.size() == 0:
			if used_pile.size() > 0 and not deck_exhausted:
				deck_exhausted = true
				return
			else:
				return
		add_card()

func threat_action() -> void:
	var skills = []
	if !earthquake_setup_done:
		skills = ["tremor", "magnitude7"]
	else:
		skills = ["tremor", "aftershock", "magnitude7"]
	var skill = skills[randi() % skills.size()]
	show_earthquake_skill_effect(skill)
	# Placeholder for animation
	print("Earthquake animation placeholder for skill: ", skill)
	match skill:
		"tremor":
			use_tremor()
			print("Earthquake uses Tremor!")
			earthquake_setup_done = true
		"aftershock":
			use_aftershock()
			print("Earthquake uses Aftershock!")
			earthquake_setup_done = false
		"magnitude7":
			use_magnitude7()
			print("Earthquake uses Magnitude 7!")

func use_tremor() -> void:
	for i in range(2):
		var rubble_card = {
			"name": "Rubble",
			"id": "rubble",
			"description": "Hazard. A useless card that clogs your deck. Costs 1 Bayanihan Spirit to play.",
			"type": 0,
			"cost": 1,
			"effect": {"hazard": 1},
			"flavorText": "Mga guho ng lindol, sagabal sa pagbangon.",
			"art": null
		}
		used_pile.append(rubble_card)

func use_aftershock() -> void:
	var rubble_count = 0
	for card in deck:
		if card.id == "rubble":
			rubble_count += 1
	for card in hand_nodes:
		if card.cardId == "rubble":
			rubble_count += 1
	for card in used_pile:
		if card.id == "rubble":
			rubble_count += 1
	var damage = rubble_count * 2
	apply_damage(damage, "Aftershock")

func use_magnitude7() -> void:
	apply_damage(10, "Magnitude 7")

func show_earthquake_skill_effect(skill: String) -> void:
	var eq = $CanvasLayer/Earthquake
	if eq.has_node("SkillEffect"): eq.get_node("SkillEffect").queue_free()
	var effect = ColorRect.new()
	effect.name = "SkillEffect"
	match skill:
		"tremor":
			effect.color = Color(1, 0.9, 0.2, 0.7) # yellow
		"aftershock":
			effect.color = Color(1, 0.2, 0.2, 0.7) # red
		"magnitude7":
			effect.color = Color(0.6, 0.2, 1, 0.7) # purple
		_:
			effect.color = Color(randf(), randf(), randf(), 0.7)
	effect.size = Vector2(32, 32)
	effect.position = Vector2(0, -48)
	eq.add_child(effect)

func remove_earthquake_skill_effect() -> void:
	var eq = $CanvasLayer/Earthquake
	if eq.has_node("SkillEffect"):
		eq.get_node("SkillEffect").queue_free()

# Hazard removal function (call this when a card removes all Rubble)
func remove_all_rubble_and_reset_setup() -> void:
	# Remove all Rubble from deck, hand, used_pile
	deck = deck.filter(func(card): return card.id != "rubble")
	for i in range(hand_nodes.size() - 1, -1, -1):
		var card = hand_nodes[i]
		if card.cardId == "rubble":
			var hand_layout = $CanvasLayer/Control/GCardHandLayout
			hand_layout.remove_child(card)
			hand_nodes.remove_at(i)
			card.queue_free()
	used_pile = used_pile.filter(func(card): return card.id != "rubble")
	earthquake_setup_done = false

func apply_damage(amount: int, source: String = "") -> void:
	if amount <= 0:
		return
	current_resilience = max(0, current_resilience - amount)
	update_resilience_display(current_resilience)
	if current_resilience <= 0:
		game_over()

func game_over() -> void:
	get_tree().paused = true

func update_ui() -> void:
	# Update button appearance for turn indication
	if current_turn_phase == "player":
		$CanvasLayer/Control/ButtonEndDay.modulate = Color(1,1,1)
	else:
		$CanvasLayer/Control/ButtonEndDay.modulate = Color(0.5,0.5,0.5)
