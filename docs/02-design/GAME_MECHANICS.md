# 🛠️ Semantic Slime: Technical & Gameplay Mechanics
## *Mechanical Overview: The Phoenix Project*

---

### 1. Framework & Architecture
The game is built using the **Knit** framework on Roblox, which enforces a clear separation between **Services** (Server-side logic) and **Controllers** (Client-side logic).

*   **Communication:** Services expose methods to Controllers via standard Knit middleware. Events (like word collection or XP gain) are handled through `RemoteEvents` organized in `ReplicatedStorage`.
*   **Data Persistence:** Integrated via `DataService` using Roblox `DataStoreService` to track player stats (Insight, XP) and word inventories across sessions.

### 2. The Etymon System (Word → Creature)
Words (Etymons) are objects generated dynamically by `SlimeFactory`.

*   **Analysis:** When a word is "minted," the engine parses it against `EtymologyDB` (a shared module) to identify its **Root** and **Suffix**.
*   **Stats Generation:**
    *   **Root (Linguistic Element):** Determines the elemental type (Fire, Water, etc.) and primary stat focus (Attack/Defense).
    *   **Suffix (Morphological Role):** Determines the "class" or role (Tank, Striker, Support).
    *   **Formula:** Stats = `(Base + RootBonus + SuffixBonus) * LevelMultiplier`.
*   **Evolution:** At Level 10, players can spend "Insight" (currency) to evolve an Etymon, resetting its level but applying a permanent stage multiplier (1.5x, 2.0x, etc.) and prepending titles (e.g., "Greater", "Ascended").

### 3. Procedural World Generation
`TownGenerator` reads a `TownBlueprint` to construct the world at runtime.

*   **The Urban Mandala:** The map is divided into 4 quadrants (Districts), each with unique architecture, props, and ambient effects.
*   **Dynamic Spawning:** The generator places district floors, buildings with interiors, entrance arches, ambient crystal shards, paved roads, and NPCs.
*   **NPC Logic:** 11 Archetypal NPCs are defined in `LoreDB` via `NPCData`. `NPCService` handles spawning and injects phase-aware dialogue trees.

### 4. Gameplay Loop Mechanics (The "Organic" Flow)
1.  **The World Breathes in Letters (Collection — 45s)**: Dawn phase. Players explore districts to collect Letter Crystals (A–Z) with rarity-based glow.
2.  **Crystallizing Meaning (Construction — 30s)**: Day phase. Players spell words at the Slime Fabricator to create Etymon slimes.
3.  **Manifesting the Hero's Journey (Quest — 90s)**: Dusk phase. NPCs offer archetype-driven Mad-Libs quests with placeholder slots.
4.  **Discord in the Psyche (Combat — 45s)**: Night phase. Slimes battle for quest slots.
5.  **Resonance of Achievement (Rewards — 30s)**: Stars phase. Players receive XP, Insight, and Context Points.

**Note on HUD**: The timer is hidden until the final 10 seconds of a phase to maintain immersion.

### 5. The Lure Minigame (Capture Mechanic)
Wild Etymons roam the districts with an Idle → Alert → Fleeing state machine. Players click a slime to trigger the **Synonym Lure**:
- 4 choices appear (synonyms + distractors from `SynonymDatabase`)
- Correct synonym → capture attempt sent to server
- Wrong synonym → slime flees with trail VFX

### 6. Slime Companionship & Progression
*   **The Follower**: Players can select one Slime as an active companion (pet system — **not yet implemented**).
*   **Context Points (CP)**: Using a slime in quests/battles grants CP. At 100 CP, the slime unlocks a Signature Move.
*   **Gacha System**: `GachaService` generates "Imaginary Slimes" with AI-style traits and rarities (Common → Mythic). **Not yet wired to currency.**

### 7. Current Implementation Status

| System | Status | Notes |
|--------|--------|-------|
| 5-Phase Game Loop | ⚠️ Runs but has bugs | Forward-reference crash in `grantObjectiveBonus` |
| Crystal Collection | ✅ Working | Spawns, collects, adds to inventory |
| Slime Creation | ⚠️ Mostly works | `generateSignatureMove` forward-ref bug |
| Lure/Capture | ✅ Working | Synonym matching → server validation |
| Mad-Libs Quests | ⚠️ Bug in FillSlot | `buildNarrative` gets wrong argument |
| Battle System | ✅ Auto-only | Player actions exist but don't affect auto-loop |
| Gacha System | ✅ Built | Not wired to game economy |
| Data Persistence | ✅ Working | DataStore save/load on join/leave |
| NPC Dialogue | ✅ Working | Phase-aware, archetype-driven |
| HUD System | ✅ Working | Notifications, stats, action bar |

### 8. Potential Expansions
*   **Sentence Combos**: Deploy 3 slimes at once to form Subject-Verb-Object for a massive ultimate attack.
*   **Trading**: Players trade rare words (like "Defenestration") in the Hub.
*   **Dictionary Registry**: Global leaderboard for "First Discoverer" of complex words.
*   **Interactive Battles**: Turn-based combat replacing auto-resolve.

> See [game_loop_improvements.md](./game_loop_improvements.md) for detailed implementation workflow.
> See [content_backlog.md](./content_backlog.md) for all content that needs building.
