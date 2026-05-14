# Bug Tracker - Semantic Slime

This document tracks major bugs resolved during the project, particularly those that caused cascading failures or blocked the game loop from functioning.

## Recent Fixes (Runtime & Boot Blockers)

| Status | Component | Description | Fix |
|---|---|---|---|
| ✅ Fixed | **TownGenerator** | Extra `end` statement caused premature loop closure, preventing town spawn and causing "Expected <eof>, got 'end'" parser errors. | Removed the extra `end` at line 1185 and corrected block nesting. |
| ✅ Fixed | **Boot.server.luau** | `collectgarbage("collect")` is unsupported in Luau/Roblox, causing the boot promise to crash. | Removed/commented out the unsupported memory management call. |
| ✅ Fixed | **GameLoopService** | `GameLoopService.Client.PhaseChanged:Fire()` called from the server using the client table, causing an `attempt to index userdata` error. | Separated Server and Client signals, and properly fired both during phase transitions (`GameLoopService.PhaseChanged:Fire` vs `Client.PhaseChanged:FireAll`). |
| ✅ Fixed | **Client Controllers** | Cascading `attempt to index nil with 'PhaseChanged'` across 12+ controllers. Controllers incorrectly tried to access Knit remote signals using the `.Client` table (e.g., `GameLoopService.Client.PhaseChanged`). | Batch-replaced all `<Service>.Client.<Signal>` references across the `src/client/Controllers` directory to correctly use `<Service>.<Signal>`. |
| ✅ Fixed | **TerrainService** | `Raycast` incorrectly called on `Workspace.Terrain` instead of `Workspace`. | Changed `Workspace.Terrain:Raycast(...)` to `Workspace:Raycast(...)` for terrain gap safety checks. |
| ✅ Fixed | **NPCService** | `attempt to call a nil value` at line 182 because `startWandering` was defined *below* `animateNPC`. | Moved `startWandering` definition above `animateNPC` to obey Lua's single-pass scoping rules. |
| ✅ Fixed | **MusicManager** | Local function `playTrackForPlayer` attempted to use `self.Client.TrackChanged:Fire`, but `self` was undefined inside the local function. | Replaced `self.Client` with explicit `MusicManager.Client` references across all local functions. |
| ✅ Fixed | **SoundController / QuestUI** | `SoundService:CreateSound()` caused repeated script failures on the client as it's an invalid API. | Replaced with standard object instantiation: `Instance.new("Sound")`. |
| ✅ Fixed | **HUDController** | `require(BattleUI)` crashed the entire controller because BattleUI.lua was deleted when combat was removed. | Replaced with stub table `local BattleUI = {}`. |
| ✅ Fixed | **QuestController** | `require(NotificationController)` crashed because NotificationController.lua never existed. | Created `NotificationController.lua` with ShowToast/ShowCelebration methods. |
| ✅ Fixed | **PerformanceMonitor** | `collectgarbage("count")` unsupported in Luau; `BattleService` references caused warnings. | Replaced with `gcinfo()`, removed dead service refs. |

## Pending / Ongoing Issues

| Severity | Component | Description | Status |
|---|---|---|---|
| 🔴 Crit | **Studio Crash (Wine)** | Studio crashes (exit status 5) AFTER successful boot — 29/29 controllers loaded, all services running. Crash is NOT a Lua error. Suspected causes: (1) 7 sound assets returning HTTP 403, (2) 2.5MB of data tables causing memory pressure under Wine, (3) TownGenerator creating 83+ instances simultaneously. | **INVESTIGATING — Next session priority.** |
| 🟡 Warn | **SoundController** | All 7 `rbxassetid://` sound assets return HTTP 403 in unpublished places. Not pcall-wrapped, could trigger cascading failures. | Needs pcall wrapping or asset replacement. |
| 🟡 Warn | **SynonymDatabase** | 1.6MB / 67K lines loaded at `require()` time. Should be lazy-loaded. | Deferred optimization. |
| 🟡 Warn | **DataService** | `DataStore unavailable` warnings appearing in Studio. | Expected behavior for unpublished places (or places with Studio Access to API disabled). Handled gracefully via `pcall`. |
| 🟡 Warn | **DataBridgeService** | HTTP Request errors for the Ubuntu bridge. | Normal if "Allow HTTP Requests" is disabled in Game Settings, wrapped in pcall. |

