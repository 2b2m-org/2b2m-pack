# Modrinth Export

Build the Modrinth pack with:

```sh
scripts/export-modrinth.sh
```

The output is:

```text
dist/2b2m-<version>.mrpack
```

The export also writes these ignored reports:

```text
dist/modrinth-export-report.json
dist/modrinth-export-report.md
```

## Export Model

The canonical repo keeps CurseForge metadata for CurseForge-hosted mods. That
keeps `scripts/export-curseforge.sh` producing a normal CurseForge manifest
instead of embedding jars that CurseForge already hosts.

For Modrinth, `scripts/export-modrinth.sh` builds from a temporary copy of the
repo:

1. Refresh the canonical pack index and preserve policy.
2. Copy the repo to a temporary export tree, excluding `.git` and `dist/`.
3. Query Modrinth by the exact SHA-1 from each CurseForge metadata file.
4. Rewrite only exact hash matches in the temporary tree to Modrinth metadata.
5. Run `packwiz modrinth export` from the temporary tree.
6. Copy the finished `.mrpack` and report files back to `dist/`.

The source files in `mods/*.pw.toml` are not converted in place.

## Current Coverage

The current exact-hash lookup converts 88 CurseForge metadata files to Modrinth
metadata in the temporary export tree. Together with the one canonical Modrinth
entry, the expected `.mrpack` has 89 Modrinth manifest downloads.

The remaining 40 CurseForge metadata files do not currently have an exact
Modrinth file hash match, so packwiz embeds those jars in `overrides/mods/`.
Review `dist/modrinth-export-report.md` after each export before publishing the
pack publicly.

Create Aeronautics is now covered by the exact Modrinth hash conversion, so the
Modrinth export no longer needs a local manual-download cache seed for that jar.

## Publishing Notes

Modrinth accepts `.mrpack` uploads. Public publishing still requires permission
to redistribute any embedded third-party jars. Do not treat the generated
`.mrpack` as publication-ready until the embedded jar exception list has been
reviewed for the release.

If more projects later publish the same files on Modrinth, the export script
will pick them up automatically by SHA-1 on the next run.
