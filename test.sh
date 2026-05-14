#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  🧪 SEMANTIC SLIME — AUTOMATED TEST RUNNER
# ═══════════════════════════════════════════════════════════════
#  Runs all offline tests that DON'T require Studio.
#  For Studio playtesting, use ./play.sh instead.
#
#  Usage:
#    ./test.sh            ← Run everything
#    ./test.sh --quick    ← Skip lint
#    ./test.sh --watch    ← Re-run on file changes (live dev mode)
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

export PATH="$HOME/.rokit/bin:$PATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PASSED=0
FAILED=0
TOTAL_START=$(date +%s)

ok() { echo -e "  ${GREEN}✅ $1${NC}"; ((PASSED++)); }
fail() { echo -e "  ${RED}❌ $1${NC}"; ((FAILED++)); }
header() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

# ──────────────────────────────────────────────────
# Test 1: Can we build?
# ──────────────────────────────────────────────────
header "BUILD TEST"

BUILD_OUT=$(rojo build -o /tmp/test_build.rbxl 2>&1)
if [ $? -eq 0 ]; then
    SIZE=$(stat -c%s /tmp/test_build.rbxl 2>/dev/null)
    SIZE_KB=$((SIZE / 1024))
    ok "Build successful (${SIZE_KB}KB)"
    rm -f /tmp/test_build.rbxl
    
    # Size sanity check
    if [ "$SIZE_KB" -lt 100 ]; then
        fail "Build suspiciously small (${SIZE_KB}KB) — missing files?"
    elif [ "$SIZE_KB" -gt 5000 ]; then
        fail "Build very large (${SIZE_KB}KB) — check for bloat"
    else
        ok "Build size is reasonable"
    fi
else
    fail "Build failed!"
    echo "$BUILD_OUT" | tail -5
fi

# ──────────────────────────────────────────────────
# Test 2: Are all critical files present?
# ──────────────────────────────────────────────────
header "FILE INTEGRITY"

CRITICAL=(
    "src/server/Boot.server.luau"
    "src/client/Boot.client.luau"
    "src/shared/Remotes.luau"
    "src/shared/GameConfig.lua"
    "src/shared/NPCData.lua"
    "src/shared/TownBlueprint.lua"
    "src/shared/WordDatabase.lua"
    "src/shared/EtymologyDB.lua"
    "src/shared/CrashGuard.lua"
    "default.project.json"
    "wally.toml"
)

for f in "${CRITICAL[@]}"; do
    if [ -f "$f" ]; then
        ok "$f"
    else
        fail "MISSING: $f"
    fi
done

# ──────────────────────────────────────────────────
# Test 3: Are packages installed?
# ──────────────────────────────────────────────────
header "PACKAGES"

if [ -f "Packages/Knit.lua" ]; then
    ok "Knit package present"
else
    fail "Packages not installed — run: wally install"
fi

# ──────────────────────────────────────────────────
# Test 4: No deprecated APIs
# ──────────────────────────────────────────────────
header "DEPRECATED API CHECK"

DEPRECATED=("Ray.new" "CreateSound" "collectgarbage")
for pattern in "${DEPRECATED[@]}"; do
    HITS=$(grep -r "$pattern" src/ --include="*.lua" --include="*.luau" -l 2>/dev/null | wc -l)
    if [ "$HITS" -gt 0 ]; then
        fail "Deprecated '$pattern' found in $HITS file(s)"
        grep -r "$pattern" src/ --include="*.lua" --include="*.luau" -l 2>/dev/null | while read f; do
            echo -e "         ${YELLOW}→ $f${NC}"
        done
    else
        ok "No '$pattern' usage"
    fi
done

# ──────────────────────────────────────────────────
# Test 5: No orphaned requires (modules that require files that don't exist)
# ──────────────────────────────────────────────────
header "ORPHAN CHECK"

# Check for BattleService/BattleUI references (known removed systems)
GHOST_REFS=$(grep -r "BattleService\|BattleUI\|CombatService\|CombatController" src/ --include="*.lua" --include="*.luau" -l 2>/dev/null | wc -l)
if [ "$GHOST_REFS" -gt 0 ]; then
    fail "Ghost references to removed systems in $GHOST_REFS file(s)"
    grep -r "BattleService\|BattleUI\|CombatService\|CombatController" src/ --include="*.lua" --include="*.luau" -l 2>/dev/null | while read f; do
        echo -e "         ${YELLOW}→ $f${NC}"
    done
else
    ok "No ghost references to removed combat system"
fi

# ──────────────────────────────────────────────────
# Test 6: Lint (unless --quick)
# ──────────────────────────────────────────────────
if [[ "$1" != "--quick" ]] && command -v selene &>/dev/null; then
    header "LINT (selene)"
    
    LINT_OUT=$(selene src/ 2>&1)
    PARSE_ERRORS=$(echo "$LINT_OUT" | grep "parse errors" | grep -oP '^\d+' || echo "0")
    
    if [ "$PARSE_ERRORS" -gt 0 ]; then
        fail "Selene found $PARSE_ERRORS PARSE ERRORS (syntax broken!)"
        echo "$LINT_OUT" | grep -A2 "parse error"
    else
        ok "No parse errors — all Lua is syntactically valid"
    fi
    
    LINT_ERRORS=$(echo "$LINT_OUT" | grep "^[0-9]* errors" | grep -oP '^\d+' || echo "0")
    if [ "$LINT_ERRORS" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠  $LINT_ERRORS style errors (non-blocking)${NC}"
    fi
else
    echo -e "\n  ${YELLOW}Lint skipped (--quick mode or selene not installed)${NC}"
fi

# ──────────────────────────────────────────────────
# Test 7: project.json references valid paths
# ──────────────────────────────────────────────────
header "PROJECT CONFIG"

if [ -f "default.project.json" ]; then
    # Extract paths from project.json and verify they exist
    PATHS=$(grep -oP '"\\$path":\s*"([^"]+)"' default.project.json | grep -oP '"[^"]+"\s*$' | tr -d '"' | sort -u)
    MISSING_PATHS=0
    for p in $PATHS; do
        if [ ! -e "$p" ]; then
            fail "project.json references missing path: $p"
            ((MISSING_PATHS++))
        fi
    done
    if [ "$MISSING_PATHS" -eq 0 ]; then
        ok "All project.json paths exist"
    fi
else
    fail "default.project.json not found!"
fi

# ──────────────────────────────────────────────────
# Results
# ──────────────────────────────────────────────────
TOTAL_TIME=$(( $(date +%s) - TOTAL_START ))

echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  TEST RESULTS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo -e "  Time:   ${TOTAL_TIME}s"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "  ${RED}❌ $FAILED TEST(S) FAILED${NC}"
    notify-send --app-name="Semantic Slime" "❌ Tests Failed" "$FAILED test(s) failed" 2>/dev/null
    exit 1
else
    echo -e "  ${GREEN}✅ ALL TESTS PASSED${NC}"
    notify-send --app-name="Semantic Slime" "✅ All Tests Passed" "$PASSED tests passed in ${TOTAL_TIME}s" 2>/dev/null
    echo -e "\n  ${CYAN}Ready to play! Run: ./play.sh${NC}"
    exit 0
fi
