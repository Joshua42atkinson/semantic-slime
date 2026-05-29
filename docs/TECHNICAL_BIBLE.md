# Semantic Slime — Technical Bible
> **Single source of truth.** Everything an agent or developer needs to understand and work on this project.

---

## 1. What Is This Game?

An **educational MMO-RPG** on Roblox that teaches English language mechanics through gameplay. Players collect letter crystals, construct words that become **Slimes** (pet creatures), and use those Slimes to fill **Mad Lib** quests given by NPCs.

**Tone:** Pokémon-adjacent, cheeky, non-violent. Letters are "annoying" not "attacking." Cleverness replaces combat.

**Target:** Family-friendly, designed for the creator's kids.

---

## 2. Core Pipeline

```
Letter Crystal → 26-Slot Alphabet Inventory → Word Construction → SLIME → Mad Lib Quest Slot
```

| Step | Service | What Happens |
|------|---------|-------------|
| 1. Collect | `CrystalService` | Glowing letter crystals spawn in the world. Players walk into them. Each letter fills a slot in their 26-letter alphabet inventory. |
| 2. Annoy | `LetterNuisanceService` | During Nuisance phase, clingy letters chase players and cling to them. These ALSO feed the alphabet inventory. Players are "annoyed" not "attacked." |
| 3. Build | `SlimeFactory` | Player spells a word using letters from their inventory → word becomes a **Slime** with element, role, stats, and rarity. |
| 4. Quest | `MadLibService` | NPCs offer Mad Lib quests with blank slots (NOUN, VERB, ADJECTIVE, ADVERB). Player fills slots with their Slimes. Completing a quest = XP + rewards. |
| 5. Evolve | `SlimeFactory` | Slimes gain XP, evolve through 5 stages (K-2 → Graduate), gain suffix/prefix/determiner modifiers. |
| 6. Companion | `PetService` | One Slime can be set as a companion that follows the player around. |

---

## 3. Game Loop Phases

```
Collection → Construction → Quest → Nuisance → Rewards → (repeat)
```

| Phase | Duration | What Happens |
|-------|----------|-------------|
| **Collection** | 45s | Letter crystals spawn. Players collect them. Dawn lighting. |
| **Construction** | 30s | Players build words from collected letters → creates Slimes. Day lighting. |
| **Quest** | 90s | Players visit NPCs, accept Mad Lib quests, fill slots with Slimes. Day lighting. |
| **Nuisance** | 45s | Clingy letters flood the map, chase players, cling to them. Dusk lighting. Players shake them off by building words. |
| **Rewards** | 30s | Quest completion rewards distributed. Night lighting. |

Durations scale: +5s per connected player (max +60s).

---

## 4. Architecture

### Framework
- **Knit** — service/controller framework for Roblox
- **Rojo** — file sync (`rojo serve default.project.json`)

### File Structure
```
src/
├── server/
│   ├── Boot.server.luau         ← Server entry point
│   ├── Services/                ← 37 Knit services
│   │   ├── GameLoopService.lua  ← Phase loop orchestrator
│   │   ├── CrystalService.lua   ← Letter inventory
│   │   ├── SlimeFactory.lua     ← Word → Slime creation
│   │   ├── MadLibService.lua    ← Quest generation & slot filling
│   │   ├── NPCService.lua       ← NPC spawning & interaction
│   │   ├── TownGenerator.lua    ← Procedural world generation
│   │   ├── TerrainService.lua   ← Terrain & biome generation
│   │   ├── LightingService.lua  ← Phase-based lighting transitions
│   │   ├── LetterNuisanceService.lua ← Clingy letter mechanic
│   │   ├── DataService.lua      ← Player persistence (DataStore)
│   │   ├── AIService.lua        ← Gemini API for NPC dialogue
│   │   └── ...
│   └── Scripts/
├── client/
│   ├── Boot.client.luau         ← Client entry point
│   ├── Controllers/             ← 21 Knit controllers
│   │   ├── HUDController.lua    ← Main UI
│   │   ├── SlimeController.lua  ← Wild slime behavior
│   │   └── SoundController.lua  ← Ambient audio
│   ├── UI/                      ← UI modules
│   │   ├── SlimeCollectionUI.lua
│   │   └── AnnoyanceUI.lua      ← (planned) Annoyance meter
│   └── VisualFeedback/          ← VFX modules
└── shared/
    ├── Remotes.luau             ← Remote event creation
    ├── GameConfig.lua           ← Central tunables
    ├── TownBlueprint.lua        ← District/building layouts
    ├── NPCData.lua              ← NPC → District mapping
    ├── LoreDB.lua               ← NPC lore & archetype data
    ├── EtymologyDB.lua          ← Root/suffix/morpheme DB
    ├── WordDatabase.lua         ← Valid words & grade levels
    ├── SlimeVisuals.lua         ← 3D slime model builder
    ├── AchievementData.lua      ← Achievement definitions
    └── QuestData.lua            ← Quest templates
```

### Sync Mapping (Rojo)
| Filesystem | Roblox Location |
|-----------|----------------|
| `src/shared/` | `ReplicatedStorage.Shared` |
| `src/server/` | `ServerScriptService.Server` |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Client` |
| `Packages/` | `ReplicatedStorage.Packages` |

---

## 5. NPCs & Districts

12 named NPCs across 4 districts. Each has an archetype (from Jungian archetypes) and teaches specific morphemes.

| District | NPCs | Theme |
|----------|------|-------|
| **Cognito Heights** | Barnaby (Innocent), Yorick (Sage), Kael (Explorer) | Mind & knowledge |
| **Mythic Quarter** | Martha (Hero), Gribble (Magician), Nyx (Lover) | Stories & adventure |
| **Ember Ward** | Vlad (Jester), Pygmalion (Everyman), Chesty (Caregiver) | Creation & warmth |
| **Void Reach** | Ozymandias (Rebel), Zafir (Creator), Ignis (Ruler) | Power & ambition |

---

## 6. Slime System

- **Creation:** Player spells word → `SlimeFactory:CreateSlime(player, word)`
- **Max inventory:** 5 active slimes
- **Stats:** Logos, Pathos, Ethos, Speed (derived from root etymology + role)
- **Elements:** Fire, Water, Earth, Air, Shadow, Light, Normal
- **Roles:** Tank, Striker, Support, Caster, Assassin, Healer, Civilian
- **Rarity:** Common → Uncommon → Rare → Epic → Legendary → Mythic
- **Evolution:** 5 stages — Baseline (K-2) → Graduate. Types: suffix, noun fusion, possessive, adjective, determiner
- **Companion:** One slime follows the player (via `PetService`)

---

## 7. Known Requirements

| Requirement | Notes |
|-------------|-------|
| **Gemini API Key** | Place in `ServerStorage.GeminiAPIKey` or hardcode in AIService. Without it, NPCs use fallback dialogue. |
| **Published Place** | DataStore requires a published Roblox place with API access enabled. |
| **Rojo** | `rojo serve default.project.json` to sync files to Studio. |

---

## 8. Key Design Principles

1. **Annoyed, not attacked** — Letters are nuisances, not enemies
2. **Cleverness, not combat** — Mad Libs are the "battles"
3. **Aversions and attractions** — Players avoid clingy letters, seek NPC stations for quests
4. **Pokémon-adjacent** — Slime companion follows you, has element/type/evolution
5. **Educational core** — Etymology, morphemes, word construction, contextual usage
6. **Cheeky tone** — Letters plead: *"PLEASE spell me into something!"*
