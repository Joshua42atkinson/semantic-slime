#!/bin/bash
# ============================================================
# Semantic Slime — Automated Quality Gate Pipeline
# ============================================================
# This script runs ALL quality checks and builds the game.
# Exit code 0 = ALL gates passed. Non-zero = failure.
#
# Usage:
#   ./pipeline.sh          # Run all gates
#   ./pipeline.sh --quick  # Skip lint, just build
#   ./pipeline.sh --publish # Build + publish to Roblox
# ============================================================

# set -e  # Don't exit on first failure — we want all gates to report

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure tools are in PATH
export PATH="$HOME/.rokit/bin:$PATH"

# Track results
PASSED=0
FAILED=0
WARNINGS=0

pass() {
    echo -e "  ${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

fail() {
    echo -e "  ${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

gate_warn() {
    echo -e "  ${YELLOW}⚠  WARN${NC}: $1"
    ((WARNINGS++))
}

header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================================
# GATE 0: Environment Health Check
# ============================================================
header "GATE 0: Environment Health Check"

if [ -x "scripts/vinegar-doctor.sh" ]; then
    DOCTOR_OUTPUT=$(bash scripts/vinegar-doctor.sh 2>&1)
    DOCTOR_EXIT=$?
    if [ "$DOCTOR_EXIT" -eq 0 ]; then
        pass "Environment health check passed"
    else
        gate_warn "Environment has issues (run ./scripts/vinegar-doctor.sh for details)"
    fi
else
    gate_warn "vinegar-doctor.sh not found — skipping environment check"
fi

# ============================================================
# GATE 1: Toolchain Check
# ============================================================
header "GATE 1: Toolchain Verification"

if command -v rojo &> /dev/null; then
    ROJO_VERSION=$(rojo --version 2>&1 | head -1)
    pass "Rojo installed: $ROJO_VERSION"
else
    fail "Rojo not found. Run: rokit install"
fi

if command -v wally &> /dev/null; then
    pass "Wally installed"
else
    fail "Wally not found. Run: rokit install"
fi

if command -v selene &> /dev/null; then
    pass "Selene installed"
else
    gate_warn "Selene not found. Run: rokit add kampfkarren/selene"
fi

if command -v stylua &> /dev/null; then
    pass "StyLua installed"
else
    gate_warn "StyLua not found. Run: rokit add JohnnyMorganz/StyLua"
fi

# ============================================================
# GATE 2: Dependencies
# ============================================================
header "GATE 2: Dependencies"

if [ -d "Packages" ] && [ -f "Packages/Knit.lua" ]; then
    pass "Packages/ directory exists with Knit"
else
    echo -e "  ${YELLOW}Installing packages...${NC}"
    wally install
    if [ -f "Packages/Knit.lua" ]; then
        pass "Packages installed successfully"
    else
        fail "wally install failed — Packages/Knit.lua not found"
    fi
fi

# ============================================================
# GATE 3: Source Integrity
# ============================================================
header "GATE 3: Source Integrity"

# Count files
SERVER_COUNT=$(find src/server/Services -name "*.lua" 2>/dev/null | wc -l)
CLIENT_COUNT=$(find src/client/Controllers -name "*.lua" 2>/dev/null | wc -l)
SHARED_COUNT=$(find src/shared -maxdepth 1 -name "*.lua" -o -name "*.luau" 2>/dev/null | wc -l)

echo "  Server services:   $SERVER_COUNT"
echo "  Client controllers: $CLIENT_COUNT"
echo "  Shared modules:    $SHARED_COUNT"

if [ "$SERVER_COUNT" -gt 0 ]; then
    pass "Server services found ($SERVER_COUNT)"
else
    fail "No server services found"
fi

if [ "$CLIENT_COUNT" -gt 0 ]; then
    pass "Client controllers found ($CLIENT_COUNT)"
else
    fail "No client controllers found"
fi

# Check critical files exist
CRITICAL_FILES=(
    "src/server/Boot.server.luau"
    "src/client/Boot.client.luau"
    "src/shared/Remotes.luau"
    "src/shared/GameConfig.lua"
    "src/shared/EtymologyDB.lua"
    "src/shared/WordDatabase.lua"
    "src/shared/NPCData.lua"
    "src/shared/TownBlueprint.lua"
    "default.project.json"
)

for f in "${CRITICAL_FILES[@]}"; do
    if [ -f "$f" ]; then
        pass "Critical file: $f"
    else
        fail "Missing critical file: $f"
    fi
done

# ============================================================
# GATE 4: Deprecated API Check
# ============================================================
header "GATE 4: Deprecated API Scan"

# Check for deprecated/unsupported APIs
DEPRECATED_PATTERNS=(
    "Ray.new"
    "CreateSound"
    "collectgarbage"
)

for pattern in "${DEPRECATED_PATTERNS[@]}"; do
    HITS=$(grep -r "$pattern" src/ --include="*.lua" --include="*.luau" -l 2>/dev/null | wc -l)
    if [ "$HITS" -gt 0 ]; then
        fail "Deprecated API '$pattern' found in $HITS file(s):"
        grep -r "$pattern" src/ --include="*.lua" --include="*.luau" -l 2>/dev/null | while read f; do
            echo "         → $f"
        done
    else
        pass "No deprecated '$pattern' usage"
    fi
done

# Check for ghost phase references that could cause confusion
BATTLE_REFS=$(grep -r "BattleService" src/server/Services/ --include="*.lua" -l 2>/dev/null | wc -l)
if [ "$BATTLE_REFS" -gt 0 ]; then
    gate_warn "BattleService references found in $BATTLE_REFS file(s) (combat was removed)"
else
    pass "No stale BattleService references in server"
fi

# ============================================================
# GATE 5: Lint (optional with --quick)
# ============================================================
if [[ "$1" != "--quick" ]] && command -v selene &> /dev/null; then
    header "GATE 5: Selene Lint"
    
    LINT_OUTPUT=$(selene src/ 2>&1)
    PARSE_ERRORS=$(echo "$LINT_OUTPUT" | grep -c "^0 parse errors" || true)
    # If "0 parse errors" is found, PARSE_ERRORS=1 (grep -c counts matches)
    # We want to FAIL if there are >0 parse errors, so check the actual line
    ACTUAL_PARSE=$(echo "$LINT_OUTPUT" | grep "parse errors" | head -1 | grep -oP '^\d+' || echo "0")
    LINT_ERRORS=$(echo "$LINT_OUTPUT" | grep "^[0-9]* errors" | head -1 | grep -oP '^\d+' || echo "0")
    LINT_WARNINGS=$(echo "$LINT_OUTPUT" | grep "^[0-9]* warnings" | head -1 | grep -oP '^\d+' || echo "0")
    
    if [ "$ACTUAL_PARSE" -gt 0 ]; then
        fail "Selene found $ACTUAL_PARSE parse errors (syntax broken!)"
    else
        pass "No parse errors (all Lua is syntactically valid)"
    fi
    
    if [ "$LINT_ERRORS" -gt 0 ]; then
        gate_warn "Selene: $LINT_ERRORS style errors (non-blocking)"
    fi
    echo "  Lint warnings: $LINT_WARNINGS"
else
    echo ""
    echo -e "  ${YELLOW}Skipping lint (--quick mode or selene not installed)${NC}"
fi

# ============================================================
# GATE 6: Build
# ============================================================
header "GATE 6: Rojo Build"

BUILD_OUTPUT=$(rojo build -o semantic_slime_built.rbxl 2>&1)
if [ $? -eq 0 ] && [ -f "semantic_slime_built.rbxl" ]; then
    FILE_SIZE=$(stat -c%s semantic_slime_built.rbxl 2>/dev/null || stat -f%z semantic_slime_built.rbxl 2>/dev/null)
    FILE_SIZE_KB=$((FILE_SIZE / 1024))
    pass "Build successful: semantic_slime_built.rbxl (${FILE_SIZE_KB}KB)"
else
    fail "Rojo build failed!"
    echo "$BUILD_OUTPUT"
fi

# ============================================================
# GATE 7: Publish (only with --publish)
# ============================================================
if [[ "$1" == "--publish" ]]; then
    header "GATE 7: Publish to Roblox"
    
    if ! command -v rbxcloud &> /dev/null; then
        fail "rbxcloud not installed. See: https://github.com/Sleitnick/rbxcloud"
    elif [ -z "$ROBLOX_API_KEY" ]; then
        fail "ROBLOX_API_KEY environment variable not set"
    elif [ -z "$ROBLOX_UNIVERSE_ID" ]; then
        fail "ROBLOX_UNIVERSE_ID environment variable not set"
    else
        echo -e "  ${YELLOW}Publishing to Roblox...${NC}"
        PUBLISH_OUTPUT=$(rbxcloud experience publish \
            --file semantic_slime_built.rbxl \
            --universe-id "$ROBLOX_UNIVERSE_ID" \
            --api-key "$ROBLOX_API_KEY" \
            --version-type Published 2>&1)
        
        if [ $? -eq 0 ]; then
            pass "Published to Roblox successfully!"
            echo "  $PUBLISH_OUTPUT"
        else
            fail "Publish failed!"
            echo "  $PUBLISH_OUTPUT"
        fi
    fi
fi

# ============================================================
# RESULTS
# ============================================================
header "PIPELINE RESULTS"

TOTAL=$((PASSED + FAILED))
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "  ${RED}❌ PIPELINE FAILED — $FAILED gate(s) did not pass${NC}"
    echo ""
    exit 1
else
    echo -e "  ${GREEN}✅ ALL GATES PASSED${NC}"
    echo ""
    
    if [ -f "semantic_slime_built.rbxl" ]; then
        echo "  Next steps:"
        echo "    1. Open Roblox Studio:  flatpak run org.vinegarhq.Vinegar studio"
        echo "    2. Open the build file: File → Open → semantic_slime_built.rbxl"
        echo "    3. Press F5 to playtest"
        echo ""
        echo "  Or publish:  ./pipeline.sh --publish"
    fi
    
    exit 0
fi
