#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

tmp="$(mktemp)"
awk '
function should_preserve(path) {
  if (path == "config/modpack-update-checker/config.json") {
    return 0
  }
  return path ~ /^(config\/|defaultconfigs\/|options\.txt$|servers\.dat$|keybind_bundles\.json$)/
}

function should_force_unpreserve(path) {
  return path == "config/modpack-update-checker/config.json"
}

function flush_block() {
  if (!in_block) {
    return
  }
  if (should_force_unpreserve(file_path)) {
    if (has_preserve) {
      sub(/preserve = true/, "preserve = false", block)
    }
  } else if (should_preserve(file_path)) {
    if (has_preserve) {
      sub(/preserve = false/, "preserve = true", block)
    } else {
      block = block "preserve = true\n"
    }
  }
  printf "%s", block
}

BEGIN {
  in_block = 0
  block = ""
  file_path = ""
  has_preserve = 0
}

$0 == "[[files]]" {
  flush_block()
  in_block = 1
  block = $0 "\n"
  file_path = ""
  has_preserve = 0
  next
}

in_block {
  block = block $0 "\n"
  if ($0 ~ /^file = "/) {
    file_path = $0
    sub(/^file = "/, "", file_path)
    sub(/"$/, "", file_path)
  }
  if ($0 ~ /^preserve = /) {
    has_preserve = 1
  }
  next
}

{
  print
}

END {
  flush_block()
}
' index.toml > "$tmp"

mv "$tmp" index.toml
