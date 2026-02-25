# Professional Roblox Development

This document defines the **Standard Engineering Workflow** for this project. We do not hack; we engineer.

## 1. Toolchain
Ensure these tools are in your PATH (managed via `rokit` recommended).
- **Rojo**: Syncs file system to Studio.
- **Selene**: Linter (catches bugs). Config: `selene.toml`.
- **StyLua**: Formatter (enforces style). Config: `stylua.toml`.
- **Wally**: Package manager (optional but recommended for libraries like Knit/Fusion).

## 2. Project Structure (The "Skeleton")
We use a **Service/Controller** architecture to separate concerns.

```text
src/
├── shared/           (ReplicatedStorage)
│   ├── Data/        (Static configuration, e.g., WeaponStats, LootTables)
│   ├── Types/       (Luau Type definitions - single source of truth)
│   ├── Remotes.lua  (RemoteEvent definitions/abstraction)
│   └── Utils/       (Shared helper functions)
├── server/           (ServerScriptService)
│   ├── Services/    (Singleton logic: InventoryService, GameLoopService)
│   │   └── init.luau (Service booter)
│   └── main.server.luau (Bootstrapper - requires Services)
└── client/           (StarterPlayerScripts)
    ├── Controllers/ (Client logic: InputController, HUDController)
    │   └── init.luau (Controller booter)
    └── main.client.lua (Bootstrapper - requires Controllers)
```

## 3. Best Practices

### Scripting
- **Strict Typing**: All new files MUST start with `--!strict`.
- **Singletons**: Use Services for global logic. distinct from Instance-bound scripts.
- **Data-Driven**: Hardcode nothing. Move constants to `shared/Data/GameConfig.lua`.
- **Descriptive Naming**: `function kill()` -> `function ApplyDamageToCharacter()`.

### Version Control (Git)
- **Commit Granularity**: One commit per "thought" (e.g., "Implement InventoryService add method").
- **Branching**: `feature/mechanic-name` -> `main`.
- **No Binaries**: Do not commit `.rbxl` files unless absolutely necessary (use `.rbxlx` or nothing).

### Environment
- **Rojo Health**: If sync breaks, restart the `./scripts/rojo-health.sh` script.
- **Context**: Keep `specs/` open to ground your AI assistant.

## VS Code Setup
- **Extensions**:
  - Roblox LSP (Nightly)
  - Selene (Linter)
  - StyLua (Formatter)
- **Settings**:
  - Format on Save: Enabled.
  - Trim Trailing Whitespace: Enabled.
