# 📋 Semantic Slime — Game Content Backlog

> **Purpose:** Engineering-focused list of all game content that needs building.
> **Created:** 2026-02-27 (derived from full code review)
> **Priority Key:** 🔴 P0 (game is broken), 🟡 P1 (minimum viable game), 🟢 P2 (polish), 🔵 P3 (post-launch)

---

## 🔴 P0: Critical Bug Fixes (Game Crashes Without These)

| # | Task | File(s) | Est. | Depends On |
|---|------|---------|------|------------|
| [x] | Move `grantObjectiveBonus` above `incrementProgress` | `GameLoopService.lua` | 2 min | — |
| [x] | Move `generateSignatureMove` above `AddContextPoints` | `SlimeFactory.lua` | 2 min | — |
| [x] | Remove duplicate Remote creation from `Boot.server.luau` (keep `Remotes.luau` only) | `Boot.server.luau` | 5 min | — |
| [x] | Fix `buildNarrative` arg: pass `quest.Slots` not single `slot` | `MadLibService.lua:286` | 1 min | — |
| [x] | Wire `getPhaseDuration()` into `setPhase()` | `GameLoopService.lua` | 1 min | — |

**Total P0: ~11 minutes of work**

---

## 🟡 P1: Minimum Viable Game (Content Gaps That Make Game Feel Empty)

### 1.1 Vocabulary Database Expansion

The game is an **educational vocabulary game** but only has **5 words** in `WordDatabase` and **~30** in `SynonymDatabase`.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| [x] | Expand `WordDatabase` to 100+ entries with psycholinguistic metrics | `WordDatabase.lua` | 2 hr | Add Concreteness, AoA, Valence, Arousal, Dominance for each |
| [x] | Expand `SynonymDatabase` to 200+ entries | `SynonymDatabase.lua` | 3 hr | Each entry: 4 synonyms, 2 antonyms, 3 distractors, element, difficulty |
| 8 | Add grade-level tagging (`"3-5"`, `"6-8"`, `"9-12"`) | `SynonymDatabase.lua`, `WordDatabase.lua` | 30 min | Enables curriculum-aligned content |
| [x] | Add `EtymologyDB` roots beyond initial 6 | `EtymologyDB.lua` | 1 hr | Currently: Ignis, Aqua, Terra, Aer, Umbra, Lux. Need 12+ roots |
| [x] | Add more suffixes beyond initial 9 | `EtymologyDB.lua` | 30 min | Currently: -tion, -ity, -ment, -ize, -ate, -fy, -ous, -al, -ive |

### 1.2 Input Validation & Security

Per Roblox Education guidelines, **all RemoteFunctions must validate inputs**.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| [x] | Add type-checking to all `OnServerInvoke` handlers | `CrystalService`, `SlimeFactory`, `LureService`, `MadLibService` | 45 min | Check `typeof(arg)`, string length limits, number ranges |
| [x] | Add distance checks to crystal/slime interactions | `CrystalService.lua` | 15 min | Players must be within 20 studs to collect |
| [x] | Add rate limiting to `CollectCrystal`, `UseLetters` | `CrystalService.lua`, `SlimeFactory.lua` | 30 min | Max 1 call per 0.5s per player |

### 1.3 Interactive Battles (Replace Auto-Resolve)

The current battle system auto-resolves — players have no agency.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| [x] | Wire `ExecuteAction` into `ProcessBattle` loop | `BattleService.lua` | 1 hr | Replace auto-fight with turn-based player input (Rap Battles!) |
| [x] | Add `BattleUI` action buttons (Attack/Defend/Special/Flee) | `BattleUI.lua` | 1 hr | Replaced with Semantic Words Input Box |
| [x] | Add damage preview before confirming action | `BattleUI.lua` | 30 min | Show estimated damage to help player learn |
| [x] | Add battle timer per turn (15s default action) | `BattleService.lua` | 20 min | Auto-defend if player doesn't choose |

### 1.4 Quest Content

Mad-Libs quests exist but content is thin.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| [x] | Write 20+ Mad-Lib quest templates by archetype | `QuestData.lua`, `QuestDefinitions.lua` | 2 hr | Hero/Mentor/Trickster/Shadow/Herald templates |
| [x] | Create per-NPC quest chains (11 NPCs × 3 quests) | `QuestData.lua` | 3 hr | District-themed, escalating difficulty |
| [x] | Implement `GetSlotSuggestions` (currently returns `{}`) | `MadLibService.lua:358` | 30 min | Should recommend matching slimes from inventory |

### 1.5 Fix Broken Controllers

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| [x] | Convert `InteractionController` to proper Knit controller | `InteractionController.lua` | 15 min | Use `Knit.CreateController`, add `KnitStart` |
| [x] | Wire `WordConstructorController` end-to-end | `WordConstructorController.lua` | 1 hr | Letter inventory → spell word → create slime → visual feedback |
| [x] | Fix B-key double toggle (Inventory + Quest Log) | `HUDController.lua:426-428` | 2 min | Remove the `self:ToggleQuestLog()` call from B-key handler |

---

## 🟢 P2: Polish Content (Makes Game Feel Complete)

### 2.1 Tutorial & Onboarding

New players currently have no guidance.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| 24 | Create tutorial quest chain: Collect → Construct → Quest → Battle | `TutorialUI.lua`, new `TutorialService.lua` | 3 hr | Step-by-step first-experience with waypoints |
| 25 | Add tooltip system for HUD elements | `HUDController.lua` | 1 hr | Hover tooltips explaining each UI element |
| 26 | Add first-spawn welcome cutscene | New `CutsceneController.lua` | 2 hr | Camera pan of Syllable Springs + NPC intro |

### 2.2 Slime Companion (Pet) System

Pet system is designed but not implemented.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| 27 | Implement `PetController` follow behavior | `PetController.lua` | 2 hr | Smooth lerp follow, idle animations |
| 28 | Add "Set Companion" button to `SlimeCollectionUI` | `SlimeCollectionUI.lua`, `SlimeFactory.lua` | 1 hr | Server validation + client visual |
| 29 | Add idle dialogue system (element-based) | `PetController.lua` | 1 hr | Random speech bubbles from element word lists |

### 2.3 Achievements & Meta-Progression

No long-term goals beyond XP.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| 30 | Define 20+ achievements | New `AchievementData.lua` | 1 hr | First Slime, Collector 10, Word Master 100, etc. |
| 31 | Add achievement tracking to `DataService` | `DataService.lua` | 1 hr | Store `Achievements`, `WordsDiscovered`, `ElementUsage` |
| 32 | Create achievement popup notification | `HUDController.lua` | 45 min | Gold banner with achievement name + icon |
| 33 | Create achievement gallery UI | New `AchievementUI.lua` | 2 hr | Grid of locked/unlocked achievements |

### 2.4 Sound & Music

SoundController exists but content is limited.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| 34 | Add per-district ambient loops | `SoundManager.luau` | 1 hr | BrainyBorough=library, HeartwoodGrove=nature, etc. |
| 35 | Add phase transition sound effects | `SoundManager.luau` | 30 min | Dawn chime, day energy, dusk calm, night tension |
| 36 | Add battle SFX (attack, defend, defeat, victory) | `SoundManager.luau` | 45 min | One per action type |
| 37 | Add capture/lure SFX | `SoundManager.luau` | 20 min | Success jingle, fail buzz |

### 2.5 Shop System

Store says "coming soon."

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| 38 | Implement `StoreService` with Insight currency | `StoreService.lua` | 2 hr | Buy: lure rerolls, crystal spawners, cosmetics |
| 39 | Create `StoreUI` with item grid & purchase flow | `StoreUI.lua` | 2 hr | Dark glass aesthetic matching game theme |
| 40 | Wire Gacha system to store (currency check) | `GachaService.lua`, `StoreService.lua` | 30 min | Single pull = 50 Insight, Multi = 400 |

### 2.6 Admin & Dev Tools

No debug commands for testing.

| # | Task | File(s) | Est. | Details |
|---|------|---------|------|---------|
| 41 | Create `DevCommandService` with chat commands | New `DevCommandService.lua` | 2 hr | /phase, /extend, /skip, /spawn, /givxp |
| 42 | Add adminList whitelist | `DevCommandService.lua` | 15 min | Only authorized UserIds can use |

---

## 🔵 P3: Stretch Content (Post-Launch)

| # | Task | Est. | Details |
|---|------|------|---------|
| 43 | Sentence Combos (deploy 3 slimes as Subject-Verb-Object) | 5 hr | Ultimate attack system |
| 44 | Player trading system | 4 hr | Trade slimes in the Hub |
| 45 | Global "First Discoverer" leaderboard | 3 hr | Who found a word first on the server |
| 46 | Wilderness zones with dynamic terrain spawn rates | 5 hr | Expanded map beyond town |
| 47 | NPC relationship system (friendship levels) | 4 hr | Unlock NPC backstory through repeated interaction |
| 48 | Time-of-day visual cycle (Dawn/Day/Dusk/Night lighting) | 2 hr | LightingService phases match game phases |
| 49 | Solo play mode (pause timer for practice) | 2 hr | Per-player timer freeze |
| 50 | Word journal / dictionary UI | 3 hr | Track all discovered words with etymology |

---

## 📊 Summary

| Priority | Items | Est. Total Time |
|----------|-------|-----------------|
| 🔴 P0 Bug Fixes | 5 | ~15 min |
| 🟡 P1 Minimum Viable | 18 | ~18 hr |
| 🟢 P2 Polish | 17 | ~24 hr |
| 🔵 P3 Stretch | 8 | ~28 hr |
| **Total** | **48 items** | **~70 hr** |

---

## 🏁 Recommended Build Order

```
Week 1:  P0 bugs (15 min) → Vocabulary expansion (#6-10) → Input validation (#11-13)
Week 2:  Interactive battles (#14-17) → Quest content (#18-20) → Controller fixes (#21-23)
Week 3:  Tutorial (#24-26) → Sound (#34-37) → Achievements (#30-33)
Week 4:  Pet system (#27-29) → Shop (#38-40) → Admin tools (#41-42)
```

> [!TIP]
> **The single highest-impact change is vocabulary expansion (#6-7).** The game is a vocabulary game with only 5 words in WordDatabase. Adding 100+ words transforms it from a tech demo into a real learning tool.

---

*This backlog should be treated as a living document. Check off items as they're completed and update estimates as you learn more.*
