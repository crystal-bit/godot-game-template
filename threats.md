# **Bayanihan Spire: Threat Dossier**

**Version: 1.0** **Compatibility:** GDD Version 1.9

**Purpose:** This document is the master list for all Threat abilities and Modifiers. It serves as the primary resource for encounter design, balancing, and AI programming.

### **Part 1: The Threat Modifier System**

A Modifier is a run-wide passive effect that layers on top of a primary Threat. Its name and visual icon change based on the active Threat to ensure thematic integrity.

| Core Mechanic | vs. Mr. Earthquake | vs. Typhoon Yoling | vs. Volcanic Eruption |
| ----- | ----- | ----- | ----- |
| **Random Discard** | **Sudden Tremor** | **High Winds** | **Blinding Ash** |
| **Block Reduction** | **Unstable Ground** | **Soaking Rain** | **Corrosive Fumes** |
| **Deck Pollution** | **Falling Debris** | **Rising Floodwater** | **Falling Embers** |
| **Heal Reduction** | **Cut Supply Lines** | **Contamination** | **Noxious Gas** |
| **Spirit Drain** | **Panic** | **Exhaustion** | **Suffocation** |

### **Part 2: Threat Dossier**

Threats have a streamlined set of skills that represent their core identity. The strategic complexity comes from their interaction with the Modifier system.

#### **2.1 Mr. Earthquake (Disruptor & Punisher)**

* **Signature Mechanic:** Polluting the player's deck with "Rubble" (a Hazard card) and punishing them for it.  
* **Skills:**  
  * `Tremor` (Setup): Adds 2 "Rubble" cards to the player's Used Pile.  
  * `Aftershock` (Payoff): Deals 5 damage for each "Rubble" card in the player's possession (Hand, Draw Pile, Used Pile).  
  * `Magnitude 7` (Burst): Deals a large, single instance of damage (e.g., 20 damage).

#### **2.2 Typhoon Yoling (Warden of Attrition)**

* **Signature Mechanic:** Applying persistent, stacking damage-over-time via the "Battered" status.  
* **Skills:**  
  * `Howling Winds` (Setup): Applies 2 stacks of "Battered" (At the start of your Day, take 1 Resilience damage per stack).  
  * `Flash Flood` (Payoff): Deals 4 damage for each stack of "Battered" the player has.  
  * `Storm Surge` (Burst): Deals a large, single instance of damage (e.g., 15 damage).

#### **2.3 The Volcanic Eruption (Escalating Juggernaut)**

* **Signature Mechanic:** Becoming exponentially more dangerous over time.  
* **Skills:**  
  * `Lava Flow` (Escalating): Deals 6 damage. This damage is permanently increased by 2 every time this action is used during this Event.  
  * `Ashfall` (Pollution): Adds 1 "Soot" (a Hazard card) to the player's Draw Pile. "Soot" cannot be Exhausted.  
  * `Pyroclastic Cloud` (Burst): Deals medium damage (e.g., 10 damage) and adds 2 "Soot" cards to the Used Pile.

