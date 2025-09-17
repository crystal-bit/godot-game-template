# **Game Design Document: Bayanihan Spire**

**Version: 1.9** **Last Updated: September 9, 2025**

### **1\. Core Concept**

**1.1. Game Concept** Bayanihan Spire is a 2D pixel-art roguelike card game where players strategically use Aksyon, Tulong, Kaalaman, and Gabay cards to help a community survive a series of escalating Philippine disasters. The "Spire" isn't a physical building but the community itself—a living entity composed of people, homes, and a shared spirit. The goal is to protect this collective spirit from falling apart.

**1.2. Genre & Audience**

* **Genre:** Roguelike Card Game, Strategy, Community-Building, Narrative-Driven.  
* **Target Audience:** Casual to mid-core gamers, ages 10-45, who enjoy deep strategic games with unique cultural themes. The game is designed with a "mobile-first" philosophy and will be localized for both English and Hiligaynon-speaking audiences.

**1.3. Design Pillars**

1. **Meaningful Decisions:** Every card play is a critical choice with lasting consequences, reinforcing the theme of "irretrievable opportunities."  
2. **Strategic Empathy:** Players should feel clever and empowered by anticipating telegraphed problems and using their knowledge to protect the community.  
3. **Accessible Depth:** The core loop is easy to understand, but the interplay between cards and Threat Modifiers provides deep strategic engagement.

   ### **2\. Core Gameplay Loop**

**2.1. The "Day" Structure** The game progresses in a turn-based structure called "Days." A full disaster encounter is an "Event" that lasts for a set number of Days.

1. **Player Phase:**  
   * The player draws cards up to their hand size. (See 3.2 Exhaustion).  
   * The player's **Bayanihan Spirit** (energy) is recharged to its maximum.  
   * The Threat **telegraphs its Intent**, showing an icon that clearly communicates its planned action(s).  
   * The player can either spend Spirit to play cards or take the **"Rest & Regroup"** action.  
2. **Threat Phase:**  
   * The player signals the end of their turn (or the Rest action is taken).  
   * The Threat executes its telegraphed action.  
   * The Survival Timer ticks down by one, and a new Day begins.

**2.2. Win & Lose Conditions**

* **Win Condition:** The player wins an Event by successfully surviving until the **Survival Timer** reaches zero.  
* **Lose Condition:** The player loses if the community's **Resilience** drops to zero. Upon losing, the current **run** ends, and all run-specific progress (the deck built during the run, map position) is lost.

  ### **3\. Player Systems & Progression**

**3.1. Core Player Mechanics**

* **Resilience:** The community's collective health. The starting and maximum values will be determined during balancing. If it reaches 0, the game is lost.  
* **Bayanihan Spirit:** The energy used to play cards. The player has a maximum of 10, which is recharged at the start of each Day.  
* **Card Type Roles:**  
  * **Tulong (Green \- The Shield):** Reactive defense; restoring Resilience or Blocking damage.  
  * **Aksyon (Blue \- The Toolkit):** Proactive problem-solving; removing debuffs or deck pollution.  
  * **Kaalaman (Yellow \- The Mind):** Strategy and manipulation; drawing cards, seeing future Intents.  
  * **Gabay (Red \- The Heartbeat):** High-cost, high-impact, tide-turning effects.

**3.2. Card System & Deck Integrity** This system is the strategic heart of the game, built on the principle that cards are a finite, precious resource.

* **The Draw Pile:** Where the player's available cards are stored.  
* **The Used Pile:** When a card is played or discarded, it is sent to the **Used Pile**. These cards are considered spent and are **not** automatically shuffled back into the Draw Pile.  
* **The "Rest & Regroup" Action:** A core strategic action where the player chooses to **skip their turn** (playing no cards). At the end of the Threat Phase, all cards from the "Used Pile" are shuffled back into the player's "Draw Pile."  
* **The "Exhaustion" Mechanic:** The penalty for running out of cards. At the start of the Player Phase, for each card the player is unable to draw, their community's **Resilience is immediately reduced** by a set amount (e.g., 2 Resilience per card).

**3.3. The Roguelike Deckbuilding Model**

* **The Starting Deck:** Every new run begins with a small, predefined deck of 8-10 basic cards.  
* **The Global Card Pool:** The permanent collection of all cards the player has unlocked. This pool is **never lost**.  
* **In-Run Deckbuilding:** During a run, players adapt their deck by adding new cards offered randomly from their Global Card Pool. This deck exists **for the current run only**.

**3.4. Meta-Progression: The Living Community** After defeating a Boss, the player earns **Remnants**. Remnants are spent to visually rebuild community structures, which in turn unlocks new gameplay options and deepens the narrative.

* **Rescuing Specialists:** Rebuilding a location also "rescues" a community specialist who provides a new service.  
  * **Example:** Rebuilding the destroyed forge **rescues the Blacksmith**. The Blacksmith then appears at the new Workshop, unlocking the ability to upgrade cards.  
  * **Example:** Rebuilding the Clinic **rescues the Doctor**, which adds a new set of powerful healing cards to the **Global Card Pool**.

  ### **4\. World & Game Structure**

**4.1. World Map & Strategic Choice** Players progress through a linear series of disaster regions on a world map. After clearing a region, the map may present branching paths, allowing the player to **scout** the next Threat type and adapt their strategy.

**4.2. Threat Modifiers & Replayability** To ensure long-term strategic variety, the game uses a modular "Modifier" system. A run may have one or more randomly selected **Modifiers**—run-wide environmental effects that alter the strategic landscape.

* **Thematic Naming:** The Modifier's name and visual icon change based on the active Threat to ensure narrative consistency. For example, the "Random Discard" mechanic is called **"High Winds"** during a Typhoon, but **"Sudden Tremor"** during an Earthquake.

  ### **5\. User Interface & Player Experience**

**5.1. The Resilience Bar** The primary UI element is the **Unified Resilience Bar**.

* **The "Balay sa Sulod" Gem:** On the far left, a glowing gem containing an illustration of community houses serves as the anchor.  
* **The Beam of Light:** The health bar itself is a beam of light emanating from the gem.  
* **Numerical Readout:** A small, stylized **plaque** integrated below the gem displays the precise numerical value of Resilience.

**5.2. Player Experience & Onboarding** A mandatory, guided "Practice Drill" event will introduce core systems sequentially to new players.

* **Drill 1: The Basics:** Teaches Resilience, Spirit, and playing basic **Tulong** cards to gain Block against a simple telegraphed attack.  
* **Drill 2: Proactive Solutions:** The Threat introduces junk "Hazard" cards (e.g., "Rubble"). The player learns about deck pollution and is guided to use an **Aksyon** card to solve it.  
* **Drill 3: The Core Choice:** The player's deck is intentionally depleted. They are guided into a situation where they must use the **"Rest & Regroup"** action to avoid the **Exhaustion** mechanic, learning the game's most crucial strategic decision.  
	
	
  Version Update Tracker:  
  **GDD Version 0.6.0**

This was the first major revision of the day, where we integrated the critical feedback from the "experienced developer" analysis. The goal was to address potential high-level weaknesses in the design.

* **Added "Player Agency & Mitigation" (Section 2.3):** We moved the design beyond a simple "have the right card or fail" system by introducing the concepts of partial success and strategic trade-offs.  
* **Made the Metagame Tangible (Section 3.2):** We evolved the "Community Hub" from an abstract menu into a visual, narrative-driven space where players rescue specialists (like the Blacksmith and Doctor) to unlock upgrades.  
* **Added "Player Experience & Onboarding" (Section 4.4):** We created a plan for a mandatory "Practice Drill" event to teach new players core mechanics sequentially, making the game more accessible.

  ### **GDD Version 1.6**

This version focused on formally implementing the "Threat Modifier" system, which was a key part of the feedback, and consolidating the document.

* **Integrated "Threat Modifiers & Replayability" (Section 4.3):** This system was officially added to the GDD as the primary method for ensuring long-term replayability and content scalability. It defines how random environmental effects can combine with main threats to create unique challenges in every run.  
* **Document Consolidation:** Cleaned up duplicated sections and improved the overall flow and readability of the document.

  ### **GDD Version 1.7 (Current Version)**

This update was crucial for clarifying and committing to the roguelike deckbuilding model based on your questions. The goal was to eliminate any ambiguity about how a "run" works.

* **Defined "Consequence of Losing" (Section 2.2):** We explicitly stated that losing a run means losing the deck built during that run and the player's position on the map.  
* **Clarified the Roguelike Model (Section 3.2):** This new section clearly defines the difference between the temporary, **run-specific deck** and the player's permanent **Global Card Pool**, explaining how players start each run with a basic deck and build it up from their collection. This solidifies the game as a true roguelike deckbuilder.
