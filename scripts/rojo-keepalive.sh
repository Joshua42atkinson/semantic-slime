#!/usr/bin/env bash
# rojo-keepalive.sh — Watches Rojo and restarts it if it dies
# Runs as a background daemon. Logs to /tmp/rojo-keepalive.log
# Usage: ./scripts/rojo-keepalive.sh &

ROJO_PORT="${ROJO_PORT:-34872}"
ROJO_URL="http://localhost:${ROJO_PORT}/api/rojo"
LOG="/tmp/rojo-keepalive.log"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROKIT_BIN="$HOME/.rokit/bin"
CHECK_INTERVAL=10  # seconds between health checks
RESTART_DELAY=3    # seconds to wait before restarting

export PATH="$ROKIT_BIN:$PATH"

log() {
  echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"
}

start_rojo() {
  log "🚀 Starting rojo serve..."
  cd "$PROJECT_DIR"
  rojo serve >> "$LOG" 2>&1 &
  ROJO_PID=$!
  log "   PID: $ROJO_PID"
  sleep 2  # give it time to bind the port
}

check_alive() {
  curl -s --max-time 2 "$ROJO_URL" > /dev/null 2>&1
  return $?
}

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "🔌 Rojo Keepalive Daemon starting"
log "   Project : $PROJECT_DIR"
log "   Port    : $ROJO_PORT"
log "   Log     : $LOG"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# If rojo isn't running yet, start it
if ! check_alive; then
  start_rojo
fi

FAIL_COUNT=0
while true; do
  sleep "$CHECK_INTERVAL"

  if check_alive; then
    FAIL_COUNT=0
    # Silent when healthy — only log issues
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    log "⚠️  Health check failed ($FAIL_COUNT/3)"

    if [ "$FAIL_COUNT" -ge 3 ]; then
      log "❌ Rojo appears dead. Restarting..."

      # Kill any zombie rojo processes
      pkill -f "rojo serve" 2>/dev/null || true
      sleep "$RESTART_DELAY"

      start_rojo
      FAIL_COUNT=0

      if check_alive; then
        log "✅ Rojo restarted successfully"
      else
        log "🔴 Restart failed — check logs above"
      fi
    fi
  fi
done
