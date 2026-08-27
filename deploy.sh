#!/bin/bash
# Build Axle in Blocks and drop the packaged mod into the local Vintage Story
# Mods folder. Wraps the upstream Cake build (build.sh) rather than repackaging
# by hand, so what gets deployed is byte-for-byte what a release would ship.
set -e

MOD_ID="axleinblocks"
MODS_DIR="$HOME/.config/VintagestoryData/Mods"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# The upstream .csproj resolves the game DLLs through $VINTAGE_STORY.
export VINTAGE_STORY="${VINTAGE_STORY:-$HOME/Apps/vintagestory}"

if [ ! -f "$VINTAGE_STORY/VintagestoryAPI.dll" ]; then
    echo "VintagestoryAPI.dll not found under VINTAGE_STORY=$VINTAGE_STORY" >&2
    exit 1
fi

echo "=== Building (Cake: validate JSON -> clean -> publish -> zip) ==="
bash "$SCRIPT_DIR/build.sh"

VERSION=$(grep -oP '"version":\s*"\K[^"]+' "$SCRIPT_DIR/AxleInBlocks/modinfo.json")
ZIP_NAME="${MOD_ID}_${VERSION}.zip"
BUILT_ZIP="$SCRIPT_DIR/Releases/$ZIP_NAME"

if [ ! -f "$BUILT_ZIP" ]; then
    echo "Expected $BUILT_ZIP but the build did not produce it" >&2
    exit 1
fi

echo "=== Deploying ==="
# Older copies are removed so the game never loads two versions side by side.
rm -f "$MODS_DIR/$MOD_ID"*.zip
cp "$BUILT_ZIP" "$MODS_DIR/$ZIP_NAME"

echo "=== Deployed to $MODS_DIR/$ZIP_NAME ==="
