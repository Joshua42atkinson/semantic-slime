# Setup Guide

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [Roblox Studio](https://create.roblox.com/) | Game editor | Download from Roblox |
| [Rokit](https://github.com/rojo-rbx/rokit) | Installs Rojo + Wally | `curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh \| bash` |

## First-Time Setup

```bash
cd ~/roblox

# Install Rojo and Wally via Rokit
rokit install

# Install Lua packages (Knit, Promise)
wally install
```

## Daily Development

```bash
# Start Rojo sync server
./sync.sh
```

Then in Roblox Studio:
1. Open `semantic_slime_fresh.rbxl` (or any place file)
2. Install the Rojo plugin if you haven't (Plugin Manager → search "Rojo 7")
3. Click **Connect** in the Rojo widget → `localhost:34872`
4. Press **Play** — the world generates automatically

## Project Configuration Files

| File | Purpose |
|------|---------|
| `default.project.json` | Rojo project — maps `src/` folders to Roblox services |
| `wally.toml` | Package dependencies (Knit framework, Promise library) |
| `rokit.toml` | Toolchain versions (Rojo 7.6.1, Wally 0.3.2) |
| `selene.toml` | Lua linter configuration |
| `stylua.toml` | Lua formatter configuration |

## How Rojo Sync Works

```
src/client/  →  StarterPlayer.StarterPlayerScripts.Client
src/server/  →  ServerScriptService.Server
src/shared/  →  ReplicatedStorage.Shared
```

When Rojo is running, any file you save in `src/` instantly appears in Studio. No build step needed.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Packages folder not found" | Run `wally install` — creates `Packages/` directory |
| Rojo won't connect | Check port 34872 isn't in use: `lsof -i :34872` |
| Studio shows old code | Disconnect and reconnect the Rojo plugin |
| "Knit not found" error | `wally install` then restart Rojo |
