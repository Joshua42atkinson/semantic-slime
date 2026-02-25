# Semantic Slime (The Phoenix Project)

> *An MMO-Lit-RPG where language is living matter*

## Overview

**Semantic Slime** is an educational Roblox game that teaches vocabulary through engaging gameplay. Players explore **Psyche-Polis**, a town manifesting Jungian psychology, to catch **Etymons** (Semantic Slimes). Each slime represents a word part (Root or Suffix) with elemental properties. Players combine these slimes to craft complex "Words of Power" to solve Mad-Libs style quests and battle obstacles.

## Core Game Loop

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
│       │              EVOLUTION & MEANING                  │             │
│       └──────────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1. Collection Phase
- Explore the world to collect **Letter Crystals** (A-Z)
- Rarer letters (Q, X, Z, J) have higher rarity and glow intensity
- Crystals spawn as physical 3D objects with glow effects

### 2. Construction Phase
- Combine letters to spell words in the **Word Constructor**
- Valid words create new **Slimes** with:
  - **Element** (from Root): Fire, Water, Earth, Air, Shadow, Light
  - **Role** (from Suffix): Tank, Striker, Support, Caster, Assassin
  - **Rarity**: Common → Mythic (with gacha-style chances)

### 3. Quest Phase
- Talk to **Archetypal NPCs** (Hero, Mentor, Trickster, Shadow, Herald)
- Complete **Mad Lib quests** by filling slots with your slimes
- Earn XP, Insight, and Evolution Points

### 4. Battle Phase
- When multiple players want the same quest slot, **battle!**
- Turn-based combat using slime stats (Logos, Pathos, Ethos, Speed)
- Winner fills the slot and gains Context Points

## Project Structure

```
src/
├── client/
│   ├── Boot.client.luau       # Client initialization
│   ├── Controllers/           # Knit controllers
│   │   ├── GameLoopController.lua    # Phase management
│   │   ├── HUDController.lua         # Main HUD
│   │   ├── SlimeController.lua       # Slime visuals
│   │   ├── WordConstructorController.lua
│   │   └── ...
│   └── UI/
│       ├── BattleUI.lua       # Battle interface
│       ├── DialogueUI.lua     # NPC dialogue
│       ├── LureUI.lua         # Capture minigame
│       ├── QuestLog.lua       # Quest tracker
│       ├── SlimeCollectionUI.lua
│       └── StoreUI.lua
├── server/
│   ├── Boot.server.luau       # Server initialization
│   ├── Services/              # Knit services
│   │   ├── GameLoopService.lua    # Game loop orchestration
│   │   ├── CrystalService.lua     # Letter crystal spawning
│   │   ├── SlimeFactory.lua       # Slime creation/evolution
│   │   ├── MadLibService.lua      # Quest generation
│   │   ├── BattleService.lua      # Combat system
│   │   ├── GachaService.lua       # AI-generated slimes
│   │   ├── DataService.lua        # Data persistence
│   │   ├── TownGenerator.lua      # Procedural map
│   │   └── ...
│   └── Scripts/
│       ├── LightingManager.server.luau
│       └── WordItemScript.server.luau
└── shared/
    ├── GameConfig.lua         # Central configuration
    ├── EtymologyDB.lua        # Root/Suffix database
    ├── SynonymDatabase.lua    # Lure minigame data
    ├── WordDatabase.lua       # Valid words
    ├── NPCData.lua            # NPC definitions
    └── TownBlueprint.lua      # Map layout
```

## Key Systems

### The Logos Engine (Etymon System)
Words are analyzed and transformed into creatures:
- **Root** determines Element (Ignis → Fire, Aqua → Water, etc.)
- **Suffix** determines Role (-tion → Tank, -ize → Striker, etc.)
- **Stats** are calculated from: Base + RootBonus + SuffixBonus × LevelMultiplier

### Evolution System
- Slimes level up through quest usage
- At Level 10, can evolve with Insight currency
- Evolution stages: Normal → Greater → Ascended → Divine → Cosmic
- Modifiers (ed, ing, er, etc.) add stat bonuses

### Gacha System
- AI-generated "imaginary" slimes with unique traits
- Rarity-based stat multipliers
- Signature moves and flavor text

## Development Setup

### Prerequisites
- [Rojo](https://rojo.space/) for syncing with Roblox Studio
- [Wally](https://wally.run/) for package management

### Installation
```bash
# Install dependencies
wally install

# Start Rojo sync
rojo serve default.project.json
```

### In Roblox Studio
1. Install the Rojo plugin
2. Connect to the Rojo server (default: localhost:34872)
3. The game will sync automatically

## Controls

| Key | Action |
|-----|--------|
| I | Open Slime Collection |
| J | Toggle Quest Log |
| K | Open Word Constructor |
| E | Interact with NPC |
| Click | Select/Lure Slime |

## Configuration

Edit `src/shared/GameConfig.lua` to adjust:
- Phase durations
- Evolution costs
- Element colors and emojis
- UI color scheme

## Documentation

See `docs/` for detailed specifications:
- `context.md` - Project overview
- `game_mechanics.md` - Technical mechanics
- `specs/001_game_manager.md` - Game state management
- `specs/002_town_quest_system.md` - Quest system
- `specs/003_logos_engine.md` - Etymon system
- `specs/004_town_layout.md` - Map generation
- `specs/005_integrated_game_loop.md` - Complete game loop

## Credits

Built with:
- [Knit](https://sleitnick.github.io/Knit/) - Roblox framework
- [Promise](https://github.com/evaera/promise.lua) - Promise implementation

## License

MIT License - See LICENSE file for details