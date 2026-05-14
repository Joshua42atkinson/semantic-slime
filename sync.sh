#!/bin/bash
# Semantic Slime - Quick Sync Script
# Run this before opening Roblox Studio

cd "$(dirname "$0")"

echo "🚀 Starting Rojo sync for Semantic Slime..."
echo "   Then open Roblox Studio and click 'Connect' in the Rojo plugin"
echo ""

# Kill any existing rojo processes
pkill -f "rojo serve" 2>/dev/null
sleep 1

# Start rojo in serve mode
echo "📡 Starting sync server on port 34872..."
~/.rokit/bin/rojo serve &

echo "✅ Sync server running!"
echo ""
echo "Next steps:"
echo "1. Open Roblox Studio"
echo "2. Click the Rojo plugin"  
echo "3. Click 'Connect' (should show localhost:34872)"
echo ""
echo "To stop: pkill -f 'rojo serve'"
