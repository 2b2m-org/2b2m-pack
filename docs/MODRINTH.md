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

## Current Embedded Exceptions

As of the May 25, 2026 export, these CurseForge files are still embedded because
Modrinth did not return an exact SHA-1 match:

| Mod | Metadata | CurseForge project | CurseForge file |
| --- | --- | --- | --- |
| The Aether | `mods/aether.pw.toml` | `255308` | `7043502` |
| Apotheosis | `mods/apotheosis.pw.toml` | `313970` | `8102047` |
| Apothic Attributes | `mods/apothic-attributes.pw.toml` | `898963` | `7445079` |
| Apothic Enchanting | `mods/apothic-enchanting.pw.toml` | `1063926` | `8107222` |
| Apothic Spawners | `mods/apothic-spawners.pw.toml` | `986583` | `7492121` |
| Balm | `mods/balm.pw.toml` | `531761` | `7420963` |
| BlockUI | `mods/blockui.pw.toml` | `522992` | `7541336` |
| Cataclysmic Combat | `mods/cataclysmic-combat.pw.toml` | `880483` | `6735019` |
| Configured | `mods/configured.pw.toml` | `457570` | `7276577` |
| Construction Sticks | `mods/construction-sticks.pw.toml` | `1156098` | `7687867` |
| Create Aeronautics: Mekanism Compatibility | `mods/create-aeronautics-mekanism-compatibility.pw.toml` | `1536749` | `8143971` |
| Create: Tracks | `mods/create-tracks.pw.toml` | `1519765` | `7968280` |
| Cupboard | `mods/cupboard.pw.toml` | `326652` | `7746488` |
| Domum Ornamentum | `mods/domum-ornamentum.pw.toml` | `527361` | `7789217` |
| Extreme Reactors | `mods/extreme-reactors.pw.toml` | `250277` | `7344744` |
| Farsight [Forge/Neo] | `mods/farsight.pw.toml` | `495693` | `7016590` |
| FTB Filter System | `mods/ftb-filter-system.pw.toml` | `943925` | `7429011` |
| FTB Library (NeoForge) | `mods/ftb-library-forge.pw.toml` | `404465` | `7746959` |
| FTB Quests (NeoForge) | `mods/ftb-quests-forge.pw.toml` | `289412` | `7878289` |
| FTB Teams (NeoForge) | `mods/ftb-teams-forge.pw.toml` | `404468` | `7878281` |
| FTB Ultimine (NeoForge) | `mods/ftb-ultimine-forge.pw.toml` | `386134` | `8078515` |
| FTB XMod Compat | `mods/ftb-xmod-compat.pw.toml` | `889915` | `7715134` |
| GraveStone Mod | `mods/gravestone-mod.pw.toml` | `238551` | `8056307` |
| KeyBind Bundles | `mods/keybind-bundles.pw.toml` | `1172594` | `7508312` |
| Kotlin for Forge | `mods/kotlin-for-forge.pw.toml` | `351264` | `7471280` |
| KubeJS | `mods/kubejs.pw.toml` | `238086` | `8083208` |
| L_Ender 's Cataclysm | `mods/lendercataclysm.pw.toml` | `551586` | `8095590` |
| Lionfish API | `mods/lionfish-api.pw.toml` | `1001614` | `8094835` |
| MineColonies | `mods/minecolonies.pw.toml` | `245506` | `8138370` |
| Multi-Piston | `mods/multi-piston.pw.toml` | `303278` | `7097877` |
| Open Parties and Claims | `mods/open-parties-and-claims.pw.toml` | `636608` | `8091505` |
| Placebo | `mods/placebo.pw.toml` | `283644` | `6926281` |
| Rhino | `mods/rhino.pw.toml` | `416294` | `7104526` |
| Sophisticated Backpacks Create Integration | `mods/sophisticated-backpacks-create-integration.pw.toml` | `1238567` | `7168412` |
| Sophisticated Backpacks | `mods/sophisticated-backpacks.pw.toml` | `422301` | `8136855` |
| Sophisticated Core | `mods/sophisticated-core.pw.toml` | `618298` | `8140101` |
| Structurize | `mods/structurize.pw.toml` | `298744` | `8138382` |
| TownTalk | `mods/towntalk.pw.toml` | `900364` | `5653504` |
| TrashSlot | `mods/trashslot.pw.toml` | `235577` | `8019502` |
| ZeroCore 2 | `mods/zerocore.pw.toml` | `247921` | `7344742` |

## Publishing Notes

Modrinth accepts `.mrpack` uploads. Public publishing still requires permission
to redistribute any embedded third-party jars. Do not treat the generated
`.mrpack` as publication-ready until the embedded jar exception list has been
reviewed for the release.

If more projects later publish the same files on Modrinth, the export script
will pick them up automatically by SHA-1 on the next run.

## Upload Readiness

As of the May 25, 2026 audit, the generated `.mrpack` is structurally valid and
the pack source plus generated CurseForge/Modrinth exports have no `xray`,
`x-ray`, `freecam`, `baritone`, `meteor`, `wurst`, or `aristois` path/content
matches.

The remaining public-upload blocker is embedded jar redistribution. The 89
manifest downloads are covered by Modrinth-hosted files. The 40 embedded
CurseForge-only jars still need one of these before public submission:

- an exact matching file published on Modrinth,
- an open-source license that allows redistribution,
- a project description statement allowing use in Modrinth modpacks, or
- explicit author permission attached in the Modrinth moderation tab.
