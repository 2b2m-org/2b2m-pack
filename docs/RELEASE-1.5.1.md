# 2b2m 1.5.1 Mekanism Security Hotfix

Status: deployed and validated on the NFO production server on August 6, 2026.

## Intended Security Model

2b2m is an anarchy server. Mekanism block and item access protection is therefore
disabled with the following server configuration:

```toml
[security]
allowProtection = false
```

This setting does not affect Mekanism frequencies. Private and trusted
teleporter, QIO, and inventory frequencies retain their normal privacy model;
no frequency or world data was deleted, rewritten, or migrated for this hotfix.

## Root Cause

The 1.5.0 pack accidentally contained `allowProtection = true`, and the cutover
copied that packaged configuration over production's pre-cutover `false` value.
The pre-cutover and live files differed by exactly that one setting. Both sides
used the same `Mekanism-1.21.1-10.7.19.85.jar`, so this was a pack configuration
regression rather than a Mekanism version upgrade or player-data migration.

## Live Correction

At `2026-08-06T21:21:35-04:00`, the corrected configuration was installed
atomically on NFO. Mekanism's NeoForge config listener invalidates its cached
configuration value when the file reloads, so Minecraft did not require a
restart. The Minecraft and website PIDs remained unchanged, both operational
health APIs continued to return HTTP 200 with `serverReady=true`, and no
post-change error or fatal journal entry appeared.

| Configuration state | SHA-256 |
| --- | --- |
| Incorrect 1.5.0 live file | `a8bb97c54d0b04836638f58122d28d35ba6d27b90983a28d3ace8e63097a39dc` |
| Corrected 1.5.1 file | `d3647a37ed800fac28ed005efe3764390e237e50fc11a1617234e940fd101d42` |

The corrected file is byte-for-byte identical to the pre-cutover production
configuration. Exact before/after evidence is preserved at:

- `/hdd/2b2m/.release-staging/1.5.0-fa88c18-cutover/mekanism-general.toml.pre-allow-protection-hotfix`
- `/hdd/2b2m/.release-staging/1.5.0-fa88c18-cutover/mekanism-general.toml.allow-protection-disabled`

## Release References

- Pack hotfix commit: `8b28e919a7fd8881585d28753e91fdb905fa10bb`
- Git branches: `main` and `staging`
- Minecraft: `1.21.1`
- NeoForge: `21.1.248`
- CurseForge project: `1530503` (`org-2b2m`)
- CurseForge upload: file ID `8591889`
- Production Packwiz feed: `https://2b2m.org/packwiz/pack.toml`

CurseForge published file ID `8591889` as the project's main release. Its public
release notes state that Mekanism block and item access protection is disabled,
frequency privacy is unchanged, and the mod payload is unchanged from 1.5.0.
The public Packwiz feed and Prism bootstrap are also live on 1.5.1.

## Artifact Audit

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.5.1-curseforge.zip` | `d21b14483a361945febd76078c36ecb2a0d446f68c6771e6a0531dbede2f9cf2` |
| `2b2m-1.5.1.mrpack` | `87c4c55314c92b947749048cc4addd1f80b06d92111f65b71e6359e4a6361b28` |
| Public `2b2m-prism-instance.zip` | `089947d6ab6e8c486ae60d12ae724843e02e043b457a106df60dc4856d28f618` |
| Unchanged 1.5.0 server base archive | `c40e1bf412a487912ffa3a20fec66e7cb2e961d17ba01b52afebee7a8bd9e12c` |

The server mod payload did not change, so no replacement full server archive was
required. The live server received only the corrected configuration. The public
Packwiz `pack.toml` SHA-256 is
`24759afc9b871d132b31fffcf98a40d18052852ec5e4708a4601e8e4c2dcf87d`,
and its referenced index SHA-256 is
`348aed8fb4778fea294f1fddf2c5b8ab04e2b2e731267957418d7847e9ed109e`.

## Independent Client Bootstrap

An empty-directory run of the exact public Prism pre-launch command successfully
processed all 634 Packwiz entries and installed exactly 144 client jars. The
installed Mekanism configuration had the corrected SHA-256 and
`allowProtection = false`; the updater reported 1.5.1. No `Generic*`,
MineColonies, BlockUI, Domum Ornamentum, Multi-Piston, Structurize, or TownTalk
jar was present.

## Rollback and Scope

The stopped-state 1.5.0 backup remains at
`/hdd/2b2m-backups/cutover-1.5.0-20260807T001105Z`. The pre-hotfix configuration,
the corrected configuration, the pre-1.5.1 public feeds, and the pre-1.5.1
website remain preserved under the release-staging directory. This hotfix did
not restart Minecraft, replace any mod jar, modify the world, change frequency
privacy, route traffic through the Mac, or activate a staging relay.
