---
description: The Lazy Developer's Guide to Building the Psyche-Polis
---

# The Lazy Dev Workflow
> "Water flows in the path of least resistance."

This workflow is for anyone who wants maximum results with minimum manual labor.

## 0. Health Check (Run This First!)
Before anything else, run the environment doctor:
```bash
./scripts/vinegar-doctor.sh
```
This checks your GPU, Vinegar config, Wine prefix, toolchain, and project files.

## 1. Build & Test
Run the quality pipeline to build the game:
```bash
./pipeline.sh --quick    # Fast: build only (~5 sec)
./pipeline.sh            # Full: lint + build (~15 sec)
```

## 2. Press Play
The world generates itself. `TownGenerator.lua` creates all 7 Jungian districts, buildings, and NPC spawns every time the server starts. You don't place parts manually.

**How:** Open Studio, connect to Rojo, press Play.
```bash
# Start Rojo sync
rojo serve

# Open Studio
flatpak run org.vinegarhq.Vinegar studio
```

## 3. Read Logs
When Studio crashes or something breaks:
```bash
./scripts/studio-logs.sh          # See filtered game output
./scripts/studio-logs.sh --all    # See everything
./scripts/studio-logs.sh --save   # Save logs to ~/roblox/logs/
./scripts/studio-logs.sh --crash  # Analyze crash dumps
```

## 4. Change the World (Without Touching the Map)
Want to rename an NPC? Change a building color? Edit district layout?

1. Edit `src/shared/NPCData.lua` (NPCs), `src/shared/TownBlueprint.lua` (map), or `src/shared/BuildingStyles.lua` (buildings)
2. Rojo syncs instantly
3. Press Play again — changes appear

**Never manually edit the 3D workspace.** Everything is code-driven.

## 5. "Bake" the Map (Optional)
If you want to manually detail a specific area:
1. Press Play (town generates)
2. Select the district folder in Workspace
3. Copy (Ctrl+C)
4. Stop the game
5. Paste (Ctrl+V) into Workspace
6. Now you can hand-edit that area

## 6. NPC Dialogue
NPCs use `NPCService.lua` for spawning and `DialogueUI.lua` for conversation display.
- Edit dialogue in `src/shared/NPCData.lua`
- Each NPC has a `DialogueRoot` table with conversation trees

## 7. Add Content
- **New words:** Edit `src/shared/WordDatabase.lua`
- **New quests:** Edit `src/shared/QuestData.lua` (or use `/new-quest`)
- **New slime properties:** Edit `src/shared/EtymologyDB.lua`

## 8. Publish to Roblox
Once your changes are ready, publish directly:
```bash
./pipeline.sh --publish    # Build + publish to Roblox
```
Requires `ROBLOX_API_KEY`, `ROBLOX_UNIVERSE_ID` environment variables.

Or push to GitHub and the CI/CD pipeline will build & publish automatically.

## 9. If Studio Crashes
Try these in order:
1. Delete Wine prefix: `rm -rf ~/.var/app/org.vinegarhq.Vinegar/data/vinegar/prefixes/studio/`
2. Switch renderer in `~/.var/app/org.vinegarhq.Vinegar/config/vinegar/config.toml`
3. Try X11 session instead of Wayland (at login screen)
4. Skip Studio entirely — publish to Roblox and test on real devices

**Your job:** Just edit data. The systems handle the rest.
