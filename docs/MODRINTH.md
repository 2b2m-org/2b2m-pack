# Modrinth Export

Build the Modrinth pack with:

```sh
scripts/export-modrinth.sh
```

The output is:

```text
dist/2b2m-<version>.mrpack
```

## Current State

The pack can be exported to `.mrpack`, and the generated archive validates with
`unzip -t`.

This is not yet a clean Modrinth-native pack. Most dependencies are currently
tracked with CurseForge metadata, so packwiz embeds those jars into
`overrides/mods/` in the `.mrpack`. Only dependencies with Modrinth metadata can
be listed as normal Modrinth downloads in `modrinth.index.json`.

As of the first export:

- 1 dependency is represented as a Modrinth manifest download: CC: Tweaked.
- 128 dependency jars are embedded in `overrides/mods/`.
- Create Aeronautics requires a manual-download cache entry because CurseForge
  does not provide that file through the packwiz download path.

`scripts/export-modrinth.sh` seeds the Create Aeronautics cache from known local
2b2m server/dev paths when the jar hash matches `mods/create-aeronautics.pw.toml`.

## Publishing Notes

Modrinth accepts `.mrpack` uploads, but public publishing requires permission to
redistribute any embedded third-party jars. The long-term cleanup path is to
replace CurseForge metadata with Modrinth metadata wherever the exact file exists
on Modrinth. That will shrink the `.mrpack` and reduce redistribution risk.
