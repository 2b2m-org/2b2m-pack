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

output="dist/2b2m-${version}-curseforge.zip"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

full_export="$tmp/full.zip"
work="$tmp/work"
src_overrides="$work/overrides"
client_overrides="$tmp/client-overrides"

packwiz curseforge export --side client --output "$full_export"
unzip -q "$full_export" -d "$work"
rm -rf "$client_overrides"
mkdir -p "$client_overrides"

copy_override_path() {
  local rel="$1"
  [[ -e "$src_overrides/$rel" ]] || return 0
  mkdir -p "$client_overrides/$(dirname "$rel")"
  cp -a "$src_overrides/$rel" "$client_overrides/$rel"
}

copy_override_glob() {
  local pattern="$1"
  local src rel
  shopt -s nullglob globstar dotglob
  for src in "$src_overrides"/$pattern; do
    [[ -f "$src" ]] || continue
    rel="${src#"$src_overrides"/}"
    mkdir -p "$client_overrides/$(dirname "$rel")"
    cp -a "$src" "$client_overrides/$rel"
  done
}

# Keep only client-side overrides in the CurseForge client import. Server data,
# server configs, defaultconfigs, and KubeJS server/data packs belong in the
# server package, not in the client installer.
copy_override_path "mods"
copy_override_path "servers.dat"
copy_override_path "options.txt"
copy_override_path "keybind_bundles.json"
copy_override_glob "config/**/*client*"
copy_override_glob "config/jei/**"
copy_override_glob "config/fancymenu/**"
copy_override_glob "config/justzoom/**"
copy_override_glob "config/xaero/**"
copy_override_glob "config/fzzy_config/**"
copy_override_glob "config/modpack-update-checker/**"
copy_override_glob "config/sodium-*"
copy_override_path "config/DistantHorizons.toml"
copy_override_path "config/farsight.json"
copy_override_path "config/autoreconnectrf.json"
copy_override_path "config/yacl.json5"
copy_override_path "config/xaerohud.txt"
copy_override_path "config/xaeropatreon.txt"
copy_override_path "config/voicechat/category-volumes.properties"
copy_override_path "config/voicechat/translations.properties"
copy_override_glob "kubejs/client_scripts/**"
copy_override_path "kubejs/config/client.json"
copy_override_path "kubejs/config/defaultoptions.txt"

rm -rf "$client_overrides"/config/xaero/*/server_profiles
rm -f "$client_overrides"/config/xaero/minimap/default_radar_categories_server.json

rm -rf "$src_overrides"
mkdir -p "$src_overrides"
cp -a "$client_overrides"/. "$src_overrides"/
find "$src_overrides" -type d -empty -delete

rm -f "$repo_root/$output"
(cd "$work" && zip -qr "$repo_root/$output" .)

echo "$output"
