#!/bin/bash
# Build Semantic Slime to .rbxl file for manual import

cd "$(dirname "$0")"

echo "🏗️  Building Semantic Slime to .rbxl..."
echo ""

# Build using rojo
~/.rokit/bin/rojo build -o "semantic_slime_built.rbxl"

if [ -f "semantic_slime_built.rbxl" ]; then
    echo "✅ Build successful: semantic_slime_built.rbxl"
    echo ""
    echo "To use:"
    echo "1. Open Roblox Studio"
    echo "2. File → Open → select semantic_slime_built.rbxl"
    echo "3. Or: File → Publish to Roblox"
else
    echo "❌ Build failed!"
    exit 1
fi
