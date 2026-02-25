# Industrialized Vibe Coding: The Antigravity Manifesto

> **Goal:** Move from "Manual Crafting" (placing parts by hand) to "Industrial Manufacturing" (scripting worlds).
> **Platform:** Linux (Vinegar + Rojo + AI).

## 1. The "OMNI Model" Workflow
You asked about building an AI agent that sees your screen. While a fully autonomous "Vision Agent" is cutting-edge (and complex), we can **approximate it today** using the **Text-to-Engine Pipeline**:

1.  **The Brain (Antigravity/LLM):** Designs the world in **Text/Code** (Lua/JSON).
2.  **The Factory (Rojo):** Instantly converts that Text into **Roblox Assets**.
3.  **The Viewport (Studio/Vinegar):** Renders the result for you to verify.
4.  **The Loop:** You screenshot the result -> Feed it back to the AI -> AI tweaks the Text.

This *is* the OMNI model, just with a manual "Vision" step (you are the eyes).

## 2. Tools of the Trade (Linux Edition)

| Tool | Purpose | Status |
| :--- | :--- | :--- |
| **Vinegar** | Runs Roblox Studio on Linux (Wine wrapper). | ✅ Essential |
| **Rojo** | Syncs filesystem (VS Code/Cursor) to Studio. | ✅ Essential |
| **Cursor / Zed** | AI-native IDEs for "Vibe Coding". | 🚀 Recommended |
| **Tarmac** | Asset Manager (images/meshes) -> Rojo. | 📦 Advanced |
| **Lune** | Standalone Luau script runner (for build scripts). | 🛠️ Industrial |

## 3. Industrial World Building Strategy
To "industrialize" the build, we stop treating the world as a **Canvas** and start treating it as **Data**.

### Phase 1: The Blueprint (Procedural)
*What we have now.*
-   **Method:** Scripts like `TownSpawner.server.luau` generate the map on runtime.
-   **Pros:** Fast, version-controllable, easy for AI to edit.
-   **Cons:** "Fake" (disappears when game stops).

### Phase 2: The "Baker" (Persistent)
*The bridging step.*
-   **Method:** We write a plugin that takes the `TownSpawner` output and **pastes it** into a permanent Folder.
-   **Pros:** Best of both worlds. AI designs it; you "bake" it to make it real.

### Phase 3: The "Director" (Live AI)
*The future.*
-   **Method:** An HTTP Server inside Roblox (`HttpService`) listens to an external Python/LLM script.
-   **Action:** You type "Make the tower taller" into a terminal -> LLM updates the `Blueprint.json` -> Rojo syncs -> Tower grows in real-time.

## 4. Immediate Implementation Plan
We will implement **Phase 2 (The Baker)** methodology immediately.

1.  **Data-Driven Design:** Move hardcoded values from `TownSpawner` into a `TownBlueprint` ModuleScript.
2.  **AI Interface:** This allows you (or Antigravity) to simply edit the *Data* to change the world, rather than writing Complex Loops.
3.  **Baking:** We keep the current "Runtime Generation" for now, but aim to bake it later.

---

## 5. Visual Tools & Marketplace
-   **Midjourney / DALL-E:** Generate textures/skyboxes.
-   **Meshy / Rodin:** Generate 3D meshes from text.
-   **Roblox Marketplace:** Use it for "Base Materials" but use AI to assemble them.

## 6. Visual Verification (The "Blind Architect" Protocol)
Because Antigravity (the AI) cannot see the screen, **You are the Eyes.**
1.  **Generate:** AI writes the Blueprint/Script.
2.  **Sync:** Rojo updates Studio instantly.
3.  **Critique:** You look at the 3D viewport.
    -   *Does it look pro?* -> "No, the tower is too short."
    -   *Does it vibe?* -> "Yes, but make it redder."
4.  **Iterate:** You tell the AI, the AI updates the code.

### Aesthetics Strategy (Greybox vs. Art Pass)
-   **Stage 1: Greybox (Current):** Simple colored blocks to prove the *Layout* and *Logic* work. It looks "dev", not "pro".
-   **Stage 2: Art Pass (Future):** We replace the `Part` blocks with high-quality Meshes/Models.
    -   *Method:* You manually build a beautiful "Library" model -> save it as `LibraryAsset` -> We update the script to spawn *that* instead of a block.

**The Golden Rule:**
*If you have to click it more than twice, script it.*
