# Vibe Coding in Antigravity: The Manifesto

## Philosophy
**Vibe Coding** is a high-bandwidth, flow-state development methodology where the **Human Creative Director** and the **AI Architect (Antigravity)** function as a single, hyper-efficient organism. It prioritizes **Vision**, **Aesthetics**, and **Momentum** over bureaucracy.

## The Roles

### 1. The Creative Director (User)
- **The Visionary**: Defines the *Soul* of the project.
- **The Sculptor**: Works in Roblox Studio. Builds the world, places props, adjusts lighting, and feels the "vibe."
- **The Judge**: Playtests and says "This feels right" or "This feels clunky."
- **Focus**: Experience, Art, Narrative, High-Level Logic.

### 2. The AI Architect (Antigravity)
- **The Engine**: Writes the code (Luau), manages the architecture, and enforces type safety.
- **The Technician**: Handles the "boring" stuff (Rojo sync, systemd, git).
- **The Librarian**: Maintains knowledge (this library), documents context, and ensures continuity.
- **Focus**: Systems, Stability, Syntax, Implementation.

## The Workflow Loop

1.  **Vibe Check (Planning / Spec)**:
    - User writes a **Spec**: *"I want the bridge to crumble if you use a 'weak' word."* (See [SDD](spec_driven_development.md))
    - Agent confirms understanding and aesthetics: *"Steampunk crumble? Particle effects?"*

2.  **The Thrust (Execution)**:
    - Agent implements the Spec in `src/`.
    - Rojo automatically syncs to Studio.
    - User *simultaneously* builds the bridge visual in Studio.

3.  **The Sync (Verification)**:
    - User hits "Play."
    - Immediate feedback.
    - "It works, but make it louder." -> Agent tweaks code -> User plays again.

## Antigravity Principles
1.  **Structure Enables Flow**: You can't vibe in chaos. We use [Spec-Driven Development](spec_driven_development.md) to keep the foundation solid so we can dance on top of it.
2.  **Aesthetics are Functional**: A generic UI is a broken UI. The code must produce beauty.
3.  **No Friction**: We do not write boilerplate. We script logic from specs.
4.  **Meta-Context**: We maintain `context.md` religiously. It is our shared memory.

## Using this Workflow
- **Keep Rojo Running**: `scripts/rojo-health.sh`.
- **Talk to the Agent**: Treat the AI as a senior partner, not a search engine. Discuss architecture.
- **Trust the Context**: Rely on the `brain/` artifacts to keep track of complexity so you can focus on the Vibe.
