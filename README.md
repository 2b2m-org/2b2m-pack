# 2b2m Pack

Canonical packwiz source for the 2b2m client modpack.

This repository manages the pack that is published to CurseForge project `1530503`
(`org-2b2m`). It is intentionally separate from the live server tree under
`/hdd/2b2m`, which contains server-only operational mods and runtime state.

## Layout

- `pack.toml` and `index.toml`: packwiz pack metadata and file index.
- `mods/*.pw.toml`: pinned mod metadata from CurseForge and Modrinth.
- `config/`, `defaultconfigs/`, `kubejs/`, `options.txt`, `servers.dat`: pack overrides.
- `scripts/`: local maintainer commands. These are excluded from pack exports.
- `dist/`: generated exports. This directory is ignored by git.

## Common Commands

Refresh the pack index after manual file changes:

```sh
scripts/refresh.sh
```

Build the CurseForge upload zip:

```sh
scripts/export-curseforge.sh
```

Upload an exported zip to CurseForge:

```sh
scripts/upload-curseforge.sh dist/2b2m-1.3.3-curseforge.zip release "Release 1.3.3"
```

The upload script reads `/root/.config/curseforge/upload-api-token.env` by
default. Do not commit API tokens or generated export zips.

## Notes

CC: Tweaked `1.118.0` is sourced from Modrinth because the matching 1.21.1
NeoForge file is not on CurseForge. Packwiz will embed that jar into the
CurseForge export, so CurseForge moderation still needs to accept it as a
third-party override mod.
