# Spec: The Logos Engine (Etymon System)

**Created:** 2026-02-18
**Status:** DRAFT

## 1. Overview
**Goal:** Transform "Words" from simple strings into "Etymons" — living, elemental entities with stats derived from their etymology.
**User Story:** As a player, I want to collect words not just to have them, but because they have power (Stats, Element, Class) that I can use in battles/puzzles.

## 2. Theoretical Framework (VaaM 2.0)
Words are composed of **Morphemes**:
1.  **Root (The Soul/Element)**: Determines the affinity (Fire, Water, Earth, Air).
2.  **Suffix (The Body/Class)**: Determines the physical manifestation (Tank, Striker, Support).

## 3. Data Structures

### Etymon (The Word Creature)
```lua
{
    Id = "ignition",
    Term = "Ignition",
    Definition = "The action of setting something on fire or starting to burn.",
    Root = "Ignis",   -- Fire
    Suffix = "tion",  -- Noun
    Stats = {
        Logos  = 15, -- Logic/Attack (Fire Bonus)
        Pathos = 5,  -- Emotion/Health
        Ethos  = 10, -- Trust/Defense (Noun Bonus)
        Speed  = 8
    },
    Role = "Tank" -- Derived from Suffix
}
```

### Elemental Roots
| Root | Element | Stat Focus | Example |
|---|---|---|---|
| **Ignis** (Pyr) | Fire | High Attack (Logos) | *Ignition, Pyrotechnic* |
| **Aqua** (Hydr) | Water | High Health (Pathos) | *Aquatic, Hydraulic* |
| **Terra** (Geo) | Earth | High Defense (Ethos) | *Terrain, Geology* |
| **Aer** (Pneu) | Air | High Speed | *Aerial, Pneumatic* |
| **Umbra** (Scot) | Shadow | Debuffs (Stealth) | *Umbra, Scotopic* |
| **Lux** (Phot) | Light | Buffs (Reveal) | *Lucid, Photon* |

### Morphological Suffixes
| Suffix | Part of Speech | Role | Stat Bonus |
|---|---|---|---|
| **-tion / -ity / -ment** | Noun | **Tank / Bruiser** | +Defense (Ethos) |
| **-ize / -ate / -fy** | Verb | **Striker / Caster** | +Attack (Logos) |
| **-ous / -al / -ive** | Adjective | **Support / Buffer** | +Utility (Speed/Pathos) |

## 4. API (LogosService)

### Server
- `LogosService.CreateEtymon(word: string) -> Etymon`
    - Parses the word string.
    - Lookups Root and Suffix in `EtymologyDB`.
    - Calculates Stats based on synergy (e.g., Fire Root + Verb Suffix = Ultra High Attack).
- `LogosService.AddEtymon(player, etymon)`
    - Adds to player inventory.
    - Triggers "Discovery" UI.

### Client
- `LogosController`
    - Renders the "New Word Discovered" card with stats and 3D model preview (based on Element).

## 5. Implementation Plan
1.  **EtymologyDB**: A ModuleScript with a dictionary of Roots and Suffixes.
2.  **Etymon Class**: A class that takes a string and constructs the object.
3.  **UI**: A "Pokemon Card" style view for the word.

## 6. Acceptance Criteria
- [ ] Calling `CreateEtymon("Ignition")` returns an object with `Root="Ignis"`, `Role="Tank"`, and correct stats.
- [ ] Collecting a word shows a UI with its Elemental Type and Role.
