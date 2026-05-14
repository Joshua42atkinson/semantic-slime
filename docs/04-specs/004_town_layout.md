# Spec 004: Syllable Springs Town Layout & Archetypal NPCs

## 1. Hypothesis
By spatially organizing the game world into a "Mandala" of 4 Cardinal Districts representing Jungian psychological functions (Logos, Eros, Pneuma, Soma), and populating them with 12 Archetypal NPCs, we can:
1.  **Reduce Cognitive Load:** Players intuitively know where to find specific types of knowledge (e.g., "Math is in the North/Logos").
2.  **Reinforce Learning:** The environment itself teaches the curriculum (e.g., visiting the Brutalist West for "Heroic" physical challenges).
3.  **Create "Vibe":** Distinct visual styles for each district prevent aesthetic fatigue and support the "Re-Enchantment" goal.

## 2. Town Layout (The Urban Mandala)
The map is a centralized hub (Town Square) with 4 expanding districts.

### 2.1 The Cardinal Districts
Each district corresponds to a direction and a Jungian function.

| Direction | District | Function | Style | Color Theme |
| :--- | :--- | :--- | :--- | :--- |
| **North** | **Logos** | Thinking | Neoclassical / Gothic | Blue / White / Gold |
| **South** | **Eros** | Feeling | Art Nouveau / Vernacular | Green / Pink / Copper |
| **East** | **Pneuma** | Intuition | Whimsical / Futurist | Purple / Silver / Neon |
| **West** | **Soma** | Sensation | Brutalist / Industrial | Red / Iron / Rust |

### 2.2 The 12 Archetypal Loci (Buildings/Zones)
Each district hosts 3 Archetypal NPCs and their associated buildings.

#### North: District of Logos (Order & Logic)
1.  **The Ruler:** Administrative Building / City Hall.
2.  **The Creator:** The Forge / Workshop (Building zone).
3.  **The Sage:** The Archive / Library.

#### South: District of Eros (Connection & Emotion)
1.  **The Lover:** The Garden / Theatre.
2.  **The Caregiver:** The Hospital / Sanctuary.
3.  **The Everyman:** The Market / Plaza.

#### East: District of Pneuma (Spirit & Possibility)
1.  **The Innocent:** The Playground / Cloud Spire.
2.  **The Magician:** The Observatory / Lab.
3.  **The Jester:** The Circus / Carnival.

#### West: District of Soma (Body & Action)
1.  **The Hero:** The Arena / Gym.
2.  **The Explorer:** The Docks / Map Room.
3.  **The Rebel:** The Undercity / Graffiti Alley.

## 3. Technical Implementation

### 3.1 Greybox Map Generation (`TownSpawner`)
Since we are in the "Greybox" phase, we will use `TownSpawner.server.luau` to procedurally generate:
-   **Ground Planes:** 4 distinct colored baseplates for each district.
-   **Building Placeholders:** Simple Part blocks representing the 12 Loci, color-coded and labeled.
-   **Signage:** SurfaceGUIs identifying the District and Building.

### 3.2 NPC Service Update
Refactor `NPCService` and `NPC` class to support Archetypes.

#### Data Structure (`NPCData.lua`)
New shared module to define the 12 NPCs.
```lua
{
    Id = "Sage_01",
    Name = "The Archivist",
    Archetype = "Sage",
    District = "Logos",
    Color = Color3.fromHex("#4F46E5"),
    DialogueRoot = "Welcome to the Archive. Knowledge is the only true currency."
}
```

#### NPC Spawning
-   `TownSpawner` iterates through `NPCData`.
-   Spawns an R15 Dummy at the corresponding Loci.
-   Applies the distinct Color to the NPC's body parts.
-   Adds an `Interaction` prompt.
-   Sets attributes: `Archetype`, `District`.

### 3.3 Verification
-   **Visual:** Map clearly shows 4 distinct colored zones.
-   **Data:** 12 NPCs defined and spawned in correct locations.
-   **Interaction:** Interacting with an NPC prints their specific Archetype/Dialogue to the output (stub for now).

## 4. Migration Plan
1.  **Create `src/shared/NPCData.lua`**: Define the 12 Archetypes.
2.  **Update `src/server/Scripts/TownSpawner.server.luau`**:
    -   Remove the single prototype "Pete".
    -   Add logic to spawn 4 District Floors.
    -   Add logic to spawn 12 Building Blocks.
    -   Add logic to spawn 12 NPCs based on `NPCData`.
3.  **Update `src/server/Services/NPCService.lua`**:
    -   Ensure `SpawnNPC` method accepts `NPCData` entry.
