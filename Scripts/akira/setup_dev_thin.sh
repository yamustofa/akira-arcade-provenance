#!/usr/bin/env bash
# Akira Arcade: generate and open the Provenance-Dev-Thin workspace (PS1, N64, SNES, PSP via
# libretro) on a Mac, without the Azahar/Dolphin native slices the other dev apps need.
# Run from anywhere: bash Scripts/akira/setup_dev_thin.sh
# Output is also written to build/akira-setup.log.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
mkdir -p build
exec > >(tee build/akira-setup.log) 2>&1

echo "akira: repo $ROOT"
echo "akira: xcode $(xcodebuild -version | tr '\n' ' ')"

if [ ! -f CodeSigning.xcconfig ]; then
    echo "akira: CodeSigning.xcconfig is missing; copy CodeSigning.xcconfig.sample and set your team" >&2
    exit 1
fi

TUIST_VERSION="$(sed -n 's/^tuist = "\(.*\)"/\1/p' .mise.toml)"
if command -v mise >/dev/null 2>&1; then
    MISE="mise"
elif [ -x "$HOME/.local/bin/mise" ]; then
    MISE="$HOME/.local/bin/mise"
else
    echo "akira: installing mise (tool version manager) into ~/.local/bin"
    curl -fsSL https://mise.run | sh
    MISE="$HOME/.local/bin/mise"
fi
"$MISE" trust --yes "$ROOT/.mise.toml" >/dev/null 2>&1 || true
"$MISE" install "tuist@$TUIST_VERSION"

echo "akira: generating Provenance-Dev.xcworkspace (Thin only)"
TUIST_DEV_ONLY=thin "$MISE" exec -- tuist generate --no-open

echo "akira: done; opening the workspace"
open Provenance-Dev.xcworkspace
