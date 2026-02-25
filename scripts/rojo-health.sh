#!/usr/bin/env bash
# rojo-health.sh — Check Rojo connection status and print a full report
# Usage: ./scripts/rojo-health.sh

set -euo pipefail

ROJO_PORT="${ROJO_PORT:-34872}"
ROJO_URL="http://localhost:${ROJO_PORT}/api/rojo"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔌 Rojo Connection Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if rojo process is running
ROJO_PID=$(pgrep -f "rojo serve" 2>/dev/null || echo "")
if [ -n "$ROJO_PID" ]; then
  echo "  Process  : ✅ Running (PID $ROJO_PID)"
else
  echo "  Process  : ❌ NOT running"
  echo ""
  echo "  → Start it with: export PATH=\"\$HOME/.rokit/bin:\$PATH\" && rojo serve"
  exit 1
fi

# Check HTTP API
HTTP_RESPONSE=$(curl -s --max-time 3 "$ROJO_URL" 2>/dev/null || echo "FAILED")
if [ "$HTTP_RESPONSE" = "FAILED" ]; then
  echo "  HTTP API : ❌ Not responding on port $ROJO_PORT"
  exit 1
fi

# Parse fields
SESSION_ID=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['sessionId'])" 2>/dev/null || echo "unknown")
VERSION=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['serverVersion'])" 2>/dev/null || echo "unknown")
PROJECT=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['projectName'])" 2>/dev/null || echo "unknown")
ROOT_ID=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['rootInstanceId'])" 2>/dev/null || echo "unknown")

echo "  HTTP API : ✅ Responding on port $ROJO_PORT"
echo "  Version  : $VERSION"
echo "  Project  : $PROJECT"
echo "  Session  : $SESSION_ID"
echo "  Root ID  : $ROOT_ID"

# Check port is actually bound
PORT_CHECK=$(ss -tlnp 2>/dev/null | grep ":${ROJO_PORT}" || echo "")
if [ -n "$PORT_CHECK" ]; then
  echo "  Port     : ✅ $ROJO_PORT bound and listening"
else
  echo "  Port     : ⚠️  $ROJO_PORT not found in socket list (may still work)"
fi

# Count source files being watched
FILE_COUNT=$(find src/ -name "*.luau" -o -name "*.lua" 2>/dev/null | wc -l | tr -d ' ')
echo "  Files    : $FILE_COUNT Luau/Lua files tracked"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Rojo is healthy and ready for Studio"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
