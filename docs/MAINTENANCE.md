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
7. Commit and push the pack source changes.

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
