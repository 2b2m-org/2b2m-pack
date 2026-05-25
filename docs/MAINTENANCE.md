# Maintenance

Use this repo as the source of truth for the client pack. Avoid copying from a
running Minecraft instance without cleaning generated state first.

## Normal Release Flow

1. Edit pack files or update mods with packwiz.
2. Run `scripts/refresh.sh`.
3. Review `git diff`.
4. Run `scripts/export-curseforge.sh`.
5. Import the generated zip into a fresh launcher profile when the change is risky.
6. Upload with `scripts/upload-curseforge.sh`.
7. Run `scripts/publish-website-packwiz.sh` to update the website-hosted packwiz tree and Prism/MultiMC instance zip.
8. Commit and push the pack source changes.

## Pack Health Commands

There is no single packwiz doctor command, but these commands cover the useful
checks:

```sh
packwiz list --version
scripts/refresh.sh
git diff --check
scripts/export-curseforge.sh
scripts/export-modrinth.sh
scripts/publish-website-packwiz.sh
unzip -t dist/2b2m-1.3.3-curseforge.zip
unzip -t dist/2b2m-1.3.3.mrpack
```

Use `packwiz update --all` only on a branch or when you are ready to review a
real dependency bump. It mutates metadata instead of reporting pending updates.

## Importing From a CurseForge Export

For a future full re-import, use a clean branch or temp directory:

```sh
packwiz -y curseforge import /path/to/2b2m-version-curseforge.zip
scripts/refresh.sh
```

The cleanup script removes common local-only files:

- backup config files
- JEI world-local history/bookmarks
- Sodium fingerprint data
- accidentally bundled CC: Tweaked jar, since it is tracked via Modrinth metadata

## Config Preservation

Pack config files are seeded into new installs but should not clobber local
changes on packwiz-based updates. `scripts/refresh.sh` runs
`scripts/apply-preserve-policy.sh`, which marks these index entries with
`preserve = true`:

- `config/**`
- `defaultconfigs/**`
- `options.txt`
- `servers.dat`
- `keybind_bundles.json`

Do not mark `mods/*.pw.toml` or `kubejs/**` as preserved. Mod metadata and
pack gameplay scripts need to update authoritatively.

CurseForge exports do not have an equivalent per-file preserve flag in their
manifest format, so this preservation policy is for packwiz-aware installs and
updates.
