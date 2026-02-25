# Semantic Slime (The Phoenix Project) - Technical Bible

## 1. Project Overview
**Semantic Slime** is an MMO-Lit-RPG where language is living matter. Players explore **Psyche-Polis**, a town manifesting Jungian psychology, to catch **Etymons** (Semantic Slimes). Each slime represents a word part (Root or Suffix) with elemental properties. Players combine these slimes to craft complex "Words of Power" to solve Mad-Libs style quests and battle obstacles.

## 2. Core Loop
1.  **Explore**: Traverse the 4 Cardinal Districts of Psyche-Polis (Logos, Eros, Pneuma, Soma).
2.  **Capture**: Find wild Etymons in the "Wilderness" behind buildings. Engage in a "Lure" minigame using synonyms.
3.  **Synthesize**: Combine a Root Slime (Element) + Suffix Slime (Role) to create a sophisticated Word Companion (e.g., *Ignis* + *tion* = *Ignition* Tank).
4.  **Resolve**: Use Word Companions to influence Town Drama (NPC Quests) or clear environmental blockages.

## 3. Architecture
The project uses the **Knit** framework on Roblox.

### 3.1 Server Services (`src/server/Services`)
*   **`LogosService`**: The "Etymon Engine". Handles word analysis (Root/Suffix), inventory, stats, and evolution.
*   **`TownGenerator`**: Procedural map generator. Reads `TownBlueprint` to spawn Districts, Buildings, and KPIs.
*   **`MonetizationService`**: Handles DevProducts (Insight Packs) and GamePasses (Double XP, VIP).
*   **`NPCService`**: Manages Archetypal NPCs and their dialogue trees.
*   **`QuestService`**: Tracks player progress through the "Hero's Journey".

### 3.2 Client Controllers (`src/client/Controllers`)
*   **`SlimeController`**: Visuals for Slimes (jumping, squishing, following).
*   **`LureController`**: The capture minigame UI (Radial synonym wheel).
*   **`JournalController`**: UI for Quests and Word Inventory.

### 3.3 Shared Data (`src/shared`)
*   **`TownBlueprint`**: Configuration for Map Districts, Buildings, and Props.
*   **`EtymologyDB`**: Database of Roots (`Ignis`, `Aqua`) and Suffixes (`-tion`, `-ous`).
*   **`NPCData`**: Definitions for the 12 Archetypal NPCs.

## 4. Current State (Honest Assessment)
*   **Map**: Functional "Greybox" prototype. Generates 4 flat districts. size ~800x800. **Needs Expansion**.
*   **Slimes**: Functional backend (`LogosService`), basic frontend.
*   **Monetization**: Logic exists for Products/Passes, but no UI Storefront.
*   **Fun Factor**: Core loop is technically possible but lacks "Juice" (VFX, Sound, Polish).
*   **Documentation**: Just restored.

## 5. Future Roadmap (The Manifestation)
*   **Map 2.0**: "Wilderness" Zones behind buildings. Dynamic Terrain (Perlin Noise) affecting spawn rates.
*   **VaaM 2.0**: Visualizing Abstract Concepts. Slimes need to *look* like their meaning.
*   **Social**: MMO features (trading slimes, coop Mad Libs).
