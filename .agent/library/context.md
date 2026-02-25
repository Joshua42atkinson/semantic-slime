# The Iron Network — Project Context
> **READ THIS FIRST every session.** This is the single source of truth.
> **Last updated:** 2026-02-18 (Session: "The Local AI Architect" Complete)

---

## 🎯 The Most Important Thing Before Starting a New Session

1. **Is Rojo running?** → `bash scripts/rojo-health.sh`
2. **Is Studio connected?** → `localhost:34872`
3. **What's the next task?** → **Record the 20-Minute Video.** (See "Next Session" below).

---

## Current Module: "The Local AI Architect" 🎓

We have built a **20-minute E-Learning Game** that teaches teachers how to use Antigravity + Roblox.
It follows the isomorphic loop: **Plan → Generate → Playtest → Iterate.**

### 1. Level 1: The Connection Room (Hub)
-   **Goal:** Teach the Rojo workflow (Install → Serve → Connect).
-   **Mechanic:** **Cable Panel** (3 switches) that sparks when connected.
-   **Teaching:** Large Billboards explain each step. Completion toast teaches "Sync".
-   **System:** `CablePanel.server.luau` + `WordSocket.client.luau`.

### 2. Level 2: The Forge Room (Logos District)
-   **Goal:** Teach generative AI creation.
-   **Mechanic:** **Forge Terminal** (Text Input) where teachers type a lesson plan.
-   **Juice:** Animated build log ("Generating Geometry...") + Magic Smoke particles.
-   **Payoff:** The entire district regenerates with a new architectural style.
-   **System:** `ForgeTerminal.server.luau` + `ForgeUI.client.luau`.

### 3. Level 3: The Playtest Chamber (Eros/Soma)
-   **Goal:** Teach iterative design.
-   **Mechanic:** **Glitch Fix** (Debug Tool) + **Architect's Log** (G-Key Feedback).
-   **Flow:** Fix a bug → Write an improvement note → Complete the course.
-   **System:** `GlitchService.lua` + `ArchitectLog.client.luau`.

---

## Core Systems (New)

### 🧭 Waypoint System (Navigation)
-   **File:** `Waypoint.client.luau`
-   **Feature:** Shows a **pulsing gold beam** at the next objective location.
-   **UX:** Includes a billboard label and a screen-space distance indicator.
-   **Crucial:** Use this for ANY new quest to guide players.

### 🎮 LessonService (Orchestrator)
-   **File:** `LessonService.lua`
-   **Feature:** Tracks player progress (Levels 1-3).
-   **API:** `OnCableComplete`, `OnForgeUsed`, `OnFeedbackWritten`.
-   **State:** Simple integer state machine.

### ✨ Visual Polish (Juice)
-   **Particles:** Green Sparks (Cables), Magic Smoke (Forge).
-   **Audio Hooks:** `playSound("rbxassetid://...")` added to all client scripts.
-   **Readability:** All UI fonts bumped to 16px-24px.

---

## File Structure (Updated)

```
rojo/src/
├── shared/
│   ├── QuestData.lua        ← Level Definitions & Dialogue
│   └── NPCData.lua          ← Teacher NPC Dialogue
├── server/
│   ├── Services/
│   │   ├── LessonService.lua    ← Core Game Loop
│   │   └── TownGenerator.lua    ← World Regen Logic
│   └── Scripts/
│       ├── CablePanel.server.luau   ← L1 Mechanic
│       ├── ForgeTerminal.server.luau ← L2 Mechanic
│       └── StyleSwitcher.server.luau ← L2 Fallback
├── client/
│   ├── Scripts/
│   │   ├── Waypoint.client.luau     ← Navigation Beams
│   │   ├── WordSocket.client.luau   ← L1 UI
│   │   ├── ForgeUI.client.luau      ← L2 UI
│   │   └── ArchitectLog.client.luau ← L3 UI
│   └── HUD.client.luau              ← Progress Bar
```

---

## Next Session: Recording & Audio 🎬

The mechanics and visuals are done. The next phase is **Production**.

**Priorities:**
1.  **Audio Assets:** Upload SFX and wire them into the `playSound` hooks.
2.  **Narration Recording:** Record the voiceover script.
3.  **Video Capture:** Record the 20-minute playthrough.

**Handover Prompt:**
*"I have reviewed the `context.md`. The 'Local AI Architect' build is stable and polished. Let's start the Recording Phase. Do we have the SFX assets ready to plug into the audio hooks?"*
