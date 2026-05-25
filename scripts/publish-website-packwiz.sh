#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${PACKWIZ_WEBSITE_ROOT:-/var/www/2b2m-packwiz}"
downloads_target="${PACKWIZ_DOWNLOADS_ROOT:-/var/www/2b2m-downloads}"
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

mkdir -p "$downloads_target"
instance_zip="$(scripts/export-prism-instance.sh)"
install -m 644 "$instance_zip" "$downloads_target/2b2m-prism-instance.zip"

echo "$target/pack.toml"
echo "$downloads_target/2b2m-prism-instance.zip"
