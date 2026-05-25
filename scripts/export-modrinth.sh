#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

version="$(awk -F '"' '$1 ~ /^version = / { print $2; exit }' pack.toml)"
if [[ -z "$version" ]]; then
  echo "Could not read pack version from pack.toml" >&2
  exit 1
fi

scripts/refresh.sh
mkdir -p dist

output="dist/2b2m-${version}.mrpack"
python3 scripts/prepare-modrinth-export.py --output "$output"

echo "$output"
