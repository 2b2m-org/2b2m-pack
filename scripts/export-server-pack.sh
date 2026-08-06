#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

usage() {
  cat <<'EOF'
Usage: scripts/export-server-pack.sh --server-root PATH [--output PATH]

Build an internal server package from an explicitly marked staging runtime.
PATH must contain a .2b2m-server-pack-source marker and must not be the live
production server directory.
EOF
}

server_root=""
output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server-root)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      server_root="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      output="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$server_root" ]]; then
  echo "--server-root is required" >&2
  usage >&2
  exit 2
fi

if [[ ! -d "$server_root" ]]; then
  echo "Server root does not exist: $server_root" >&2
  exit 1
fi

server_root="$(cd "$server_root" && pwd -P)"
if [[ "$server_root" == "/hdd/2b2m" ]]; then
  echo "Refusing the production server root: $server_root" >&2
  exit 1
fi
if [[ ! -f "$server_root/.2b2m-server-pack-source" ]]; then
  echo "Refusing unmarked server root: $server_root" >&2
  echo "Create .2b2m-server-pack-source only in a disposable or staging runtime." >&2
  exit 1
fi
source_label="$(head -n 1 "$server_root/.2b2m-server-pack-source")"
if [[ -z "$source_label" ]]; then
  echo "Server source marker must contain a short source label" >&2
  exit 1
fi

version="$(awk -F '"' '$1 ~ /^version = / { print $2; exit }' pack.toml)"
if [[ -z "$version" ]]; then
  echo "Could not read pack version from pack.toml" >&2
  exit 1
fi
neoforge_version="$(awk -F '"' '$1 ~ /^neoforge = / { print $2; exit }' pack.toml)"
if [[ -z "$neoforge_version" ]]; then
  echo "Could not read NeoForge version from pack.toml" >&2
  exit 1
fi

output="${output:-dist/2b2m-${version}-server.zip}"
if [[ "$output" = /* ]]; then
  output_path="$output"
else
  output_path="$repo_root/$output"
fi

for required in mods config defaultconfigs kubejs run.sh user_jvm_args.txt; do
  if [[ ! -e "$server_root/$required" ]]; then
    echo "Missing required server file or directory: $server_root/$required" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$output_path")"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

stage="$tmp/2b2m-${version}-server"
mkdir -p "$stage"

rsync -a "$server_root/mods" "$stage/"
rsync -a "$server_root/config" "$stage/"
rsync -a "$server_root/defaultconfigs" "$stage/"
rsync -a "$server_root/kubejs" "$stage/"
cp -a "$server_root/run.sh" "$stage/run.sh"
cp -a "$server_root/user_jvm_args.txt" "$stage/user_jvm_args.txt"
[[ -f "$server_root/eula.txt" ]] && cp -a "$server_root/eula.txt" "$stage/eula.txt"

rm -rf "$stage/config/fancymenu"
rm -rf "$stage/config/justzoom"
rm -rf "$stage/config/xaero"
rm -rf "$stage/config/worldedit"
rm -rf "$stage/config/jei/world"
rm -f "$stage/config/DistantHorizons.toml"
rm -f "$stage/config/autoreconnectrf.json"
rm -f "$stage/config/farsight.json"
rm -f "$stage/config/keybindbundles-client.toml"
rm -f "$stage/config/lightaura-client.toml"
rm -f "$stage/config/sodium-fingerprint.json"
rm -f "$stage/config/sodium-mixins.properties"
rm -f "$stage/config/sodium-options.json"
rm -f "$stage/config/xaerohud.txt"
rm -f "$stage/config/xaeropatreon.txt"
rm -f "$stage/config/yacl.json5"
rm -rf "$stage/config/fzzy_config"
rm -f "$stage/config/genericspectate/keyed-login-names.txt"
rm -f "$stage/config/genericspectate/keyed-login-secret.txt"
rm -f "$stage/config/voicechat/category-volumes.properties"
rm -f "$stage/config/voicechat/player-volumes.properties"
rm -f "$stage/config/voicechat/translations.properties"
rm -f "$stage/config/voicechat/username-cache.json"
rm -rf "$stage/config/spark/tmp-client"
rm -f "$stage/kubejs/config/client.json"
find "$stage" -type d -name codex-backups -prune -exec rm -rf {} +
find "$stage" -type f \( -name '*.bak' -o -name '*.bak-*' -o -name '*~' -o -name '*.orig' -o -name '*.orig-*' \) -delete
find "$stage/config" -type f \( -iname '*client*' -o -iname 'client.*' \) -delete
rm -f "$stage/mods"/genericclientcompanion-*.jar
rm -f "$stage/mods"/genericevents_client-*.jar

expected_mods="$tmp/expected-server-mods.txt"
: > "$expected_mods"

for metadata in "$repo_root"/mods/*.pw.toml; do
  side="$(awk -F '"' '/^side = / { print $2; exit }' "$metadata")"
  filename="$(awk -F '"' '/^filename = / { print $2; exit }' "$metadata")"
  if [[ -z "$side" || -z "$filename" ]]; then
    echo "Invalid packwiz mod metadata: $metadata" >&2
    exit 1
  fi
  case "$side" in
    client)
      rm -f "$stage/mods/$filename"
      ;;
    both|server)
      if [[ ! -f "$stage/mods/$filename" ]]; then
        echo "Server-capable pack mod is missing from $server_root/mods: $filename" >&2
        exit 1
      fi
      printf '%s\n' "$filename" >> "$expected_mods"
      ;;
    *)
      echo "Unsupported packwiz side '$side' in $metadata" >&2
      exit 1
      ;;
  esac
done

sort -u -o "$expected_mods" "$expected_mods"
actual_mods="$tmp/actual-server-mods.txt"
find "$stage/mods" -maxdepth 1 -type f -name '*.jar' -exec basename {} \; | sort -u > "$actual_mods"
comm -13 "$expected_mods" "$actual_mods" > "$stage/SERVER-EXTRA-MODS.txt"

server_mod_count="$(find "$stage/mods" -maxdepth 1 -type f -name '*.jar' | wc -l)"
pack_mod_count="$(wc -l < "$expected_mods" | tr -d ' ')"
extra_mod_count="$(wc -l < "$stage/SERVER-EXTRA-MODS.txt" | tr -d ' ')"
(cd "$stage/mods" && sha256sum -- *.jar | sort -k2) > "$stage/SERVER-MODS.sha256"

cat > "$stage/README-server.txt" <<EOF
2b2m ${version} server pack

Staging source: ${source_label}

This package intentionally excludes server.properties because runtime copies can
contain local ports and RCON credentials. Create or copy server.properties when
installing this package.

Minecraft: 1.21.1
NeoForge: ${neoforge_version}
Pack server mods: ${pack_mod_count}
Operational server-only extras: ${extra_mod_count}
Total server mods: ${server_mod_count}

Packwiz entries marked client-only are excluded. Entries marked both or server
must be present, including mixed-side mods such as Jade and JEI. Additional
server-only operational mods present in the source runtime are retained and
listed in SERVER-EXTRA-MODS.txt.
EOF

rm -f "$output_path"
(cd "$stage" && zip -qr "$output_path" .)
echo "$output_path"
