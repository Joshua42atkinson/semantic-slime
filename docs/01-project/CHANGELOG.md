# Changelog

All notable changes to Semantic Slime are documented here.

## [0.1.0] - 2026-03-03 — "The Nine-Bug Audit"

### Fixed
- **CRITICAL**: `SynonymDatabase.lua` used JSON `[]` syntax — converted to Lua `{}`
- **CRITICAL**: `Boot.server.luau` didn't require `Remotes.luau` — services hung on `WaitForChild`
- **CRITICAL**: `BattleService.lua` called non-existent `SynonymDatabase:GetWordData()`
- `sync.sh` port mismatch (34972 vs 34872)
- `HUDController.lua` double `AchievementUI.Initialize()`
- `GameLoopService.lua` `NextPhase()` skipped Combat phase
- `GameLoopService.lua` variable re-declarations in strict mode

### Added
- `DataService` stub methods: `GrantRerollToken`, `GrantBattleSkip`, `GrantDoubleRewards`
- Consolidated `docs/` folder structure (7 sections)
- `docs/05-pedagogy/LESSONS_LEARNED.md`
- `docs/07-testing/BUG_TRACKER.md`

### Removed
- Empty `src/shared/Remotes/` folder (shadowed `Remotes.luau`)
