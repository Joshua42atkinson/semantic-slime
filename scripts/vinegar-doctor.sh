#!/bin/bash
# ============================================================
# vinegar-doctor.sh — Environment Health Check
# ============================================================
# Diagnoses common issues with the Roblox Studio + Vinegar
# development environment on Linux.
#
# Usage: ./scripts/vinegar-doctor.sh
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
WARNED=0
FAILED=0

pass() {
    echo -e "  ${GREEN}✅${NC} $1"
    ((PASSED++))
}

warn_check() {
    echo -e "  ${YELLOW}⚠ ${NC} $1"
    ((WARNED++))
}

fail_check() {
    echo -e "  ${RED}❌${NC} $1"
    ((FAILED++))
}

header() {
    echo ""
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

# ============================================================
header "System Info"
# ============================================================

echo -e "  Kernel:   $(uname -r)"
echo -e "  OS:       $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"' || echo 'Unknown')"
echo -e "  Date:     $(date)"

# Memory
TOTAL_MEM=$(free -h | awk '/^Mem:/{print $2}')
AVAIL_MEM=$(free -h | awk '/^Mem:/{print $7}')
echo -e "  Memory:   $AVAIL_MEM available / $TOTAL_MEM total"

# ============================================================
header "Display Server"
# ============================================================

SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
if [ "$SESSION_TYPE" = "wayland" ]; then
    warn_check "Running Wayland — Wine apps may crash. Try X11 session for stability."
elif [ "$SESSION_TYPE" = "x11" ]; then
    pass "Running X11 — best compatibility for Wine apps"
else
    warn_check "Display server: $SESSION_TYPE (unknown compatibility)"
fi

# ============================================================
header "GPU"
# ============================================================

GPU_INFO=$(lspci 2>/dev/null | grep -i "vga\|3d\|display" | head -1 | sed 's/.*: //')
if [ -n "$GPU_INFO" ]; then
    echo -e "  GPU: $GPU_INFO"
    
    if echo "$GPU_INFO" | grep -qi "renoir\|vega.*ryzen\|cezanne\|barcelo"; then
        warn_check "AMD iGPU detected — known DXVK issues. Use Vulkan renderer."
    elif echo "$GPU_INFO" | grep -qi "nvidia"; then
        warn_check "NVIDIA detected — ensure proprietary drivers are installed"
    elif echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
        pass "AMD GPU detected — should work with Mesa/RADV drivers"
    elif echo "$GPU_INFO" | grep -qi "intel"; then
        warn_check "Intel GPU — limited Wine compatibility"
    fi
else
    warn_check "Could not detect GPU (lspci not available)"
fi

# Mesa version
MESA_VER=$(glxinfo 2>/dev/null | grep "OpenGL version" | head -1 || echo "")
if [ -n "$MESA_VER" ]; then
    echo -e "  Mesa: $MESA_VER"
else
    echo -e "  Mesa: (could not detect — glxinfo not available)"
fi

# ============================================================
header "Vinegar"
# ============================================================

if flatpak list 2>/dev/null | grep -q "org.vinegarhq.Vinegar"; then
    VIN_VER=$(flatpak info org.vinegarhq.Vinegar 2>/dev/null | grep "Version:" | awk '{print $2}')
    pass "Vinegar installed (Flatpak): $VIN_VER"
else
    fail_check "Vinegar NOT installed. Install: flatpak install flathub org.vinegarhq.Vinegar"
fi

# Config file
CONFIG_FILE="$HOME/.var/app/org.vinegarhq.Vinegar/config/vinegar/config.toml"
if [ -f "$CONFIG_FILE" ]; then
    pass "Vinegar config exists: $CONFIG_FILE"
    echo -e "  ${CYAN}Config contents:${NC}"
    cat "$CONFIG_FILE" | sed 's/^/    /'
else
    warn_check "No Vinegar config file — using defaults"
    echo "    Create one at: $CONFIG_FILE"
fi

# Wine prefix
PREFIX_DIR="$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/prefixes/studio"
if [ -d "$PREFIX_DIR" ]; then
    PREFIX_SIZE=$(du -sh "$PREFIX_DIR" 2>/dev/null | awk '{print $1}')
    pass "Wine prefix exists ($PREFIX_SIZE)"
else
    warn_check "No Wine prefix — Studio will create one on first launch"
fi

# Crash dumps
CRASH_DIR="$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar/appdata/Roblox/logs/crashes/reports"
if [ -d "$CRASH_DIR" ]; then
    CRASH_COUNT=$(ls "$CRASH_DIR"/*.dmp 2>/dev/null | wc -l)
    if [ "$CRASH_COUNT" -gt 0 ]; then
        warn_check "$CRASH_COUNT crash dump(s) found in $CRASH_DIR"
    else
        pass "No crash dumps"
    fi
else
    pass "No crash directory (clean install)"
fi

# ============================================================
header "Roblox Dev Toolchain"
# ============================================================

export PATH="$HOME/.rokit/bin:$PATH"

# Rokit
if command -v rokit &>/dev/null; then
    pass "Rokit installed"
else
    fail_check "Rokit not found. Install: curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash"
fi

# Rojo
if command -v rojo &>/dev/null; then
    pass "Rojo: $(rojo --version 2>&1 | head -1)"
else
    fail_check "Rojo not found. Run: rokit install"
fi

# Wally
if command -v wally &>/dev/null; then
    pass "Wally: $(wally --version 2>&1 | head -1)"
else
    fail_check "Wally not found. Run: rokit install"
fi

# Selene
if command -v selene &>/dev/null; then
    pass "Selene: $(selene --version 2>&1 | head -1)"
else
    warn_check "Selene not found (optional). Run: rokit add kampfkarren/selene"
fi

# StyLua
if command -v stylua &>/dev/null; then
    pass "StyLua: $(stylua --version 2>&1 | head -1)"
else
    warn_check "StyLua not found (optional). Run: rokit add JohnnyMorganz/StyLua"
fi

# rbxcloud
if command -v rbxcloud &>/dev/null; then
    pass "rbxcloud: $(rbxcloud --version 2>&1 | head -1)"
else
    warn_check "rbxcloud not found — needed for CLI publishing. Run: rokit add Sleitnick/rbxcloud"
fi

# ============================================================
header "Project Files"
# ============================================================

PROJECT_DIR="$HOME/roblox"
if [ -f "$PROJECT_DIR/default.project.json" ]; then
    pass "default.project.json exists"
else
    fail_check "default.project.json not found in $PROJECT_DIR"
fi

if [ -d "$PROJECT_DIR/Packages" ] && [ -f "$PROJECT_DIR/Packages/Knit.lua" ]; then
    pass "Packages/Knit.lua exists"
else
    warn_check "Packages not installed. Run: wally install"
fi

if [ -f "$PROJECT_DIR/semantic_slime_built.rbxl" ]; then
    RBXL_SIZE=$(stat -c%s "$PROJECT_DIR/semantic_slime_built.rbxl" 2>/dev/null)
    RBXL_KB=$((RBXL_SIZE / 1024))
    pass "Built .rbxl exists (${RBXL_KB}KB)"
else
    warn_check "No built .rbxl file. Run: rojo build -o semantic_slime_built.rbxl"
fi

# ============================================================
header "Health Report"
# ============================================================

TOTAL=$((PASSED + WARNED + FAILED))
echo -e "  ${GREEN}Passed:   $PASSED${NC}"
echo -e "  ${YELLOW}Warnings: $WARNED${NC}"
echo -e "  ${RED}Failed:   $FAILED${NC}"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "  ${RED}❌ ENVIRONMENT HAS ISSUES — fix the failed items above${NC}"
    exit 1
elif [ "$WARNED" -gt 3 ]; then
    echo -e "  ${YELLOW}⚠  ENVIRONMENT HAS WARNINGS — review items above${NC}"
    exit 0
else
    echo -e "  ${GREEN}✅ ENVIRONMENT LOOKS GOOD${NC}"
    exit 0
fi
