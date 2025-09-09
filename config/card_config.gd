extends Node
@export_enum("aksyon", "gabay", "kaalaman") var type: int
# Card configuration data
var config = {
	"cardLibrary": [
		{
			"id": "collective-effort",
			"name": "Collective Effort",
			"type": 0,
			"cost": 1,
			"description": "All of your cards played this turn that target threats have their effects doubled against the chosen threat.",
			"effect": {
				"boost": 2
			},
			"flavorText": "Sama-samang pagkilos, mas malakas na epekto.",
			"art": "collective-effort.png"
		},
		{
			"id": "divine-shield",
			"name": "Divine Shield",
			"type": 1,
			"cost": 1,
			"description": "The community's resilience gem cannot drop below 1 for the next turn.",
			"effect": {
				"protected": 1
			},
			"flavorText": "",
			"art": "divine-shield.png"
		},
		{
			"id": "evacuation-order",
			"name": "Evacuation Order",
			"type": 1,
			"cost": 1,
			"description": "Postpones incoming threat damage by 1 for the next turn.",
			"effect": {
				"damageDelay": 1
			},
			"flavorText": "",
			"art": "evacuation-order.png"
		},
		{
			"id": "people-resolve",
			"name": "People Resolve",
			"type": 2,
			"cost": 1,
			"description": "Gain an additional action this turn. All cards cost 0 Bayanihan Spirit.",
			"effect": {
				"addTurn": 1,
				"handCost": 0
			},
			"flavorText": "",
			"art": "people-resolve.png"
		},
		{
			"id": "sagip-bahay",
			"name": "Sagip Bahay",
			"type": 1,
			"cost": 1,
			"description": "Gives the resilience gem a reinforced state for the next turn, making it immune to damage for 1 turn.",
			"effect": {
				"reinforced": 1
			},
			"flavorText": "",
			"art": "sagip-bahay.png"
		},
		# Threat Hazards (from GDD)
		{
			"id": "rubble",
			"name": "Rubble",
			"type": 0,
			"cost": 0,
			"description": "Hazard. A useless card that clogs your deck. Some threats punish you for holding Rubble.",
			"effect": {
				"hazard": 1
			},
			"flavorText": "Mga guho ng lindol, sagabal sa pagbangon.",
			"art": "rubble.png"
		},
		{
			"id": "soot",
			"name": "Soot",
			"type": 0,
			"cost": 0,
			"description": "Hazard. Cannot be exhausted. Clogs your deck.",
			"effect": {
				"hazard": 1,
				"cannotExhaust": 1
			},
			"flavorText": "Abo ng bulkan, di matanggal-tanggal.",
			"art": "soot.png"
		}
	],
	"starterDecks": {
		"basic": [
			{ "cardId": "collective-effort", "quantity": 2 },
			{ "cardId": "divine-shield", "quantity": 1 },
			{ "cardId": "people-resolve", "quantity": 2 },
			{ "cardId": "evacuation-order", "quantity": 1 },
			{ "cardId": "sagip-bahay", "quantity": 1 }
		],
		"defensive": [
			{ "cardId": "divine-shield", "quantity": 2 },
			{ "cardId": "evacuation-order", "quantity": 2 },
			{ "cardId": "sagip-bahay", "quantity": 2 },
			{ "cardId": "collective-effort", "quantity": 1 }
		],
		"tactical": [
			{ "cardId": "collective-effort", "quantity": 2 },
			{ "cardId": "people-resolve", "quantity": 2 },
			{ "cardId": "evacuation-order", "quantity": 2 },
			{ "cardId": "divine-shield", "quantity": 1 }
		]
	},
	"cardEffects": {
		"damage": {
			"description": "Reduces disaster health",
			"icon": "zap",
			"color": "red"
		},
		"block": {
			"description": "Prevents incoming damage",
			"icon": "shield",
			"color": "blue"
		},
		"heal": {
			"description": "Restores player health",
			"icon": "heart",
			"color": "green"
		},
		"energy": {
			"description": "Provides additional Bayanihan Spirit this turn",
			"icon": "zap",
			"color": "yellow"
		},
		"draw": {
			"description": "Draw additional cards",
			"icon": "plus",
			"color": "purple"
		},
		"permanentBlock": {
			"description": "Block that persists between turns",
			"icon": "shield",
			"color": "cyan"
		},
		"boost": {
			"description": "Increases damage dealt by the card",
			"icon": "zap",
			"color": "yellow"
		},
		"protected": {
			"description": "Prevents incoming damage",
			"icon": "shield",
			"color": "blue"
		},
		"reinforced": {
			"description": "Gives the resilience gem a reinforced state for the next turn, making it immune to damage for 1 turn.",
			"icon": "shield",
			"color": "blue"
		},
		"addTurn": {
			"description": "Gives the player an additional action this turn.",
			"icon": "plus",
			"color": "purple"
		},
		"handCost": {
			"description": "Reduces the cost of playing a card from Bayanihan Spirit to 0.",
			"icon": "zap",
			"color": "yellow"
		},
		"damageDelay": {
			"description": "Postpones incoming threat damage by 1 for the next turn.",
			"icon": "clock",
			"color": "purple"
		},
		"hazard": {
			"description": "A useless card that clogs your deck. Some threats punish you for holding Hazards.",
			"icon": "skull",
			"color": "gray"
		},
		"cannotExhaust": {
			"description": "This card cannot be exhausted or removed from your deck during the event.",
			"icon": "lock",
			"color": "gray"
		}
	},
	"cardTypeConfig": {
		"tulong": {
			"color": "green",
			"icon": "shield",
			"description": "Reactive defense; restoring Resilience or Blocking damage."
		},
		"aksyon": {
			"color": "blue",
			"icon": "toolkit",
			"description": "Proactive problem-solving; removing debuffs or deck pollution."
		},
		"kaalaman": {
			"color": "yellow",
			"icon": "mind",
			"description": "Strategy and manipulation; drawing cards, seeing future Intents."
		},
		"gabay": {
			"color": "red",
			"icon": "heartbeat",
			"description": "High-cost, high-impact, tide-turning effects."
		}
	}
}

# Get a card by its ID
func get_card(card_id: String) -> Dictionary:
	for card in config.cardLibrary:
		if card.id == card_id:
			return card.duplicate()
	return {}

# Get all cards of a specific type
func get_cards_by_type(card_type: String) -> Array:
	var result = []
	for card in config.cardLibrary:
		if card.type == card_type:
			result.append(card.duplicate())
	return result

# Get a starter deck by name
func get_starter_deck(deck_name: String) -> Array:
	if deck_name in config.starterDecks:
		return config.starterDecks[deck_name].duplicate()
	return []

# Get effect configuration
func get_effect_config(effect_name: String) -> Dictionary:
	if effect_name in config.cardEffects:
		return config.cardEffects[effect_name].duplicate()
	return {}

# Get card type configuration
func get_card_type_config(type_name: String) -> Dictionary:
	if type_name in config.cardTypeConfig:
		return config.cardTypeConfig[type_name].duplicate()
	return {}
