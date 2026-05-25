#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pack_url="${PACKWIZ_PUBLIC_URL:-https://2b2m.org/packwiz/pack.toml}"
bootstrap_version="${PACKWIZ_BOOTSTRAP_VERSION:-v0.0.3}"
bootstrap_jar="packwiz-installer-bootstrap.jar"
bootstrap_url="https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/${bootstrap_version}/${bootstrap_jar}"

cd "$repo_root"

name="$(awk -F '"' '$1 ~ /^name = / { print $2; exit }' pack.toml)"
version="$(awk -F '"' '$1 ~ /^version = / { print $2; exit }' pack.toml)"
minecraft="$(awk -F '"' '$1 ~ /^minecraft = / { print $2; exit }' pack.toml)"
neoforge="$(awk -F '"' '$1 ~ /^neoforge = / { print $2; exit }' pack.toml)"

if [[ -z "$name" || -z "$version" || -z "$minecraft" || -z "$neoforge" ]]; then
  echo "Could not read name, version, minecraft, or neoforge from pack.toml" >&2
  exit 1
fi

mkdir -p dist
output="${1:-dist/${name}-${version}-prism-instance.zip}"
tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

mkdir -p "$tmp_dir/minecraft"
curl -fsSL -o "$tmp_dir/minecraft/$bootstrap_jar" "$bootstrap_url"

cat > "$tmp_dir/instance.cfg" <<EOF
[General]
ConfigVersion=1.3
InstanceType=OneSix
MCLaunchMethod=LauncherPart
MaxMemAlloc=8192
MinMemAlloc=1024
OverrideCommands=true
OverrideMemory=true
PreLaunchCommand="\$INST_JAVA" -jar "$bootstrap_jar" "$pack_url"
name=2b2m
EOF

cat > "$tmp_dir/mmc-pack.json" <<EOF
{
  "formatVersion": 1,
  "components": [
    {
      "uid": "net.minecraft",
      "version": "$minecraft",
      "important": true
    },
    {
      "uid": "net.neoforged",
      "version": "$neoforge"
    }
  ]
}
EOF

(
  cd "$tmp_dir"
  zip -qr "$repo_root/$output" .
)

echo "$output"
