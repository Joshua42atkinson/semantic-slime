# Syllable Springs: Roblox Engineering Guide

This guide maps the **"Lore Trinity" (Isomorphism, Mechanics, Learning)** directly to the Roblox Studio file structure and Knit framework patterns. It serves as the standard for how all new lore, NPCs, and semantic data are integrated into the game engine.

---

## 1. Project Structure (Roblox Explorer)
To manage the lore and mechanics efficiently without duplicating logic, data must flow from a single source of truth in `ReplicatedStorage`.

### `ReplicatedStorage.Shared` (The Source of Truth)
*   `Master_Lore/` (Folder containing the raw data)
    *   `LoreDB.lua`: The master table for NPCs, Elements, Archetypes, and Dialogues.
    *   `EtymologyDB.lua`: Root/Suffix definitions, elemental affinities, and stat multipliers.

### `ReplicatedStorage.Controllers` (Client-Side Rendering)
*   `SlimeController.lua`: Handles VaaM 2.0 (Visuals as a Model). Listens to the Server and renders Etymons based physically on their lore.
*   `NPCController.lua`: Handles local dialogue UI, camera work, and rendering phase-aware prompts above NPCs.

### `ServerScriptService.Services` (Server-Side Logic)
*   `GameLoopService.lua`: The "Heartbeat" state machine. Controls what Phase the town is in.
*   `LogosService.lua`: The "Isomorphism" engine. Validates word creation, handles inventory, and calculates stats.
*   `MadLibService.lua`: Procedural quest generation. Reads `LoreDB` to figure out what kind of words NPCs want.
*   `NPCService.lua`: Handles the physical spawning of NPCs and verifying client proximity interactions.

---

## 2. Implementing Isomorphism (VaaM 2.0)
The visual representation of a Slime must ALWAYS perfectly match its underlying data. We achieve this by having `SlimeController` apply visual traits *procedurally* based on the `LogosService` data packet.

**The Workflow Pattern:**
1.  Server (`LogosService`) creates a slime and assigns it Element/Role based on `EtymologyDB`.
2.  Client (`SlimeController`) receives creation event and reads the `Element`.
3.  Client applies colors, materials, particles, and sizes based strictly on that data.

*Example:* "Earth" slimes become Slate/Blocky, "Fire" slimes get Neon/Particle Emitters.

---

## 3. Implementing Mechanics (Phase-Aware NPCs)
To ensure the 12 NPCs act as a unified, living town, we use a **Phase Dispatcher**. This prevents each NPC from needing its own cumbersome script, centralizing all logic.

**The Workflow Pattern:**
1.  `GameLoopService` changes the global phase (e.g., from "Collection" to "Combat").
2.  `NPCService` listens for this phase change.
3.  `NPCService` iterates through all spawned NPCs, queries `LoreDB.lua` for their phase-specific actions/dialogues, and updates their `ProximityPrompt` ActionText.

---

## 4. Implementing Learning (The Knowledge Graph)
Learning is translated into mechanical power. Tracking "Discovered Etymologies" provides permanent stat buffs, turning the player's personal vocabulary growth into character progression.

**The Workflow Pattern:**
1.  `DataService` uses ProfileService to track the `WordsDiscovered` array for each player.
2.  When a player creates a new Slime, `LogosService` calculates its base stats using `EtymologyDB`.
3.  `LogosService` then checks the player's `DataService` profile. If the Slime's Root exists in `WordsDiscovered`, a percentage "Understanding Bonus" (e.g., +10% Attack/Defense) is applied to the final stats.

---

## 5. Summary of Implementation Benefits
*   **Scalability**: Adding a 13th NPC only requires adding one entry to `LoreDB.lua`. No new scripts are needed.
*   **Consistency**: Because `SlimeController` uses the same data as `LogosService`, the Slime's appearance will always inherently match its mechanical power and element.
*   **Ease of Use**: Quest generation (`MadLibService`) becomes a simple "fill-in-the-blank" script that dynamically queries an NPC's archetype and preferences directly from `LoreDB.lua`.
