---
description: The Lazy Developer's Guide to Building the Psyche-Polis
---

# The Lazy Dev Workflow
> "Water flows in the path of least resistance."

This workflow is designed for teachers and developers who want maximum results with minimum manual labor.

## 1. The "Instant World" Button
We use a **Procedural Spawner** (`TownSpawner.server.luau`) to generate the game world every time the server starts.
- **Why?** You don't need to manually place 50 parts. You don't need to align things. The code does it for you.
- **How?** just press **Play** in Roblox Studio. The Town of Psyche-Polis will appear automatically.

## 2. customizing the World (The Lazy Way)
If you want to change a building's color or an NPC's name:
1. Don't touch the map in Studio.
2. Edit **`src/shared/NPCData.lua`**.
3. Change `Color`, `Name`, or `DialogueRoot`.
4. Rojo syncs it instantly. The game updates.

## 3. "Baking" the Map (Making it Real)
If you decide you want to manually detail a specific district (e.g., add trees to Eros):
1. **Run the Game.**
2. Select the `Logos_District` (or any part) in the **Workspace**.
3. **Copy (Ctrl+C)** the folder/parts.
4. **Stop the Game.**
5. **Paste (Ctrl+V)** them back into the Workspace.
6. Now you can delete/disable `TownSpawner.server.luau` and the map is yours to edit manually.

## 4. NPC Brains
The NPCs use a simple **Dialogue System** powered by `NPCService`.
- To add more dialogue, just edit the table in `NPCService.lua` (or connect it to an LLM later).
- The UI handled automatically by `DialogueUI`.

**Status:**
- [x] Town Layout Generator: **Active**
- [x] NPC Spawner: **Active**
- [x] Dialogue UI: **Active**

**Your Job:** Just press Play.
