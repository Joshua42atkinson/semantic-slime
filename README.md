# 🧪 Semantic Slime

> **An educational MMO-RPG where words become living creatures.**

Semantic Slime is a Roblox game where players explore **Syllable Springs** — a world built from Jungian archetypes — to catch **Etymons** (word-slimes). Each slime is born from real etymology: its root determines its element, its suffix determines its role. Players collect letter crystals, build words, and use their slimes to solve Mad-Lib quests and fend off clingy letter nuisances.

**Platform:** Roblox (PC/Mobile)  
**Target Audience:** Ages 12–18  
**Framework:** [Knit](https://sleitnick.github.io/Knit/)  
**Sync:** [Rojo](https://rojo.space/) 7.6.1  

---

## 🎮 Core Game Loop

```
COLLECT letter crystals → BUILD words → CATCH slimes → QUEST with Mad-Libs → SURVIVE nuisances
         ↑                                                                         │
         └─────────────────── EVOLVE & MASTER ─────────────────────────────────────┘
```

### Phases
1. **Collection** — Explore districts, gather A–Z crystals (rarity: common → mythic)
2. **Construction** — Spell words in the Word Constructor; valid words spawn Etymon slimes
3. **Quest** — Talk to archetypal NPCs, fill Mad-Lib slots with your slimes
4. **Nuisance** — Clingy letters chase players, cling to them, and feed the alphabet inventory
5. **Rewards** — XP, Insight currency, Evolution Points

---

## 📁 Project Structure

```
semantic-slime/
├── src/
│   ├── client/
│   │   ├── Boot.client.luau       # Client entry point
│   │   ├── Controllers/           # 21 Knit controllers
│   │   ├── UI/                    # 14 UI modules
│   │   └── VisualFeedback/        # Effect systems
│   ├── server/
│   │   ├── Boot.server.luau       # Server entry point
│   │   ├── Services/              # 36 Knit services
│   │   └── Scripts/               # Standalone server scripts
│   └── shared/
│       ├── GameConfig.lua         # Central configuration
│       ├── EtymologyDB.lua        # Root/suffix → element/role mapping
│       ├── WordDatabase.lua       # Valid word list (~956KB)
│       ├── SynonymDatabase.lua    # Synonym/antonym data
│       ├── NPCData.lua            # NPC definitions (12 characters)
│       ├── TownBlueprint.lua      # Procedural map layout
│       ├── Remotes.luau           # RemoteEvent/Function creation
│       └── Data/Master_Lore/      # Character lore (12 NPCs)
├── docs/
│   ├── 01-project/                # Architecture, changelog, setup
│   ├── 02-design/                 # Design doc, mechanics, lore, backlog
│   ├── 03-technical/              # Technical bible
│   ├── 04-specs/                  # Feature specifications
│   ├── 05-pedagogy/               # Educational theory & lessons learned
│   ├── 06-workflows/              # Roadmap
│   └── 07-testing/                # Bug tracker
├── scripts/                       # Rojo health checks, service files
├── default.project.json           # Rojo project config
├── wally.toml                     # Package dependencies (Knit, Promise)
├── rokit.toml                     # Toolchain versions
├── selene.toml                    # Linter config
├── stylua.toml                    # Formatter config
└── semantic_slime_fresh.rbxl      # Latest Studio build
```

---

## 🚀 Getting Started

### Prerequisites
- [Roblox Studio](https://create.roblox.com/)
- [Rokit](https://github.com/rojo-rbx/rokit) (installs Rojo + Wally)

### Setup
```bash
# Install toolchain
rokit install

# Install packages
wally install

# Start Rojo sync
rojo serve default.project.json
```

Then in Roblox Studio:
1. Install the Rojo plugin
2. Connect to `localhost:34872`
3. Press **Play** — the world generates procedurally

---

## 🎯 Current Status: Alpha

The core systems exist but need integration testing and polish. See [ROADMAP.md](docs/06-workflows/ROADMAP.md) for the path to playable.

### What Works
- ✅ Knit service/controller architecture (36 services, 21 controllers)
- ✅ Procedural town generation (7 Jungian districts)
- ✅ 12 archetypal NPCs with lore and dialogue
- ✅ Word construction pipeline (EtymologyDB → SlimeFactory)
- ✅ Game loop phase management
- ✅ Boot sequence with error recovery

### What Needs Work
- 🔧 End-to-end playtest (no verified full-loop playthrough yet)
- 🔧 Data quality audit (SynonymDB, WordDB, QuestData)
- 🔧 UI polish and mobile responsiveness
- 🔧 Sound/music integration verification
- 🔧 Performance profiling

---

## ⌨️ Controls

| Key | Action |
|-----|--------|
| **E** | Interact with NPC |
| **I** | Slime Collection |
| **J** | Quest Log |
| **K** | Word Constructor |
| **Click** | Select / Lure Slime |

---

## 📚 Key Documentation

| Doc | Purpose |
|-----|---------|
| [Architecture](docs/01-project/ARCHITECTURE.md) | System diagram, boot sequence, dependencies |
| [Design Document](docs/02-design/DESIGN_DOCUMENT.md) | Full game design |
| [Lore Bible](docs/02-design/LORE_BIBLE.md) | World and character lore |
| [Game Mechanics](docs/02-design/GAME_MECHANICS.md) | Technical mechanics detail |
| [Roadmap](docs/06-workflows/ROADMAP.md) | Sprint plan to launch |
| [Bug Tracker](docs/07-testing/BUG_TRACKER.md) | Known issues and fixes |
| [Lessons Learned](docs/05-pedagogy/LESSONS_LEARNED.md) | Technical gotchas |

---

## 📄 License

MIT