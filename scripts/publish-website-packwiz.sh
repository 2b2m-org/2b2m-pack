#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${PACKWIZ_WEBSITE_ROOT:-/var/www/2b2m-packwiz}"
staging="$(mktemp -d)"

cleanup() {
  rm -rf "$staging"
}
trap cleanup EXIT

cd "$repo_root"

scripts/refresh.sh

python3 scripts/prepare-modrinth-export.py \
  --packwiz-tree-output "$staging/pack" \
  --skip-mrpack

mkdir -p "$target"

rsync -a --delete "$staging/pack/" "$target/"

find "$target" -type d -exec chmod 755 {} +
find "$target" -type f -exec chmod 644 {} +

echo "$target/pack.toml"
