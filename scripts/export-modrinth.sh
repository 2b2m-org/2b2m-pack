#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

version="$(awk -F '"' '$1 ~ /^version = / { print $2; exit }' pack.toml)"
if [[ -z "$version" ]]; then
  echo "Could not read pack version from pack.toml" >&2
  exit 1
fi

ensure_create_aeronautics_cache() {
  local meta="mods/create-aeronautics.pw.toml"
  local filename expected_hash cache_path

  filename="$(awk -F '"' '$1 ~ /^filename = / { print $2; exit }' "$meta")"
  expected_hash="$(awk -F '"' '$1 ~ /^hash = / { print $2; exit }' "$meta")"
  cache_path="/root/.cache/packwiz/cache/import/$filename"

  [[ -n "$filename" && -n "$expected_hash" ]] || return 0

  if [[ -f "$cache_path" ]] && [[ "$(sha1sum "$cache_path" | awk '{print $1}')" == "$expected_hash" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$cache_path")"

  local candidates=(
    "/root/dev/2b2m-staging-server/client-required-extra-mods/$filename"
    "/root/dev/2b2m-staging-server/server/mods/$filename"
    "/root/dev/2b2m-dev-server/server/mods/$filename"
    "/root/dev/2b2m-side-dev-server/server/mods/$filename"
    "/root/dev/aeronautics-sable-dev-server/server/mods/$filename"
    "/hdd/2b2m/mods/$filename"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate" ]] && [[ "$(sha1sum "$candidate" | awk '{print $1}')" == "$expected_hash" ]]; then
      cp -f "$candidate" "$cache_path"
      return 0
    fi
  done

  echo "Missing manual Modrinth export cache for $filename" >&2
  echo "Expected SHA-1: $expected_hash" >&2
  echo "Place the jar at: $cache_path" >&2
  return 1
}

scripts/refresh.sh
ensure_create_aeronautics_cache
mkdir -p dist

output="dist/2b2m-${version}.mrpack"
packwiz modrinth export --output "$output"

echo "$output"
