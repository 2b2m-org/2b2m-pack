# 2b2m Pack

Canonical packwiz source for the 2b2m client modpack.

This repository manages the pack that is published to CurseForge project `1530503`
(`org-2b2m`). It is intentionally separate from the live server tree under
`/hdd/2b2m`, which contains server-only operational mods and runtime state.

## Layout

- `pack.toml` and `index.toml`: packwiz pack metadata and file index.
- `mods/*.pw.toml`: pinned mod metadata from CurseForge and Modrinth.
- `config/`, `defaultconfigs/`, `kubejs/`, `options.txt`, `servers.dat`: pack overrides.
- `update-feed/`: public Modpack Update Checker metadata and changelogs.
- `scripts/`: local maintainer commands. These are excluded from pack exports.
- `dist/`: generated exports. This directory is ignored by git.

## Common Commands

Refresh the pack index after manual file changes:

```sh
scripts/refresh.sh
```

`scripts/refresh.sh` also reapplies the config preservation policy so shipped
config files seed new installs without overwriting local edits during
packwiz-based updates.

Build the CurseForge upload zip:

```sh
scripts/export-curseforge.sh
```

Build a Modrinth `.mrpack`:

```sh
scripts/export-modrinth.sh
```

The Modrinth export converts exact SHA-1 matches to Modrinth metadata in a
temporary export tree, then embeds only the remaining CurseForge-only jar
exceptions. See `docs/MODRINTH.md` and the generated
`dist/modrinth-export-report.md` before publishing it publicly.

Upload an exported zip to CurseForge:

```sh
scripts/upload-curseforge.sh dist/2b2m-1.3.3-curseforge.zip release "Release 1.3.3"
```

The upload script reads `/root/.config/curseforge/upload-api-token.env` by
default. Do not commit API tokens or generated export zips.

Publish the packwiz source tree and Prism/MultiMC instance zip to the website:

```sh
scripts/publish-website-packwiz.sh
```

This publishes a temporary exact-hash Modrinth-converted tree, not the
canonical CurseForge-first source files. That keeps packwiz-installer users away
from known manual CurseForge downloads such as Create Aeronautics.

The public updater URL is:

```text
https://2b2m.org/packwiz/pack.toml
```

The public Prism/MultiMC instance download is:

```text
https://2b2m.org/downloads/2b2m-prism-instance.zip
```

Useful pack health checks:

```sh
packwiz list --version
scripts/refresh.sh
git diff --check
unzip -t dist/2b2m-1.3.3-curseforge.zip
unzip -t dist/2b2m-1.3.3.mrpack
```

## Notes

CC: Tweaked `1.118.0` is sourced from Modrinth because the matching 1.21.1
NeoForge file is not on CurseForge. Packwiz will embed that jar into the
CurseForge export, so CurseForge moderation still needs to accept it as a
third-party override mod.
