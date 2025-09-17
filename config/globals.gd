extends Node

# --- Core Player Stats & Systems (from GDD) ---
var MAX_RESILIENCE := 20 # Example starting/max value, to be balanced
var MAX_BAYANIHAN_SPIRIT := 10
var STARTING_HAND_SIZE := 5
var EXHAUSTION_PENALTY := 2 # Resilience lost per undrawn card
var ACTIVE_CARD: Variant # Currently played card
var CURRENT_BAYANIHAN_SPIRIT := MAX_BAYANIHAN_SPIRIT

# --- Card Effect Tracking ---
var cards_played_this_turn: int = 0
var next_card_cost_reduction: int = 0
var hand_cost_set_to_zero: bool = false
var revealed_intent: String = ""
var scry_cards: Array = []
var delayed_damage: Dictionary = {
	"amount": 0,
	"turns_remaining": 0
}

# Reset turn-based effects (call at start of player turn)
func reset_turn_effects() -> void:
	cards_played_this_turn = 0
	next_card_cost_reduction = 0
	hand_cost_set_to_zero = false
	# Don't reset revealed_intent here - it persists until used
	
# Reset all effects (for new game/restart)
func reset_all_effects() -> void:
	reset_turn_effects()
	revealed_intent = ""
	scry_cards = []
	delayed_damage = {"amount": 0, "turns_remaining": 0}

# Handle end of turn updates
func end_turn_updates() -> void:
	# Process delayed damage
	if delayed_damage.turns_remaining > 0:
		delayed_damage.turns_remaining -= 1
		if delayed_damage.turns_remaining <= 0 and delayed_damage.amount > 0:
			# Apply delayed damage - this would be called from the game loop
			# after checking turns_remaining
			pass
	
	# Clear turn-based effects
	reset_turn_effects()

# --- Deck System (from GDD) ---
var STARTING_DECK_SIZE := 8 # To be balanced
var GLOBAL_CARD_POOL := [] # Populated as player unlocks cards

# --- Meta-Progression: Specialists (from GDD) ---
var SPECIALISTS = {
	"blacksmith": {
		"name": "Blacksmith",
		"unlocked": false,
		"service": "Upgrade cards"
	},
	"doctor": {
		"name": "Doctor",
		"unlocked": false,
		"service": "Adds powerful healing cards to Global Card Pool"
	}
}

# --- Threat Modifiers (from GDD) ---
var THREAT_MODIFIERS = {
	"random_discard": {
		"default_name": "Random Discard",
		"icons": {
			"typhoon": "wind",
			"earthquake": "quake",
			"volcano": "ash"
		},
		"names": {
			"typhoon": "High Winds",
			"earthquake": "Sudden Tremor",
			"volcano": "Blinding Ash"
		}
	},
	"deck_pollution": {
		"default_name": "Deck Pollution",
		"icons": {
			"typhoon": "flood",
			"earthquake": "debris",
			"volcano": "ember"
		},
		"names": {
			"typhoon": "Rising Floodwater",
			"earthquake": "Falling Debris",
			"volcano": "Falling Embers"
		}
	}
	# Add more modifiers as needed
}

# --- UI: Resilience Bar (from GDD) ---
var RESILIENCE_BAR_CONFIG = {
	"gem_icon": "balay_sa_sulod_gem",
	"beam_color": "light",
	"plaque_style": "stylized"
}

# --- Practice Drill Sequence (from GDD) ---
var PRACTICE_DRILLS = [
	{
		"id": 1,
		"title": "The Basics",
		"teaches": ["Resilience", "Spirit", "Tulong cards", "Block"]
	},
	{
		"id": 2,
		"title": "Proactive Solutions",
		"teaches": ["Hazard cards", "Deck pollution", "Aksyon cards"]
	},
	{
		"id": 3,
		"title": "The Core Choice",
		"teaches": ["Rest & Regroup", "Exhaustion mechanic"]
	}
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
