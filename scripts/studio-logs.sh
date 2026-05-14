#!/bin/bash
# ============================================================
# studio-logs.sh — Real-time Roblox Studio log viewer
# ============================================================
# Usage:
#   ./scripts/studio-logs.sh          # Tail the latest log
#   ./scripts/studio-logs.sh --all    # Show all log content (no filter)
#   ./scripts/studio-logs.sh --save   # Save session log to ~/roblox/logs/
#   ./scripts/studio-logs.sh --crash  # Analyze latest crash dump
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

LOG_DIR="$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/appdata/Roblox/logs"
CRASH_DIR="$LOG_DIR/crashes"
SAVE_DIR="$HOME/roblox/logs"

# Find the latest log file
find_latest_log() {
    local latest=$(ls -t "$LOG_DIR"/*_last.log 2>/dev/null | head -1)
    if [ -z "$latest" ]; then
        echo ""
    else
        echo "$latest"
    fi
}

# Colorize log output
colorize_log() {
    while IFS= read -r line; do
        if echo "$line" | grep -qi "error\|FAIL\|❌"; then
            echo -e "${RED}${line}${NC}"
        elif echo "$line" | grep -qi "warn"; then
            echo -e "${YELLOW}${line}${NC}"
        elif echo "$line" | grep -qi "\[SemanticSlime\]\|✅\|Boot\|TownGenerator"; then
            echo -e "${GREEN}${line}${NC}"
        elif echo "$line" | grep -qi "FLog::Output"; then
            echo -e "${CYAN}${line}${NC}"
        else
            echo "$line"
        fi
    done
}

# Main: Tail logs
tail_logs() {
    local log=$(find_latest_log)
    if [ -z "$log" ]; then
        echo -e "${RED}No Studio log files found in $LOG_DIR${NC}"
        echo "Start Roblox Studio first: flatpak run org.vinegarhq.Vinegar studio"
        exit 1
    fi

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Roblox Studio Log Viewer${NC}"
    echo -e "${CYAN}  File: $(basename "$log")${NC}"
    echo -e "${CYAN}  Press Ctrl+C to stop${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ "$1" == "--all" ]]; then
        cat "$log" | colorize_log
    else
        # Filter to game-relevant output
        grep -i "FLog::Output\|FLog::Error\|SemanticSlime\|TownGenerator\|Knit\|error\|warning\|crash\|Boot\|NPC\|Controller\|Service" "$log" | colorize_log
    fi

    echo ""
    echo -e "${CYAN}━━━ End of log ━━━${NC}"
}

# Save session log
save_log() {
    local log=$(find_latest_log)
    if [ -z "$log" ]; then
        echo -e "${RED}No log file found${NC}"
        exit 1
    fi

    mkdir -p "$SAVE_DIR"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local dest="$SAVE_DIR/studio_${timestamp}.log"
    cp "$log" "$dest"
    echo -e "${GREEN}✅ Log saved to: $dest${NC}"

    # Also save a filtered version
    local filtered="$SAVE_DIR/studio_${timestamp}_filtered.log"
    grep -i "FLog::Output\|FLog::Error\|SemanticSlime\|error\|warn\|Boot\|crash" "$log" > "$filtered"
    echo -e "${GREEN}✅ Filtered log saved to: $filtered${NC}"
}

# Analyze crash dumps
analyze_crashes() {
    if [ ! -d "$CRASH_DIR/reports" ]; then
        echo -e "${GREEN}No crash dumps found — that's good!${NC}"
        exit 0
    fi

    local count=$(ls "$CRASH_DIR/reports/" 2>/dev/null | wc -l)
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Crash Dump Analysis${NC}"
    echo -e "${CYAN}  Found: $count crash dump(s)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    for dump in "$CRASH_DIR/reports/"*.dmp; do
        local name=$(basename "$dump")
        local size=$(stat -c%s "$dump" 2>/dev/null || echo "?")
        echo -e "  ${YELLOW}$name${NC} (${size} bytes)"
    done

    echo ""
    echo -e "${MAGENTA}Crash metadata:${NC}"
    if [ -f "$CRASH_DIR/metadata" ]; then
        strings "$CRASH_DIR/metadata" 2>/dev/null | head -20
    else
        echo "  No metadata file found"
    fi

    echo ""
    echo -e "${YELLOW}To clear old crash dumps:${NC}"
    echo "  rm -rf $CRASH_DIR/reports/*.dmp"
}

# Route commands
case "${1:-}" in
    --all)
        tail_logs --all
        ;;
    --save)
        save_log
        ;;
    --crash)
        analyze_crashes
        ;;
    --help|-h)
        echo "Usage: ./scripts/studio-logs.sh [--all|--save|--crash]"
        echo ""
        echo "  (no args)  Show filtered game log (errors, boot, services)"
        echo "  --all      Show complete unfiltered log"
        echo "  --save     Save current log to ~/roblox/logs/"
        echo "  --crash    Analyze crash dumps"
        ;;
    *)
        tail_logs
        ;;
esac
