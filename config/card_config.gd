extends Node
@export_enum("aksyon", "gabay", "kaalaman", "tulong", "rubble") var type: int
# Card configuration data
var config = {
	"cardLibrary": [
		{
			"id": "collective-effort",
			"name": "Collective Effort",
			"type": 0,
			"cost": 4,
			"description": "Gain 5 Block. For the rest of this Day, all Block you gain is increased by 50%",
			"effect": {
				"block": 2
			},
			"flavorText": "Sama-samang pagkilos, mas malakas na epekto.",
			"art": "collective-effort.png"
		},
		{
			"id": "divine-shield",
			"name": "Divine Shield",
			"type": 3,
			"cost": 5,
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
			"type": 0,
			"cost": 3,
			"description": "The Threat's telegraphed damage is delayed. It will be added to its attack next Day.",
			"effect": {
				"damageDelay": 1
			},
			"flavorText": "",
			"art": "evacuation-order.png"
		},
		{
			"id": "people-resolve",
			"name": "People's Resolve",
			"type": 1,
			"cost": 10,
			"description": "Exhaust. Gain an extra Day. On that Day, you have 15 Spirit and draw 7 cards.",
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
			"type": 3,
			"cost": 4,
			"description": "Resilience gen is immune to damage for 1 turn.",
			"effect": {
				"reinforced": 1
			},
			"flavorText": "",
			"art": "sagip-bahay.png"
		},
		{
			"id": "clear-debris",
			"name": "Clear Debris",
			"type": 3,
			"cost": 4,
			"description": "Resilience gem is immune to damage for 1 turn.",
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
			"type": 4,
			"cost": 1,
			"description": "Hazard. A useless card that clogs your deck. Some threats punish you for holding Rubble.",
			"effect": {
				"hazard": 1
			},
			"flavorText": "Mga guho ng lindol, sagabal sa pagbangon.",
			"art": ""
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
		},
		{
			"id": "bayanihan-power",
			"name": "Bayanihan Power",
			"type": 1,
			"cost": 6,
			"description": "Gain 30 Block. All other cards in your hand cost 0 for the rest of the Day.",
			"effect": {
				"block": 30,
				"setHandCostToZero": true
			},
			"flavorText": "Lakas ng bayan, walang kapantay.",
			"art": "bayanihan-power.PNG"
		},
		{
			"id": "clear-debris",
			"name": "Clear Debris",
			"type": 0,
			"cost": 3,
			"description": "Exhaust. Remove all \"Hazard\" cards from your hand.",
			"effect": {
				"exhaust": true,
				"removeHazards": true
			},
			"flavorText": "Linisin ang daan para sa mas mabilis na pagtugon.",
			"art": "clear-debris.PNG"
		},
		{
			"id": "community-meeting",
			"name": "Community Meeting",
			"type": 2,
			"cost": 2,
			"description": "Draw 3 cards.",
			"effect": {
				"draw": 3
			},
			"flavorText": "Pulong-bayan para sa mas magandang bukas.",
			"art": "community-meeting.png"
		},
		{
			"id": "diy-barricade",
			"name": "DIY Barricade",
			"type": 3,
			"cost": 2,
			"description": "Gain 6 Block for this Day.",
			"effect": {
				"block": 6
			},
			"flavorText": "Mula sa mga bagay na walang halaga, nagkakaroon ng depensa.",
			"art": "diy-baricade.PNG"
		},
		{
			"id": "first-aid",
			"name": "First Aid",
			"type": 3,
			"cost": 2,
			"description": "Restore 4 Resilience.",
			"effect": {
				"heal": 4
			},
			"flavorText": "Agad na lunas sa sugat ng bayan.",
			"art": "first-aid.PNG"
		},
		{
			"id": "foresight",
			"name": "Foresight",
			"type": 2,
			"cost": 3,
			"description": "See the Threat's telegraphed Intent for the next Day. Draw 1 card.",
			"effect": {
				"revealIntent": true,
				"draw": 1
			},
			"flavorText": "Ang paghahanda ay susi sa tagumpay.",
			"art": "fore-sight.png"
		},
		{
			"id": "grit",
			"name": "Grit",
			"type": 2,
			"cost": 4,
			"description": "Choose a card in your hand. It costs 0 Spirit for the rest of this Day.",
			"effect": {
				"makeCardCostZero": 1
			},
			"flavorText": "Tibay ng loob sa harap ng pagsubok.",
			"art": "grit.PNG"
		},
		{
			"id": "heroic-stand",
			"name": "Heroic Stand",
			"type": 1,
			"cost": 3,
			"description": "Gain Block equal to your missing Resilience.",
			"effect": {
				"blockEqualMissingHealth": true
			},
			"flavorText": "Hindi ako susuko hangga't may natitira pang lakas.",
			"art": "heroic-stand.PNG"
		},
		{
			"id": "iron-will",
			"name": "Iron Will",
			"type": 3,
			"cost": 2,
			"description": "Gain 11 Block for this Day.",
			"effect": {
				"block": 11
			},
			"flavorText": "Tibay ng loob sa gitna ng unos.",
			"art": "iron-will.PNG"
		},
		{
			"id": "pagasa-report",
			"name": "PAGASA Report",
			"type": 2,
			"cost": 1,
			"description": "Gain 5 Block. Reveal a random telegraphed Intent from the Threat's ability pool for the next Day.",
			"effect": {
				"block": 5,
				"revealRandomIntent": true
			},
			"flavorText": "Handa sa anumang panahon.",
			"art": "pagasa-report.png"
		},
		{
			"id": "scry",
			"name": "Scry",
			"type": 2,
			"cost": 0,
			"description": "Look at the top 3 cards of your Draw Pile. Put one back on top, one in the Used Pile, and one on the bottom.",
			"effect": {
				"scry": 3
			},
			"flavorText": "Tingnan ang hinaharap, pumili ng daan.",
			"art": "scry.PNG"
		},
		{
			"id": "stockpile",
			"name": "Stockpile",
			"type": 2,
			"cost": 2,
			"description": "Draw 2 cards. Move 1 card from your hand to the Used Pile.",
			"effect": {
				"draw": 2,
				"discardFromHand": 1
			},
			"flavorText": "Handa sa anumang oras.",
			"art": "stockpile.PNG"
		},
		{
			"id": "street-smart",
			"name": "Street Smart",
			"type": 0,
			"cost": 1,
			"description": "The next card you play this Day costs 1 less Spirit.",
			"effect": {
				"reduceNextCardCost": 1
			},
			"flavorText": "Diskarte sa bawat sulok.",
			"art": "street-smart.PNG"
		},
		{
			"id": "teamwork",
			"name": "Teamwork",
			"type": 0,
			"cost": 2,
			"description": "If you have played 2 or more cards this Day, draw 2 cards.",
			"effect": {
				"draw": 2,
				"requiresCardsPlayed": 2
			},
			"flavorText": "Sama-sama, kaya natin 'to!",
			"art": "teamwork.PNG"
		},
		{
			"id": "utang-na-loob",
			"name": "Utang na Loob",
			"type": 0,
			"cost": 1,
			"description": "Gain 10 Block now. At the start of your next Day, lose 5 Resilience.",
			"effect": {
				"block": 10,
				"delayedDamage": {
					"amount": 5,
					"turns": 1
				}
			},
			"flavorText": "Ang utang na loob ay hindi napapalitan ng salapi.",
			"art": "utang-na-loob.PNG"
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
