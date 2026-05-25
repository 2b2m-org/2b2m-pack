#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

zip_path="${1:-}"
release_type="${2:-release}"
changelog="${3:-}"
token_file="${CURSEFORGE_UPLOAD_TOKEN_FILE:-/root/.config/curseforge/upload-api-token.env}"

if [[ -z "$zip_path" ]]; then
  echo "Usage: scripts/upload-curseforge.sh <zip> [alpha|beta|release] [changelog]" >&2
  exit 1
fi

if [[ ! -f "$zip_path" ]]; then
  echo "Missing zip: $zip_path" >&2
  exit 1
fi

case "$release_type" in
  alpha|beta|release) ;;
  *)
    echo "Invalid release type: $release_type" >&2
    exit 1
    ;;
esac

if [[ -f "$token_file" ]]; then
  # shellcheck disable=SC1090
  source "$token_file"
fi

token="${CURSEFORGE_UPLOAD_API_TOKEN:-${CF_UPLOAD_API_TOKEN:-}}"
if [[ -z "$token" ]]; then
  echo "Set CURSEFORGE_UPLOAD_API_TOKEN or CF_UPLOAD_API_TOKEN" >&2
  exit 1
fi

display_name="$(basename "$zip_path")"
display_name="${display_name%.zip}.zip"
if [[ -z "$changelog" ]]; then
  changelog="Pack export ${display_name}"
fi

metadata="$(jq -nc \
  --arg changelog "$changelog" \
  --arg displayName "$display_name" \
  --arg releaseType "$release_type" \
  '{
    changelog: $changelog,
    changelogType: "markdown",
    displayName: $displayName,
    gameVersions: [11779, 10150],
    releaseType: $releaseType
  }')"

curl --fail-with-body \
  -H "X-Api-Token: ${token}" \
  -F "metadata=${metadata};type=application/json" \
  -F "file=@${zip_path}" \
  "https://minecraft.curseforge.com/api/projects/1530503/upload-file"
