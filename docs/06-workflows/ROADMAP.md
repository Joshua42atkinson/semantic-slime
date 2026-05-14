# Roadmap — Semantic Slime

> **Goal:** A playable, publishable Roblox game that kids actually enjoy.

## Current Status: Alpha (Not Yet Playable End-to-End)

**What exists:** 36 server services, 21 client controllers, procedural town, 12 NPCs, word/slime pipeline.  
**What's missing:** Nobody has played through the full loop yet. No verified Collection→Construction→Quest→Battle→Rewards cycle.

---

## Sprint 1: Boot & Play (Current)

> _Can we press Play and walk around without errors?_

- [ ] Verify full game boot in Roblox Studio (0 errors in Output)
- [ ] Walk around Syllable Springs — all 7 districts render
- [ ] Interact with at least 1 NPC (dialogue opens and closes)
- [ ] Open the HUD, inventory, and Word Constructor UI
- [ ] Fix any errors discovered during these tests

**Exit criteria:** A clean Studio session with no red errors and basic interaction working.

---

## Sprint 2: The Loop

> _Can one player complete the core game loop once?_

- [ ] Collect 5+ letter crystals from the world
- [ ] Open Word Constructor, spell a valid word, create a slime
- [ ] Accept a quest from an NPC (Mad-Lib with slots)
- [ ] Fill at least 1 quest slot with owned slime
- [ ] Complete the quest, receive rewards (XP / Insight)
- [ ] Verify data persists across rejoin (DataService)

**Exit criteria:** One human plays through Collection → Construction → Quest → Rewards.

---

## Sprint 3: Data Quality

> _Is the educational content actually correct?_

- [ ] Audit `EtymologyDB.lua` — roots/suffixes map to correct elements/roles
- [ ] Audit `WordDatabase.lua` — spot-check 50 words for validity
- [ ] Audit `SynonymDatabase.lua` — verify synonym/antonym pairs are real
- [ ] Audit `QuestData.lua` — Mad-Lib templates make grammatical sense
- [ ] Audit `NPCData.lua` — dialogue is appropriate for ages 12–18

**Exit criteria:** A teacher would not be embarrassed showing this to students.

---

## Sprint 4: Polish

> _Does it feel good to play?_

- [ ] Sound effects play correctly (crystal pickup, word creation, battle hits)
- [ ] Music plays per district (no silence, no overlapping tracks)
- [ ] UI is readable on mobile (touch targets, responsive layouts)
- [ ] NPC dialogue feels natural (no placeholder text)
- [ ] Town visuals: lighting, particle effects, terrain look intentional
- [ ] Tutorial guides new players through first word creation

**Exit criteria:** A 13-year-old can figure out what to do without being told.

---

## Sprint 5: Multiplayer & Battle

> _Does the competitive loop work?_

- [ ] Two players can see each other in the world
- [ ] Two players can compete for the same quest slot
- [ ] Battle system resolves turn-by-turn with visual feedback
- [ ] Winner fills the quest slot, loser gets consolation XP
- [ ] No desync or data corruption with 2+ players

**Exit criteria:** Two kids can play together and have fun.

---

## Sprint 6: Ship It

> _Is it ready for real players?_

- [ ] Game page setup on Roblox (name, description, tags)
- [ ] Thumbnail and icon art
- [ ] Performance check: 60 FPS on mid-range devices
- [ ] Memory usage < 200MB
- [ ] No exploitable remote events
- [ ] Publish to Roblox — open beta

**Exit criteria:** Live on Roblox. Real players. Real feedback.

---

## Someday / Maybe

These are real features from the design doc. They are not Sprint 1–6 work.

- Evolution system (Normal → Cosmic)
- Guild/Lexicon system
- Trading marketplace
- AI-generated gacha slimes
- Seasonal events
- School/classroom integration
- Analytics dashboard
