extends Node

# --- Core Player Stats & Systems (from GDD) ---
var MAX_RESILIENCE := 30 # Example starting/max value, to be balanced
var MAX_BAYANIHAN_SPIRIT := 10
var STARTING_HAND_SIZE := 5
var EXHAUSTION_PENALTY := 2 # Resilience lost per undrawn card

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
