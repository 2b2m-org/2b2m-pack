#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

rm -rf config/jei/world

find . -type f \
  \( -name '*.bak' -o -name '*.backup*' -o -name '*~' \) \
  -delete

rm -f config/sodium-fingerprint.json
rm -f config/almostunified/.gitignore
rm -f mods/cc-tweaked-1.21.1-forge-1.118.0.jar

find . -type d -empty -delete
