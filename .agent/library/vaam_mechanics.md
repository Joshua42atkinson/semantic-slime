# VaaM (Vocabulary-as-a-Mechanic) Design Specification

Based on: *"The Cognitive Mechanics of Vocabulary"*

## 1. Core Concept
Words are **Functional Assets** (Runes), not just text. Their in-game stats are derived directly from real-world Psycholinguistic Data.

## 2. The Formulas (Psycholinguistics -> Gameplay)

### A. Damage Type (Concreteness)
*Source: Brysbaert Norms (1-5 Scale)*
-   **Concrete (4-5):** Physical Damage (Blocked by Armor).
-   **Abstract (1-2.5):** Magic Damage (Ignores Armor / Resisted by Will).
-   **Formula:**
    $$Physical\% = (Concreteness - 1) / 4$$
    Example: *Rock* (4.85) = 96% Phys. *Idea* (1.45) = 11% Phys.

### B. Level & Cost (Age of Acquisition - AoA)
*Source: Kuperman Norms (Years)*
-   **Item Level:** Prevents overwhelming novices.
    $$Level = AoA \times 2$$
-   **Mana Cost:** Complexity tax.
    $$Cost = Base \times e^{k(AoA - Min)}$$
    *Logic:* High AoA words are powerful but mentally draining.

### C. Elemental Alignment (VAD)
*Source: Warriner Norms (Valence, Arousal, Dominance)*
| Dimension | High (>7) | Low (<3) |
| :--- | :--- | :--- |
| **Valence** | **Holy/Buff** (Joy) | **Shadow/Rot** (Grief) |
| **Arousal** | **Crit/Berserk** (Frenzy) | **Stasis/Root** (Calm) |
| **Dominance** | **Aggro/Tank** (King) | **Stealth** (Servant) |

### D. Area of Effect (Semantic Density)
-   **High Density:** AoE / Splash (Spreads like the network).
-   **Low Density:** Sniper / Single Target (Precise).

## 3. Technical Architecture (Roblox)

### Data Storage
-   **Strategy:** Static ModuleScripts (Sharded).
-   **Reason:** Avoiding DataStore throttling for readonly data.
-   **Structure:**
    ```lua
    -- src/shared/Data/WordDB_A.lua
    return {
        ["apple"] = { C=5.0, AoA=2, V=6, A=4, D=5 },
        ["anxiety"] = { C=1.5, AoA=9, V=2, A=8, D=3 },
    }
    ```

### Crafting (Semantic Synthesis)
-   **Client:** Sends `(WordA, WordB)` to Server.
-   **Server:** Checks Cache. If missing, calls `HttpService` -> External Python API (Vector Math).
-   **Logic:** `Vec(A) + Vec(B) = Vec(C)`.

### Stealth Assessment
-   **Inverse Efficiency Score (IES):** `RT / (1 - PE)`
-   **Mechanic:** If IES < 1.5s, word becomes **Gold (Mastered)** (+10% Stats).

## 4. Implementation Stages
1.  **The Database:** Create the `WordData` Module.
2.  **The Rune Factory:** A script that takes a string ("Precarious") and generates a Tool/Object with stats calculated from the data.
3.  **The Combat:** Implementing the Damage/Cost logic.
