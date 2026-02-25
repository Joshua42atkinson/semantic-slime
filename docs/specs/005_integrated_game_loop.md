# Spec: Integrated Game Loop - Semantic Slime

**Created:** 2026-02-24
**Status:** DRAFT
**Vision:** A vocabulary-building RPG where players collect letter-crystals to spell words, creating slimes that battle for narrative slots in AI-driven Mad Lib quests.

---

## 1. Core Vision

### The Game Loop
```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MAIN GAME LOOP                                  │
│                                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│  │ COLLECT  │───▶│ CONSTRUCT│───▶│  QUEST   │───▶│  BATTLE  │         │
│  │ LETTERS  │    │   WORD   │    │   MAD    │    │  FOR     │         │
│  │ CRYSTALS │    │  SLIMES  │    │   LIBS   │    │  SLOTS   │         │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘         │
│       ▲                                                   │             │
│       │              EVOLUTION & MEANING                 │             │
│       └──────────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.1 Collection Phase (Crystal Mining)
- Players explore the world to collect **Letter Crystals** (A-Z)
- Crystals spawn as physical 3D objects with glow effects
- Rarer letters (Q, X, Z, J) have higher rarity and glow intensity
- Players combine letters to spell words → creates a new Slime

### 1.2 Construction Phase (Word Assembly)
- **Letter Inventory**: Players store collected letters
- **Word Constructor**: Drag-and-drop or type to assemble words
- **Slime Birth**: When a valid English word is formed, a Slime is born
  - The **Root** determines Element (Fire, Water, Earth, etc.)
  - The **Suffix** determines Role (Tank, Striker, Support, etc.)
  - The **Core Word** is the base identity

### 1.3 Evolution Phase (Modifier System)
- Core words can be evolved with suffixes/prefixes:
  - Base: `run` → Runner (adds -er)
  - Past: `run` → `runned` or `ran` (adds -ed/-en)
  - Progressive: `run` → `running` (adds -ing)
  - Plural: `cat` → `cats` (adds -s)
- Evolution grants stat bonuses and new abilities
- **Evolution Points (EP)**: Earned through quest usage

### 1.4 Quest Phase (Mad Lib Drama)
- AI generates story-driven quests using Mad Lib templates
- NPCs have **Archetypes**: Hero, Mentor, Trickster, Shadow, Herald
- The quest narrative has **Placeholder Slots** that need Slimes
- Example: "The [ADJECTIVE] hero [VERB] toward the [NOUN]"

### 1.5 Battle Phase (Slot Competition)
- Multiple players' slimes compete for quest slots
- Slimes battle using their stats (Logos, Pathos, Ethos, Speed)
- Winner fills the slot → gains **Context Points**
- Context Points make the word's meaning more impactful

---

## 2. Game Systems Architecture

### 2.1 Slime Entity Data Structure

```lua
-- Complete Slime Instance
export type SlimeInstance = {
    -- Identity
    InstanceId: string,           -- Unique UUID
    WordId: string,               -- Base word (e.g., "run")
    Term: string,                 -- Display name (e.g., "Running")
    
    -- Morphology
    Root: string,                 -- Etymological root (e.g., "run" → "run")
    Suffix: string?,              -- Modifier suffix (e.g., "ing", "ed", "s")
    Prefix: string?,              -- Optional prefix modifier
    
    -- Classification
    Element: string,              -- Fire, Water, Earth, Air, Shadow, Light
    Role: string,                 -- Tank, Striker, Support, Caster, Assassin
    
    -- Progression
    Level: number,                -- 1-100
    XP: number,                   -- Current XP
    EvolutionStage: number,       -- 1-5 (Normal, Greater, Ascended, Divine, Cosmic)
    
    -- Stats (VaaM-inspired)
    Stats: {
        Logos: number,            -- Logic/Attack power
        Pathos: number,           -- Emotion/Health
        Ethos: number,            -- Trust/Defense
        Speed: number             -- Initiative/Agility
    },
    
    -- Context & Meaning
    ContextPoints: number,        -- Earned through quest usage
    ContextHistory: {             -- Records of how word was used
        { QuestId: string, Slot: string, Outcome: string }
    },
    
    -- Gacha Properties (AI-generated)
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic",
    ImaginaryTrait: string?,      -- AI-generated unique trait
    SignatureMove: string?,       -- Special ability name
    
    -- Visual
    PrimaryColor: Color3,
    SecondaryColor: Color3,
    ParticleEffect: string,
}
```

### 2.2 Rarity System (Gacha-Inspired)

| Rarity | Chance | Stat Multiplier | Visual Flair |
|--------|--------|-----------------|--------------|
| Common | 40% | 1.0x | Standard glow |
| Uncommon | 25% | 1.2x | Green shimmer |
| Rare | 18% | 1.5x | Blue particles |
| Epic | 10% | 1.8x | Purple aura |
| Legendary | 5% | 2.2x | Gold flames |
| Mythic | 2% | 3.0x | Rainbow rainbow |

### 2.3 Mad Lib Quest Structure

```lua
export type MadLibQuest = {
    QuestId: string,
    Title: string,
    
    -- NPC Archetype Story
    NarratorArchetype: "Hero" | "Mentor" | "Trickster" | "Shadow" | "Herald",
    DramaticSituation: string,   -- The narrative context
    
    -- Slots requiring slime filling
    Slots: {
        {
            SlotId: string,
            SlotType: "ADJECTIVE" | "VERB" | "NOUN" | "ADVERB",
            RequiredElement: string?,  -- Optional element requirement
            RequiredRole: string?,     -- Optional role requirement
            FilledBy: string?,         -- PlayerId_SlimeInstanceId
            CompetingSlimes: {         -- Slimes in battle
                { PlayerId: string, InstanceId: string }
            }
        }
    },
    
    Rewards: {
        XP: number,
        Insight: number,
        EvolutionPoints: number,
        ContextPoints: number
    }
}
```

### 2.4 NPC Archetype System

| Archetype | Role in Mad Lib | Dialogue Style | Preferred Stats |
|-----------|-----------------|----------------|----------------|
| **Hero** | Protagonist | Brave, determined | High Logos |
| **Mentor** | Guide | Wise, cryptic | High Ethos |
| **Trickster** | Complication | Sneaky, humorous | High Speed |
| **Shadow** | Antagonist | Menacing, dark | High Pathos |
| **Herald** | Catalyst | Urgent, prophetic | Balanced |

---

## 3. Service Architecture

### 3.1 New Services Required

| Service | Responsibility |
|---------|----------------|
| **CrystalService** | Manages letter crystal spawning, collection, inventory |
| **SlimeFactory** | Creates slimes from words, handles evolution, modifiers |
| **GachaService** | AI-generates imaginary slimes with rarity and traits |
| **MadLibService** | Generates AI quest narratives, manages slot filling |
| **BattleService** | Handles slime combat for quest slots |
| **ContextService** | Tracks word meaning development through usage |

### 3.2 Existing Services to Extend

| Service | Extension |
|---------|-----------|
| **WordService** | Add modifier support, evolution tracking |
| **LogosService** | Integrate with SlimeFactory, add ContextPoints |
| **QuestService** | Connect to MadLibService for dynamic quests |
| **AIService** | Add methods for Gacha generation and Mad Lib creation |

---

## 4. Core Gameplay Flows

### 4.1 Crystal Collection Flow
```
1. CrystalService spawns letter crystal in world
2. Player touches crystal → triggers collection
3. Crystal added to player's LetterInventory
4. UI shows new letter with fanfare
5. Check if new letters enable new word combinations
```

### 4.2 Word Construction Flow
```
1. Player opens Word Constructor UI
2. Drag letters from inventory to spell slots
3. System validates word against WordDatabase
4. If valid word:
   a. SlimeFactory creates new SlimeInstance
   b. GachaService assigns rarity and traits
   c. Slime spawns in player's collection
   d. UI shows "New Slime Discovered!"
5. If invalid: UI shows "Not a valid word"
```

### 4.3 Evolution Flow
```
1. Player selects slime to evolve
2. System shows available modifiers based on word
3. Player selects modifier (e.g., "ing" for "run" → "running")
4. Deduct Evolution Points cost
5. Slime stats increase, visual updates
6. New term displayed (e.g., "Running" instead of "Run")
```

### 4.4 Mad Lib Quest Flow
```
1. Player talks to NPC
2. AIService generates Mad Lib quest based on:
   - Player's collected slimes
   - NPC archetype
   - Current world state
3. Quest UI shows narrative with empty slots
4. Player selects slime to fill slot
5. If multiple players want same slot → Battle Phase
6. Winner fills slot → ContextPoints awarded
7. Complete all slots → Quest complete
8. Rewards distributed + Reflection (Socratic questioning)
```

### 4.5 Battle Flow
```
1. Multiple slimes compete for one slot
2. Turn-based combat using stats:
   - Logos vs Ethos (Attack vs Defense)
   - Speed determines turn order
   - Pathos used for special abilities
3. Winner determined by HP system
4. Victory grants ContextPoints to winner
5. Loser returns to inventory (not destroyed)
```

---

## 5. Implementation Status

### ✅ Phase 1: Foundation - COMPLETE
- [x] CrystalService - Letter spawning and collection
- [x] Word Constructor (via SlimeFactory)
- [x] Slime creation from words
- [x] Basic inventory system

**Files Created:**
- `src/server/Services/CrystalService.lua`

### ✅ Phase 2: Evolution System - COMPLETE
- [x] Modifier system (ed, s, ing, er, etc.)
- [x] Evolution point accumulation  
- [x] Stat recalculation on evolution
- [x] ContextPoints and meaning tracking

**Files Created:**
- `src/server/Services/SlimeFactory.lua`

### ✅ Phase 3: Quest & Mad Lib - COMPLETE
- [x] MadLibService with templates
- [x] NPC archetype dialogue system
- [x] Slot filling mechanics
- [x] Quest completion rewards

**Files Created:**
- `src/server/Services/MadLibService.lua`

### ✅ Phase 4: Combat & Gacha - COMPLETE
- [x] BattleService for slot competition
- [x] GachaService for AI-generated slimes
- [x] Rarity system with visual flair
- [x] ContextPoints tracking

**Files Created:**
- `src/server/Services/BattleService.lua`
- `src/server/Services/GachaService.lua`

### ✅ Phase 5: Game Loop Integration - COMPLETE
- [x] GameLoopService - Complete game loop orchestration
- [x] Phase transitions (Collection → Construction → Quest → Combat → Rewards)
- [x] All systems connected

**Files Created:**
- `src/server/Services/GameLoopService.lua`

### Next Steps (Post-Implementation)
- [ ] Full UI integration (Word Constructor UI, Quest UI, Battle UI)
- [ ] Sound effects
- [ ] Data persistence (save/load player data)
- [ ] Performance optimization
- [ ] Balance tuning

---

## 6. Acceptance Criteria

### Collection
- [ ] Letter crystals spawn in world with correct frequency
- [ ] Collecting crystals adds them to player inventory
- [ ] Rarer letters have appropriate rarity glow

### Construction
- [ ] Word Constructor validates real English words
- [ ] New slimes created with correct element/role
- [ ] Gacha rarity assigned on creation

### Evolution
- [ ] Modifiers correctly transform base words
- [ ] Stats increase appropriately with evolution
- [ ] Visual changes reflect evolution stage

### Quests
- [ ] AI generates coherent Mad Lib quests
- [ ] NPCs follow archetype dialogue patterns
- [ ] Slots fill correctly with player slimes

### Combat
- [ ] Battle resolves correctly based on stats
- [ ] Winner fills quest slot
- [ ] ContextPoints awarded appropriately

---

## 7. Notes

- **Why Mad Libs?** Creates emergent storytelling where player vocabulary directly shapes the narrative
- **Why Gacha?** AI-generated "imaginary" slimes add excitement and replayability without needing manual content creation
- **Why Context Points?** Gives meaning to repetition - using a word in quests makes it more "powerful" in-game, mirroring real language acquisition
- **Quest-Drama Connection**: The NPC archetypes provide emotional stakes. The Trickster's quest will have different word slots than the Hero's quest.

---

*This spec will evolve as we implement and discover what works best. All systems should be modular to allow for iteration.*
