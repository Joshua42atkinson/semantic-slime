# Roblox Game Dev — Best Practices Reference
> This is the standing rulebook for all games in this project. Read alongside context.md.

---

## 1. Agentic Workflow

### The Loop
```
Antigravity writes code → Rojo syncs (< 1 sec) → You playtest in Studio → Feedback → repeat
```

### Session Start Checklist
- [ ] `rojo serve` running? (check port 34872)
- [ ] Read `.agent/context.md` for current game state
- [ ] Read `src/shared/GameConfig.lua` to recall tunables

### Your Role vs Antigravity's Role
| You (Creative Director) | Antigravity (Engineer) |
|---|---|
| Set the vision & lesson goals | Write all Luau scripts |
| Sculpt terrain in Studio | Design system architecture |
| Place NPCs & props | Wire all RemoteEvents |
| Playtest & judge feel | Fix bugs & iterate |
| Upload style documents | Enforce code standards |

---

## 2. Code Architecture

### Folder Structure (always)
```
src/
├── shared/     ← Pure data modules. No game:GetService() here.
│   ├── GameConfig.lua   ← ALL tunables live here
│   └── QuestData.lua    ← ALL content (dialogue, quizzes)
├── server/     ← Services. Server-authoritative. One script per system.
│   ├── GameManager.server.luau
│   └── [SystemName].server.luau
└── client/     ← Controllers. UI + input only. Never trust client data.
    ├── HUD.client.luau
    └── [FeatureName].client.luau
```

### Golden Rules
1. **Server is truth.** All game state lives on server. Client only *requests* and *displays*.
2. **One script, one job.** GameManager manages quests. NPCTeacher manages proximity. Never mix.
3. **Config over code.** If it's a number or string a designer might change, it goes in `GameConfig.lua`.
4. **Events, not polling.** Use `RemoteEvent`/`BindableEvent`. Only poll for proximity (Heartbeat).
5. **`--!strict` on all new scripts.** Catches bugs before runtime.
6. **Guard clauses over nesting.** `if not x then return end` beats 4 levels of `if/else`.

### Naming Conventions
| Thing | Convention | Example |
|---|---|---|
| Services / Controllers | PascalCase | `GameManager`, `HUDController` |
| Local variables | camelCase | `playerData`, `questStage` |
| Constants | UPPER_SNAKE | `MAX_PLAYERS`, `INTERACT_DISTANCE` |
| RemoteEvents | PascalCase verb | `QuestComplete`, `TalkToNPC` |
| Module returns | PascalCase table | `GameConfig.Colors.Primary` |

---

## 3. Educational Game Design

### Cognitive Load Framework
Every design decision must pass this test:

| Load Type | What it is | How to minimize |
|---|---|---|
| **Extraneous** | Confusion from bad UI/UX | Intuitive interface, no jargon |
| **Intrinsic** | Complexity of the subject | One concept per quest, chunked info |
| **Germane** | Deep learning effort | Mechanic = lesson (orbs = training data) |

### Quest Design Template
Every quest must have:
- **One** learning objective (not two)
- A mechanic that *embodies* the concept (not just describes it)
- Immediate feedback (correct/wrong, not delayed)
- A reward that feels earned (badge, unlock, narrative beat)
- A bridge to the next quest ("Now that you know X, let's explore Y...")

### Content Rules
- Students skip walls of text → **max 2 lines per dialogue beat**
- Use metaphor first, definition second
- Never use the word "wrong" — use "not quite" or "look again"
- Positive reinforcement on every correct action

---

## 4. Aesthetic System — Yin-Yang Balance

### The Two Poles
| Element | High Fantasy (Yin) | Dark Steampunk (Yang) |
|---|---|---|
| **Color** | Indigo, gold, soft violet | Charcoal, copper, amber |
| **Shape** | Organic, flowing, curved | Angular, riveted, mechanical |
| **Texture** | Luminescent, ethereal | Weathered brass, iron, leather |
| **Typography** | Serif, illuminated | Monospace, typewriter |
| **Sound** | Chimes, wind, nature | Gears, steam, mechanical clicks |

### Where Each Pole Lives
- **World/Narrative** → Fantasy (wonder, exploration)
- **UI Chrome** → Steampunk (structured, grounding, mechanical)
- **Learning Content** → Neutral (clean, high contrast, zero aesthetic noise)

### Color Palette (Roblox hex)
```lua
-- Fantasy
Gold    = "F59E0B"   -- arcane amber
Indigo  = "4F46E5"   -- deep magic
Violet  = "7C3AED"   -- mystical purple
Glow    = "EEF2FF"   -- soft light

-- Steampunk
Copper  = "B45309"   -- aged brass
Iron    = "374151"   -- dark metal
Charcoal= "1F2937"   -- deep background
Steam   = "9CA3AF"   -- grey mist

-- Neutral (learning content)
White   = "FFFFFF"
TextBg  = "1E1B4B"   -- dark navy (readable)
```

### The Cognitive Load Rule for Aesthetics
> **Aesthetic complexity must be inversely proportional to content complexity.**
> When the lesson is hard, the visuals must be simple.
> When the world is being explored, the visuals can be rich.

---

## 5. Security Checklist (every game)

- [ ] All game state mutations happen server-side only
- [ ] Client RemoteEvents are validated on server (stage check, distance check)
- [ ] No `loadstring()` or `require()` from untrusted sources
- [ ] `FilteringEnabled = true` in Workspace (already set in project.json)
- [ ] Leaderstats are set server-side only

---

## 6. Performance Rules

- Use `task.wait()` not `wait()` (deprecated)
- Use `task.spawn()` for fire-and-forget coroutines
- Destroy UI elements when not needed (don't just hide them if they're complex)
- Heartbeat proximity checks: only run when NPC exists in workspace
- TweenService for all animations (never loop-animate with wait())
