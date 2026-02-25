# 🛠️ Semantic Slime: Technical & Gameplay Mechanics
## *Mechanical Overview: The Phoenix Project*

---

### 1. Framework & Architecture
The game is built using the **Knit** framework on Roblox, which enforces a clear separation between **Services** (Server-side logic) and **Controllers** (Client-side logic).

*   **Communication:** Services expose methods to Controllers via standard Knit middleware. Events (like word collection or XP gain) are handled through `RemoteEvents` organized in `ReplicatedStorage`.
*   **Data Persistence:** Integrated via `DataService` (using `ProfileService`) to track player stats (Insight, XP) and word inventories across sessions.

### 2. The Logos Engine (The "How" of Words)
Words (Etymons) are not static strings; they are objects generated dynamically by `LogosService`.

*   **Analysis:** When a word is "minted," the engine parses it against `EtymologyDB` (a shared module) to identify its **Root** and **Suffix**.
*   **Stats Generation:**
    *   **Root (Linguistic Element):** Determines the elemental type (Fire, Water, etc.) and primary stat focus (Attack/Defense).
    *   **Suffix (Morphological Role):** Determines the "class" or role (Tank, Striker, Support).
    *   **Formula:** Stats = `(Base + RootBonus + SuffixBonus) * LevelMultiplier`.
*   **Evolution:** At Level 10, players can spend "Insight" (currency) to evolve an Etymon, resetting its level but applying a permanent stage multiplier (1.5x, 2.0x, etc.) and prepending titles (e.g., "Greater", "Ascended").

### 3. Procedural World Generation
`TownGenerator` reads a `TownBlueprint` to construct the world at runtime.

*   **The Urban Mandala:** The map is divided into 4 quadrants (Districts).
*   **Dynamic Spawning:** The generator places colored baseplates, placeholder "Loci" (buildings), and NPCs. 
*   **NPC Logic:** 12 Archetypal NPCs are defined in `NPCData`. The `NPCService` handles their spawning and injects their specific dialogue trees and quest triggers.

### 4. Gameplay Loop Mechanics
1.  **Exploration:** Physics-based movement through the 4 districts.
2.  **The Lure (Capture):** A client-side minigame using a radial UI. Players select synonyms for a target word. Success triggers `LogosService.CollectWord(player, word)`.
3.  **Quests:**
    *   **Acceptance:** `InteractionController` detects proximity -> `NPCService` returns dialogue -> `QuestService` assigns a multi-step quest.
    *   **Objectives:** Quests involve finding specific words (collecting "Word Orbs") or reaching locations.
    *   **Completion:** `QuestService` checks inventory via `LogosService:HasWord()` or `GetInventory()`.

### 5. Current Implementation State
*   **Greybox Phase:** Visuals are currently simple blocks and colors to prioritize system stability.
*   **VaaM 1.0:** The "Visualizing Abstract Concepts" system is currently mapping linguistics to stats/roles. VaaM 2.0 (visual aesthetics matching meaning) is on the roadmap.
