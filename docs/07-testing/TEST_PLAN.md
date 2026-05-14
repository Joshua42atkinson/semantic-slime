# Semantic Slime - Playtesting Plan

This document outlines the structured playtesting strategy for Semantic Slime. Since the core game loop and crucial services are now functioning, the focus shifts from fixing critical engine bugs to refining the player experience.

## Phase 1: The "Family Test" (First-Time User Experience)

Have your kids play the game from a fresh start without you explaining how to play. Observe their actions to identify friction points:

1. **The Tutorial Flow**: 
   - Does the `TutorialUI` appear immediately?
   - Do they read Zog the guide, or skip it?
   - Is it obvious that they need to pick up glowing Letter Crystals?
2. **The Slime Fabricator**:
   - Do they know where to go to craft a word?
   - Is the UI intuitive enough for them to drag/click letters to form words?
   - Does the game accurately reward them with a new Slime Companion?
3. **Companions & Pet Service**:
   - Does the Slime follow them correctly without getting stuck?
   - Do they understand how to switch their active companion?

## Phase 2: The Core Game Loop Test

The game operates on timed phases managed by the `GameLoopService` taking players through: `Collection` → `Construction` → `Quest` → `Nuisance` → `Rewards`.

1. **Phase Transitions**:
   - Does the lighting naturally shift to match the phase (e.g., darker for Combat)?
   - Does the UI clearly tell the player what they should be doing right now?
   - Are the phase durations giving players enough time? (e.g., 45s for collection vs 90s for questing).
2. **Questing & NPC Interaction**:
   - Can they talk to NPCs like the Town Mayor or the Scholar?
   - Do they understand how to solve the "Mad Lib" or fill-in-the-blank style semantic puzzles?

## Phase 3: Stress Testing & Data Resilience

1. **Data Persistence**:
   - After they have collected 10+ letters and crafted a few slimes, have them leave the game and rejoin.
   - Do all slimes, letters, and levels restore perfectly via `DataService`?
2. **Device Performance**:
   - Roblox mobile players often face memory constraints. Since we have many parts (Crystals, complex Baseplate generations, multi-part trees), keep an eye on the `PerformanceMonitor` for any memory leaks or extreme lag spikes when new districts load.
3. **Multiplayer Chaos**:
   - Have more than one kid (or yourself and a kid) join the same server. 
   - Ensure you aren't picking up each other's UI elements or breaking the quests if two people talk to the same NPC.

## How to Log Playtest Feedback

When doing these tests, keep the `BUG_TRACKER.md` open and log issues into 3 categories:
1. **Game-Breaking Bugs** (e.g., "Screen froze when opening the Fabricator")
2. **UX Friction** (e.g., "Didn't know what Aether points are used for")
3. **Pedagogical Gaps** (e.g., "The synonym puzzle was too hard for an 8-year-old")
