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

## Release Coverage

Each export writes `dist/modrinth-export-report.json` and
`dist/modrinth-export-report.md`. Those generated reports are authoritative
for the exact release candidate; do not copy their changing project counts or
exception table into this maintenance document.

Review both `overrides/mods/` and `client-overrides/mods/` when checking the
archive. Client-only embedded jars use the latter path.

## Publishing Notes

Modrinth accepts `.mrpack` uploads. Public publishing still requires permission
to redistribute any embedded third-party jars. Do not treat the generated
`.mrpack` as publication-ready until the embedded jar exception list has been
reviewed for the release.

If more projects later publish the same files on Modrinth, the export script
will pick them up automatically by SHA-1 on the next run.

## Upload Readiness

For every public upload, validate the generated archive, review the exact
embedded-jar report, and scan the pack source and archive for prohibited client
mods. Record release-specific counts and decisions in that release's audit.

Every embedded CurseForge-only jar still needs one of these before public
submission:

- an exact matching file published on Modrinth,
- an open-source license that allows redistribution,
- a project description statement allowing use in Modrinth modpacks, or
- explicit author permission attached in the Modrinth moderation tab.
