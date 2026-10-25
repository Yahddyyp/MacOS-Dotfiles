#!/bin/sh
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$DIR/../libnowplaying.dylib}"

echo "Building libnowplaying.dylib..."
swiftc -O -emit-library -module-name SketchybarNowPlaying \
  "$DIR/NowPlayingAdapter.swift" \
  "$DIR/NowPlayingSelection.swift" \
  "$DIR/NotchPlaybackSource.swift" \
  -o "$OUTPUT"

codesign --force --sign - "$OUTPUT"
echo "Done -> $OUTPUT"
