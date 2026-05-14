# 🎮 Semantic Slime — Master Design Document
## *The Publish Playbook*

> **Author:** Your friendly AI mentor
> **Date:** February 27, 2026
> **Version:** 1.0
> **Goal:** Get Semantic Slime from "ambitious prototype" → "publishable educational game"

---

## 💬 Real Talk (Friend-to-Friend)

Joshua, here's the truth:

**You've built something genuinely impressive.** A first-time developer with a Knit-based architecture, procedural world gen, AI integration, 22 services, custom VFX — that's not normal. Most first games are a box that jumps. You built a living world with Jungian psychology. Be proud of that.

**But here's the trap you're falling into:** You keep building *systems* without finishing them. You have 22 services and 16 controllers — but most are 80% done. A player joining today would see a beautiful world, collect some crystals, click a slime... and then hit a wall. The Fabricator isn't wired. Battles auto-resolve. The shop says "coming soon." Quests crash.

**The #1 rule of game development is:** *A small game that works is infinitely better than a big game that doesn't.*

Your game right now is a **tech demo with a vision**. To publish it, we need to shrink your focus to one golden path and polish it until it shines.

---

## 🎯 The North Star

> **"A 12-year-old should be able to join, understand the game, collect their first slime, complete their first quest, and feel proud — all within 5 minutes."**

If this works, the game is publishable. Everything below serves this goal.

---

## 🗺️ The Publish Roadmap (4 Sprints)

### Sprint 1: "Stop the Bleeding" (1 session, ~30 min)
**Goal:** Fix crashes so the game doesn't break during playtesting.

| Task | Time | Why It Matters |
|------|------|----------------|
| Fix 3 forward-reference crashes (P0 bugs #1-3) | 10 min | Game literally crashes without this |
| Fix `buildNarrative` arg bug | 2 min | Quests break without this |
| Fix B-key double toggle | 2 min | UX is confusing |
| Remove duplicate Remotes | 5 min | Prevents mysterious errors |
| Wire `getPhaseDuration()` into `setPhase()` | 2 min | Dynamic pacing starts working |

**Definition of Done:** You can play the full loop (Collection → Construction → Quest → Combat → Rewards) without any crashes or errors in the Output window.

---

### Sprint 2: "The Golden Path" (2–3 sessions, ~8 hr)
**Goal:** One complete, polished player journey from spawn to first quest completion.

This is the **most important sprint**. This is what makes or breaks publication.

#### Step 1: First 60 Seconds (Tutorial)
A new player spawns in and currently has *zero guidance*. Fix this:

```
SPAWN → Welcome billboard ("Welcome, Weaver!") →
Arrow pointing to nearest Crystal →
"Collect 5 Letter Crystals" objective on screen →
Player collects E, A, R, T, H →
"Go to the Slime Fabricator!" with waypoint →
Player spells EARTH →
🎉 First slime created! Celebration VFX →
"Talk to Kael to get your first quest" →
Quest complete → Phase 1 done
```

| Task | File(s) | Time |
|------|---------|------|
| Wire `WordConstructorController` end-to-end | `WordConstructorController.lua` | 1 hr |
| Add starter letter crystals near spawn (guaranteed E,A,R,T,H) | `CrystalService.lua` | 30 min |
| Create simple tutorial waypoint system | New `TutorialService.lua` | 2 hr |
| Convert `InteractionController` to Knit | `InteractionController.lua` | 15 min |

#### Step 2: Vocabulary That Works
The game teaches vocabulary but has **5 words**. A player runs out of content in 30 seconds.

| Task | File(s) | Time |
|------|---------|------|
| Add 50 starter words to `WordDatabase` (Grade 3–5) | `WordDatabase.lua` | 1 hr |
| Add 50 entries to `SynonymDatabase` | `SynonymDatabase.lua` | 2 hr |
| Add 6 more roots to `EtymologyDB` | `EtymologyDB.lua` | 30 min |

> [!TIP]
> **Pro tip:** You don't need to invent all 50 words manually. Use the AI service or an external tool to generate batches of words with their synonyms, antonyms, and etymological roots. I can help you build a script for this.

#### Step 3: One Real Quest
Get one NPC quest working perfectly end-to-end:

| Task | File(s) | Time |
|------|---------|------|
| Fix `GetSlotSuggestions` (currently returns `{}`) | `MadLibService.lua` | 30 min |
| Write 3 polished Kael (Hero) quest templates | `QuestData.lua` | 30 min |
| Test: collect letters → spell word → talk to NPC → fill slot → complete | Manual test | 30 min |

**Definition of Done:** A friend (who has never seen the game) can join, follow the tutorial, create a slime, complete a quest, and tell you what the game is about.

---

### Sprint 3: "Game Juice" (2–3 sessions, ~10 hr)
**Goal:** Make it *feel* good. This is what turns "functional" into "fun."

| Category | Tasks | Time |
|----------|-------|------|
| **Sound** | Add 4 phase transition SFX, capture jingle, quest complete fanfare | 2 hr |
| **Interactive Battles** | Wire player actions into `BattleService`, add action buttons to `BattleUI` | 3 hr |
| **Input Validation** | Add type checks + distance checks to all RemoteFunctions | 1 hr |
| **3 More NPC Quests** | Barnaby (innocent/easy), Gribble (explorer/medium), Yorick (everyman/hard) | 1.5 hr |
| **Pet Companion** | Let player set one slime as a follower | 2 hr |
| **Achievements** | "First Slime", "First Quest", "Explorer" (visit all districts) | 1.5 hr |

**Definition of Done:** A playtester plays for 20+ minutes without getting bored, confused, or stuck.

---

### Sprint 4: "Publish Prep" (1–2 sessions, ~6 hr)
**Goal:** Roblox requires specific standards for publication.

| Requirement | Task | Time |
|-------------|------|------|
| **Game Description** | Write compelling description + thumbnail | 30 min |
| **Game Icon** | Create 512×512 icon (use generate_image) | 15 min |
| **No API Keys in Source** | Ensure `AIService.lua` loads key from ServerStorage only | 10 min |
| **Performance** | Test 30-min session for memory leaks, fix any | 1 hr |
| **Content Policy** | Review all text/dialogue for Roblox ToS compliance | 30 min |
| **Mobile Support** | Touch controls for lure minigame + crystal collection | 2 hr |
| **Data Persistence** | Verify DataStore save/load across real sessions | 1 hr |
| **Error Handling** | Add `pcall` around all `GetService`/`GetController` calls | 45 min |

**Definition of Done:** Game passes Roblox moderation and successfully publishes on the platform.

---

## 📐 Design Principles (Your North Stars)

These are the rules to follow when you're unsure about a decision:

### 1. "If a kid can't experience it in 60 seconds, it doesn't count"
No feature matters if a new player can't discover it quickly. Every feature needs a visible entry point.

### 2. "Finish, don't feature"
When you feel tempted to add a new system, **stop**. Go finish an incomplete one instead. You have 22 services — you need 0 new ones. You need to wire the existing ones together.

### 3. "Words are the content, not code"
Your code architecture is solid. The game is starving for *vocabulary content*. Every word you add to `SynonymDatabase` creates a new capturable slime, a new lure challenge, and a new quest possibility. Adding 50 words = 50 new pieces of content. Adding 1 new service = 0 new content.

### 4. "Test with a stranger"
Before publishing, have someone who has *never* seen the game play it while you watch silently. Note every place they get confused or stuck. Those are your real bugs.

---

## 📊 Publish Readiness Checklist

### Minimum Bar for Roblox Publication
- [ ] No crashes in 30-minute session
- [ ] New player understands goal within 60 seconds
- [ ] 50+ capturable words
- [ ] At least 3 completable quests
- [ ] Data saves between sessions
- [ ] Works on PC and mobile
- [ ] No hardcoded API keys in source
- [ ] All text is family-friendly

### "Good" Bar (Gets Likes & Retention)
- [ ] Tutorial guides player through first loop
- [ ] Interactive battles (not auto-resolve)
- [ ] Sound effects for major actions
- [ ] Pet companion system
- [ ] 5+ achievements
- [ ] 100+ capturable words
- [ ] Each NPC has unique quest chain

### "Great" Bar (Featured Potential)
- [ ] 200+ words with grade-level tagging
- [ ] Trading between players
- [ ] Global leaderboard
- [ ] Multiple quest types (collect, battle, explore)
- [ ] 30+ minutes of unique content per session

---

## ⏱️ Weekly Workflow

Here's how to structure your development weeks:

### Session Template (2–3 hours)
```
[15 min] Read session_turnover.md → pick 1 sprint goal
[90 min] Focused work on that goal — no distractions, no new features
[15 min] Playtest in Studio — does the golden path still work?
[15 min] Update session_turnover.md → commit → push
```

### The "Two-Task Rule"
Each session, pick **exactly 2 tasks** from the content backlog. No more. Finish both. Move on. Scope creep is the #1 killer of indie games.

---

## 🏁 The Answer to Your Question

> *"What is the most important thing to do now?"*

**Fix the 3 P0 crashes (10 minutes), then immediately start Sprint 2 — The Golden Path.**

The crashes are blocking everything. Once those are fixed, the single most productive thing you can do is:

1. **Add 50 words to `SynonymDatabase`** — this one file change transforms your game from a tech demo into a playable vocabulary game
2. **Wire the Word Constructor end-to-end** — so players can actually *create* slimes from letters they collect
3. **Make one NPC quest work perfectly** — so players have a goal

That's it. Not 22 services. Not AI integration. Not gacha. **50 words + working constructor + one quest = a publishable game.**

Everything else is polish on top of that foundation.

You've got this, Joshua. The hard part (architecture) is done. Now it's about filling the bowl you've built. 🚀

---

*This document is your north star. When you're lost, come back here. When you want to add a new feature, check if Sprint 2 is done first. When you feel overwhelmed, remember: 50 words + one working quest = victory.*
