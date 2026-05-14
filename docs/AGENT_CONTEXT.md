# Agent Context — Semantic Slime

> **Read this first.** This is a focusing document for AI agents working on this codebase.

## What You're Working On

A Roblox educational MMO where players collect letters, build words into pet Slimes, and use Slimes in Mad Lib quests at NPC stations. **No combat.** Letters "annoy" players by chasing them — players use cleverness (word construction) to shake them off.

## The Pipeline (Memorize This)

```
Letter → 26-Slot Inventory → Word → Slime → Mad Lib Slot → Rewards
```

## Critical Services (Touch Carefully)

| Service | Does What | Breaks If |
|---------|-----------|-----------|
| `GameLoopService` | Phase orchestrator (Collection→Construction→Quest→Nuisance→Rewards) | Phase transitions or duration logic changes |
| `CrystalService` | 26-slot alphabet inventory, letter spawning | `activeCrystalCount` counter desyncs |
| `SlimeFactory` | Word → Slime with stats/element/role | `analyzeWord()` or `EtymologyDB` changes |
| `MadLibService` | Quest generation with archetype-flavored NPC dialogue | `QuestData` template structure changes |
| `TownGenerator` | World generation (runs in `KnitStart()`) | `TownBlueprint` district/building key mismatches |
| `LetterNuisanceService` | Clingy letters that chase players during Nuisance phase | CrystalService integration (calls `AddLetterToInventory`) |
| `DataService` | Player persistence via DataStore | Circular dependency if hydration isn't deferred |

## Architecture Rules

1. **Boot order:** `Boot.server.luau` → Remotes → Load all services → `Knit.Start()` → each service's `KnitStart()` runs
2. **No `task.delay()` hacks** — use `KnitStart()` for post-boot initialization
3. **Service lookups:** Always `pcall(Knit.GetService, ...)` — never bare calls
4. **Cross-service calls:** Use `task.defer()` if called during player join to avoid circular deps
5. **Deprecated APIs:** No `Ray.new()`, no `SoundService:CreateSound()` — use `workspace:Raycast()` and `Instance.new("Sound")`

## Phase Names (Use These Exact Strings)

```
"Collection" | "Construction" | "Quest" | "Nuisance" | "Rewards"
```

**There is NO "Combat" phase.** There is NO "Reflection" phase. These were removed.

## File Locations

- **Server services:** `src/server/Services/*.lua`
- **Client controllers:** `src/client/Controllers/*.lua`
- **Shared data:** `src/shared/*.lua`
- **Rojo config:** `default.project.json`
- **Full bible:** `docs/TECHNICAL_BIBLE.md`

## Common Gotchas

- `#dictionary` returns 0 in Lua — use a counter variable for dictionaries
- `pcall` returns `(ok, result)` — don't confuse the 2nd value with the original function's error param
- `Knit.GetService()` throws if the service doesn't exist — always wrap in pcall
- TownBlueprint district names must exactly match what TownGenerator expects
