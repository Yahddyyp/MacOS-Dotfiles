#!/bin/sh
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$DIR/../libnowplaying.dylib}"

mkdir -p "$(dirname "$OUTPUT")"

echo "Building $(basename "$OUTPUT")..."
xcrun swiftc -O \
  -parse-as-library \
  -emit-library \
  -module-name SketchybarNowPlaying \
  "$DIR/NowPlayingAdapter.swift" \
  "$DIR/NowPlayingSelection.swift" \
  "$DIR/NowPlayingSource.swift" \
  -o "$OUTPUT"

codesign --force --sign - "$OUTPUT"
echo "Done -> $OUTPUT"
