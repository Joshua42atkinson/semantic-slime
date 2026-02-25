---
description: Start the Rojo sync server for Roblox Studio
---

## Option A — Quick Start (manual, current session only)
// turbo
1. Run `rojo serve` to start the sync server
```bash
export PATH="$HOME/.rokit/bin:$PATH" && rojo serve
```

## Option B — Keepalive Daemon (auto-restarts if Rojo dies)
2. Run the keepalive daemon in the background
```bash
chmod +x scripts/rojo-keepalive.sh && bash scripts/rojo-keepalive.sh &
```
Logs go to `/tmp/rojo-keepalive.log`. To stop it: `pkill -f rojo-keepalive.sh`

## Option C — Systemd Service (starts on login, survives reboots)
3. Install as a systemd user service (one-time setup)
```bash
mkdir -p ~/.config/systemd/user
cp scripts/rojo.service ~/.config/systemd/user/rojo.service
systemctl --user daemon-reload
systemctl --user enable rojo
systemctl --user start rojo
```
Check status: `systemctl --user status rojo`
View logs: `journalctl --user -u rojo -f`
Stop: `systemctl --user stop rojo`

## Health Check (any time)
4. Verify the connection is alive
```bash
chmod +x scripts/rojo-health.sh && bash scripts/rojo-health.sh
```

## Connecting Studio
- Open Roblox Studio
- Install the Rojo plugin (Plugin Manager → search "Rojo 7")
- Click **Connect** → `localhost:34872`
