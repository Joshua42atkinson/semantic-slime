#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  🎮  SEMANTIC SLIME — ONE-CLICK PLAY
# ═══════════════════════════════════════════════════════════════
#  This script does EVERYTHING for you:
#    1. Checks your environment is healthy
#    2. Installs any missing packages
#    3. Builds the game
#    4. Starts the Rojo sync server
#    5. Opens Roblox Studio
#    6. Shows you the logs
#
#  Usage:
#    ./play.sh          ← Normal: build + sync + studio + logs
#    ./play.sh --quick  ← Skip lint, faster build
#    ./play.sh --fresh  ← Delete Wine prefix first (crash fix)
#    ./play.sh --logs   ← Just show logs (Studio already open)
#    ./play.sh --stop   ← Stop everything
#    ./play.sh --status ← Show what's running
# ═══════════════════════════════════════════════════════════════

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Log directory
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Ensure tools are in PATH
export PATH="$HOME/.rokit/bin:$PATH"

# ─────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────

banner() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  🎮  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

step() {
    echo -e "\n${BOLD}${GREEN}▶ Step $1: $2${NC}"
}

ok() {
    echo -e "  ${GREEN}✅ $1${NC}"
}

warn() {
    echo -e "  ${YELLOW}⚠  $1${NC}"
}

fail() {
    echo -e "  ${RED}❌ $1${NC}"
}

notify() {
    # Desktop notification (non-blocking)
    notify-send --app-name="Semantic Slime" "$1" "$2" 2>/dev/null &
}

is_rojo_running() {
    pgrep -f "rojo serve" >/dev/null 2>&1
}

is_studio_running() {
    pgrep -f "vinegar" >/dev/null 2>&1 || pgrep -f "RobloxStudio" >/dev/null 2>&1
}

rojo_pid() {
    pgrep -f "rojo serve" 2>/dev/null | head -1
}

# ─────────────────────────────────────────────────────────────
# Commands
# ─────────────────────────────────────────────────────────────

cmd_status() {
    banner "STATUS CHECK"
    
    echo -e "\n${BOLD}Services:${NC}"
    if is_rojo_running; then
        ok "Rojo sync server is RUNNING (PID $(rojo_pid))"
    else
        warn "Rojo sync server is NOT running"
    fi
    
    if is_studio_running; then
        ok "Roblox Studio is RUNNING"
    else
        warn "Roblox Studio is NOT running"
    fi
    
    echo -e "\n${BOLD}Environment:${NC}"
    echo -e "  Display:  ${XDG_SESSION_TYPE:-unknown}"
    echo -e "  Memory:   $(free -h | awk '/^Mem:/{print $7 " available / " $2 " total"}')"
    
    echo -e "\n${BOLD}Project:${NC}"
    if [ -f "semantic_slime_built.rbxl" ]; then
        local age=$(( ($(date +%s) - $(stat -c%Y semantic_slime_built.rbxl)) / 60 ))
        ok "Build exists (${age} minutes old)"
    else
        warn "No build file — run ./play.sh to build"
    fi
    
    # Latest log
    echo -e "\n${BOLD}Latest log:${NC}"
    local latest_log=$(ls -t "$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/appdata/Roblox/logs/"*_last.log 2>/dev/null | head -1)
    if [ -n "$latest_log" ]; then
        echo -e "  $(basename "$latest_log")"
        local errors=$(grep -ci "error" "$latest_log" 2>/dev/null || echo "0")
        if [ "$errors" -gt 10 ]; then
            warn "$errors errors in log (use ./play.sh --logs to see)"
        else
            ok "$errors errors in log"
        fi
    else
        echo -e "  No logs yet"
    fi
}

cmd_stop() {
    banner "STOPPING EVERYTHING"
    
    if is_rojo_running; then
        pkill -f "rojo serve" 2>/dev/null
        ok "Stopped Rojo sync server"
    else
        echo -e "  Rojo was not running"
    fi
    
    echo -e "  ${YELLOW}Note: Roblox Studio must be closed manually (File → Exit)${NC}"
    notify "Semantic Slime" "Services stopped"
}

cmd_logs() {
    banner "LIVE LOGS"
    bash scripts/studio-logs.sh "$@"
}

cmd_fresh() {
    banner "FRESH START — Deleting Wine Prefix"
    
    echo -e "  ${YELLOW}This will reset Roblox Studio settings (your code is safe).${NC}"
    echo -e "  ${YELLOW}Studio will take longer to open the first time after this.${NC}"
    
    if [ -d "$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/prefixes/studio" ]; then
        rm -rf "$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/prefixes/studio/"
        ok "Wine prefix deleted"
    else
        ok "Wine prefix was already clean"
    fi
}

cmd_play() {
    local QUICK_MODE=false
    local FRESH_MODE=false
    
    for arg in "$@"; do
        case "$arg" in
            --quick) QUICK_MODE=true ;;
            --fresh) FRESH_MODE=true ;;
        esac
    done
    
    banner "SEMANTIC SLIME — LAUNCHING"
    echo -e "  ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    
    # ──── Fresh mode (optional) ────
    if $FRESH_MODE; then
        cmd_fresh
    fi
    
    # ──── Step 1: Health Check ────
    step 1 "Environment Check"
    
    if ! command -v rojo &>/dev/null; then
        fail "Rojo not found! Installing tools..."
        if command -v rokit &>/dev/null; then
            rokit install
        else
            fail "Rokit not installed. Run: curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash"
            exit 1
        fi
    fi
    ok "Rojo $(rojo --version 2>&1 | head -1)"
    
    if ! command -v wally &>/dev/null; then
        fail "Wally not found!"
        exit 1
    fi
    ok "Wally ready"
    
    if ! flatpak list 2>/dev/null | grep -q "org.vinegarhq.Vinegar"; then
        fail "Vinegar not installed! Run: flatpak install flathub org.vinegarhq.Vinegar"
        exit 1
    fi
    ok "Vinegar installed"
    
    # Check Wayland
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        warn "Running on Wayland — if Studio crashes, try X11 session at login"
    fi
    
    # ──── Step 2: Install packages ────
    step 2 "Packages"
    
    if [ ! -d "Packages" ] || [ ! -f "Packages/Knit.lua" ]; then
        echo -e "  Installing packages..."
        wally install 2>&1 | tail -3
        if [ -f "Packages/Knit.lua" ]; then
            ok "Packages installed"
        else
            fail "Package install failed!"
            exit 1
        fi
    else
        ok "Packages already installed"
    fi
    
    # ──── Step 3: Build ────
    step 3 "Building Game"
    
    local BUILD_START=$(date +%s)
    local BUILD_OUTPUT
    BUILD_OUTPUT=$(rojo build -o semantic_slime_built.rbxl 2>&1)
    local BUILD_EXIT=$?
    local BUILD_TIME=$(( $(date +%s) - BUILD_START ))
    
    if [ $BUILD_EXIT -eq 0 ] && [ -f "semantic_slime_built.rbxl" ]; then
        local SIZE_KB=$(( $(stat -c%s semantic_slime_built.rbxl) / 1024 ))
        ok "Built: semantic_slime_built.rbxl (${SIZE_KB}KB in ${BUILD_TIME}s)"
    else
        fail "Build failed!"
        echo "$BUILD_OUTPUT"
        exit 1
    fi
    
    # ──── Step 4: Start Rojo Sync ────
    step 4 "Rojo Sync Server"
    
    if is_rojo_running; then
        ok "Rojo already running (PID $(rojo_pid))"
    else
        # Start Rojo in background, log output
        local ROJO_LOG="$LOG_DIR/rojo_$(date +%Y%m%d_%H%M%S).log"
        rojo serve > "$ROJO_LOG" 2>&1 &
        local ROJO_PID=$!
        sleep 1
        
        if kill -0 $ROJO_PID 2>/dev/null; then
            ok "Rojo started (PID $ROJO_PID) — log: $ROJO_LOG"
        else
            fail "Rojo failed to start! Check: $ROJO_LOG"
            exit 1
        fi
    fi
    
    # ──── Step 5: Open Studio ────
    step 5 "Opening Roblox Studio"
    
    if is_studio_running; then
        ok "Studio is already open"
        echo -e "  ${CYAN}→ In Studio: click Rojo plugin → Connect${NC}"
        echo -e "  ${CYAN}→ Then: File → Open → semantic_slime_built.rbxl${NC}"
    else
        echo -e "  ${CYAN}Launching Studio via Vinegar... (this may take 30-60 seconds)${NC}"
        flatpak run org.vinegarhq.Vinegar studio &>/dev/null &
        notify "Semantic Slime" "🎮 Studio is launching. When it opens:\n1. Click Rojo plugin → Connect\n2. File → Open → semantic_slime_built.rbxl\n3. Press F5 to playtest"
        ok "Studio launch command sent"
    fi
    
    # ──── Step 6: Instructions ────
    banner "WHAT TO DO IN STUDIO"
    
    echo -e "
  ${BOLD}When Studio opens:${NC}

  ${GREEN}1.${NC} Click the ${BOLD}Rojo plugin${NC} button in the toolbar
     → Click ${BOLD}Connect${NC} (it should say localhost:34872)

  ${GREEN}2.${NC} ${BOLD}File → Open${NC} → choose ${BOLD}semantic_slime_built.rbxl${NC}
     (it's in: ~/roblox/)

  ${GREEN}3.${NC} Press ${BOLD}F5${NC} to playtest!

  ${YELLOW}If Studio crashes:${NC}
     → Run: ${CYAN}./play.sh --fresh${NC}
     → Or try: ${CYAN}./play.sh --logs --crash${NC}
     → Nuclear option: switch to X11 at login screen

  ${BOLD}Useful commands while testing:${NC}
     ${CYAN}./play.sh --status${NC}   ← See what's running
     ${CYAN}./play.sh --logs${NC}     ← See Studio output
     ${CYAN}./play.sh --stop${NC}     ← Stop Rojo sync
"
    
    # Save a timestamped session record
    {
        echo "=== Play Session $(date) ==="
        echo "Build: ${SIZE_KB}KB in ${BUILD_TIME}s"
        echo "Rojo: PID $(rojo_pid)"
        echo "Display: $XDG_SESSION_TYPE"
        echo "Memory: $(free -h | awk '/^Mem:/{print $7 " / " $2}')"
    } >> "$LOG_DIR/sessions.log"
    
    # ──── Auto-tail logs after a delay ────
    echo -e "${CYAN}Waiting 15 seconds for Studio to start, then showing logs...${NC}"
    echo -e "${CYAN}Press Ctrl+C to skip waiting.${NC}"
    
    # Wait for studio logs to appear, checking every 2 seconds
    for i in $(seq 1 8); do
        sleep 2
        local latest_log=$(ls -t "$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/appdata/Roblox/logs/"*_last.log 2>/dev/null | head -1)
        if [ -n "$latest_log" ]; then
            local log_age=$(( $(date +%s) - $(stat -c%Y "$latest_log") ))
            if [ "$log_age" -lt 30 ]; then
                echo -e "\n${GREEN}Studio log detected! Showing game output:${NC}\n"
                bash scripts/studio-logs.sh
                break
            fi
        fi
        echo -ne "\r  Waiting... (${i}/8)"
    done
}

# ─────────────────────────────────────────────────────────────
# Route command
# ─────────────────────────────────────────────────────────────

case "${1:-play}" in
    --stop|-s)
        cmd_stop
        ;;
    --status|-S)
        cmd_status
        ;;
    --logs|-l)
        shift
        cmd_logs "$@"
        ;;
    --fresh|-f)
        cmd_fresh
        # Then continue to play
        shift
        cmd_play "$@"
        ;;
    --help|-h)
        banner "HELP"
        echo "
  ${BOLD}Usage:${NC}  ./play.sh [option]

  ${GREEN}(no option)${NC}    Build + sync + open Studio + show logs
  ${GREEN}--quick${NC}        Skip lint, faster build
  ${GREEN}--fresh${NC}        Delete Wine prefix first (fixes crashes)
  ${GREEN}--logs${NC}         Just show latest Studio logs
  ${GREEN}--stop${NC}         Stop Rojo sync server
  ${GREEN}--status${NC}       Show what's running
  ${GREEN}--help${NC}         Show this help
"
        ;;
    *)
        cmd_play "$@"
        ;;
esac
