# Syllable Springs - Project Context & Lore Bible

## Project Overview

**Project Name:** Syllable Springs (formerly Syllable Springs)
**Genre:** Roblox Adventure/Word-Building Game
**Target Audience:** Primary: Roblox demographic (kids/teens); Secondary: Word game enthusiasts
**Core Concept:** A vibrant, wacky magical town where words literally fall from the sky and grow in the dirt. Language is physical, bouncy, and playful.

---

## World Rebrand Summary

### Old vs. New Names

| Old Name | New Name | Description |
|----------|----------|-------------|
| Syllable Springs | Syllable Springs | Vibrant magical town |
| Logos District | The Brainy Borough | Floating books, puzzle pieces, clockwork gears |
| Eros District | Heartwood Grove | Lush forest, giant glowing flowers, heart-shaped ponds |
| Pneuma District | Whisper Winds | Cloudy high-altitude, floating islands, windmills |
| Soma District | Action Alley | Industrial, construction-themed, obstacle courses |
| The Discord in the Psyche | The Typos / The Static | Glitchy shadow-monsters |
| Context Points | Friendship Points / Bonding XP | Currency for relationships |
| Etymons | Keep as "Etymons" | Semantic Slimes |
| Fabricator | Slime Synthesizer / Word Cauldron | Where words are crafted |

---

## The Lore Trinity

### 1. Isomorphism (Word = World)

In Syllable Springs, language isn't just text on a page—it is living matter. The world is perfectly isomorphic to the rules of language.

- **The Root is the Soul:** A word's linguistic root dictates its elemental heart. A root meaning "fire" physically burns; a root meaning "water" is liquid and flowing.

- **The Suffix is the Body:** The suffix dictates its shape and role. A noun-suffix makes the Etymon bulky and defensive (Tank), while an active verb suffix makes it sharp and fast (Striker).

When players craft an Etymon, they aren't just typing—they are physically weaving the fabric of the universe.

### 2. Mechanics (The Cycle of Meaning)

The daily game loop is the "heartbeat" of Syllable Springs:

| Phase | Time | Activity | Lore Meaning |
|-------|------|----------|--------------|
| **Dawn** | 06:00 | Collection | Raw potential (Letter Crystals) condenses like morning dew |
| **Day** | 12:00 | Construction | Players forge letters into structured meaning (Etymons) |
| **Dusk** | 18:00 | Quests | Meaning applied to solve Mad-Libs problems |
| **Night** | 20:00 | Combat | The Typos emerge; players defend logic and color |

### 3. Learning (The Hero's Journey)

Education isn't a side-effect—it's the ultimate source of power.

- The player is a "Weaver"—capable of unlocking hidden history of words
- Knowledge Pedestals recover lost memories, pushing back The Static
- Learning etymologies grants +10% stat boosts to crafted Etymons

---

## Technical Implementation Notes

### Lore as Data (src/shared/LoreDB.lua)

All NPC data stored in shared ModuleScript accessible by Server and Client:

```lua
local LoreDB = {
    NPCs = {
        [NPCName] = {
            PreferredElement = {"Element1", "Element2"},
            PreferredClass = {"Class1", "Class2"},
            QuestType = "QuestType",
            District = "DistrictName",
            Teaches = {"root/affix list"}
        }
    }
}
```

### Friendship Point Bonus

When players bring Etymons matching an NPC's PreferredElement/PreferredClass, they receive 1.2x Friendship Points.

### Phase Hooks

NPCs hook into GameLoopService.PhaseChanged to swap dialogue based on time of day.

---

## District Guide

### The Brainy Borough (formerly Logos)

**Theme:** Logic/Academic
**Visual:** Floating books, giant puzzle pieces, clockwork gears
**Resident:** Gribble the Goblin
**Vibe:** Intellectual, curious, discovery

### Heartwood Grove (formerly Eros)

**Theme:** Emotion/Nature
**Visual:** Lush colorful forest, giant glowing flowers, cozy cottages, heart-shaped ponds
**Residents:** Barnaby the Cyclops, Vlad the Vampire
**Vibe:** Peaceful, emotional, nature-loving

### Whisper Winds (formerly Pneuma)

**Theme:** Spiritual/Ethereal
**Visual:** Cloudy high-altitude, floating islands, windmills, pastel colors
**Resident:** Martha the Gargoyle
**Vibe:** Dreamy, protective, ethereal

### Action Alley (formerly Soma)

**Theme:** Physical/Body
**Visual:** Industrial, construction-themed, obstacle courses, training yards
**Resident:** Yorick the Skeleton
**Vibe:** Working-class, practical, blue-collar

### Town Hub (Central)

**Theme:** Central meeting point
**Location:** Near Slime Synthesizer
**Resident:** Kael the Minotaur (self-appointed Grand Paladin)
**Vibe:** Heroic, dramatic, central

---

## Character Directory

### 01 - Barnaby (The Innocent)

- **Type:** Cyclops
- **Archetype:** The Innocent (Jungian)
- **District:** Heartwood Grove
- **Personality:** Naive, golden retriever energy, takes everything literally
- **PreferredElements:** Water
- **PreferredClasses:** Support

### 02 - Yorick (The Everyman)

- **Type:** Skeleton
- **Archetype:** The Everyman (Jungian)
- **District:** Action Alley
- **Personality:** Blue-collar, practical, union jokes, unbothered by drama
- **PreferredElements:** Earth
- **PreferredClasses:** Striker

### 03 - Kael (The Hero)

- **Type:** Minotaur
- **Archetype:** The Hero (Jungian)
- **District:** Town Hub (near Synthesizer)
- **Personality:** Dramatic, chivalrous, afraid of his own strength, tiptoes everywhere
- **PreferredElements:** Light
- **PreferredClasses:** Defense

### 04 - Martha (The Caregiver)

- **Type:** Gargoyle
- **Archetype:** The Caregiver (Jungian)
- **District:** Whisper Winds
- **Personality:** Maternal, knits sweaters, makes "granite soup" (hot water + gravel)
- **PreferredElements:** Water, Light
- **PreferredClasses:** Support

### 05 - Gribble (The Explorer)

- **Type:** Goblin
- **Archetype:** The Explorer (Jungian)
- **District:** The Brainy Borough
- **Personality:** Hyperactive, curious, maps everything (including pantries), chases enemies to study them
- **PreferredElements:** Air
- **PreferredClasses:** Striker

### 06 - Nyx (The Rebel)

- **Type:** Banshee
- **Archetype:** The Rebel (Jungian)
- **District:** Action Alley
- **Personality:** Punk-rock, disruptive, fiercely independent, pranks authority
- **PreferredElements:** Air, Shadow
- **PreferredClasses:** Striker
- **Teaches:** Disruptive affixes (un-, de-, anti-, -ify)

### 07 - Vlad (The Lover)

- **Type:** Vampire
- **Archetype:** The Lover (Jungian)
- **District:** Heartwood Grove
- **Personality:** Dramatic, romantic, cheesy poetry, aesthetic obsessed
- **PreferredElements:** Water
- **PreferredClasses:** Support
- **Teaches:** Emotion/relationship roots (phil-, amat-, path-)

---

## Game Terminology Quick Reference

| Term | Definition |
|------|------------|
| **Syllable Springs** | The world/setting |
| **Etymons** | The Semantic Slimes players craft |
| **Slime Synthesizer** | Word crafting station |
| **The Typos** | Night enemies (shadow monsters) |
| **The Static** | Another name for Typos |
| **Weaver** | What the player is called |
| **Letter Crystals** | Raw materials found at Dawn |
| **Friendship Points** | Relationship/currency system |
| **Knowledge Pedestals** | Learning stations in buildings |

---

## Pending Tasks

- [ ] Add Lore Trinity sections to characters 1-5 (Isomorphism, Mechanics, Learning)
- [x] ~~Create characters 6, 8, 9, 10, 11, 12~~ All 12 characters complete
- [ ] Align all avatar build guides with new terminology
- [ ] Fill `Teaches` arrays for characters 1-5

---

*Last Updated: February 2026*
*Project: Syllable Springs Roblox Lore*
