# 2b2m 1.6.0 Stable Mod Refresh

Status: deployed to production and verified on August 30, 2026.

## Release scope

This release updates 39 tracked mods to current stable Minecraft 1.21.1
releases while retaining the existing 144-mod client pack, 25 operational
server-only mods, and NeoForge 21.1.248.

The final stable additions beyond the original candidate are:

- Create Aeronautics 1.3.2
- Farmer's Delight 1.3.4
- Construction Sticks 1.5.0
- Create: Copycats+ 3.0.8
- JEI 19.50.0.414

Packwiz still offers Advanced Peripherals 0.8.0a, Create Crafts & Additions
1.7.0, Lithostitched 1.8.0+beta4, and JEI 19.51.0.417. Those files are not
part of this release because they are alpha, beta, or explicitly prerelease
builds. JEI 19.50.0.414 is the newest stable JEI release for Minecraft 1.21.1.

## Compatibility corrections

Create Aeronautics 1.3.2 bundles Simulated 1.3.2. That bundle removes the
unconditional `silence_jei.ItemStackListFactoryMixin` from Simulated 1.3.1,
which had made JEI 19.50 incompatible with the previous Aeronautics bundle.

Copycats+ 3.0.8 contains a stale Sable physics resource targeting the removed
`copycats:copycat_catwalk` block. The pack overrides only that resource with an
explicitly empty block tag. This removes the invalid assignment without
patching either JAR or changing any registered gameplay block.

## Configuration policy

Nine server/common configuration schemas were migrated from clean runtime
output. Values shared with the previous schemas retain their prior values.
Release-critical policy remains:

- Mekanism `allowProtection = false`.
- Waystones `enableCosts = false`.
- Waystones non-interdimensional distance multiplier `0.0`.
- Waystones fleeting-memorial travel remains free.
- Quark item sharing remains disabled.

## Validation

- Pack store: 144 hash-verified JARs.
- Native Windows client: 145 JARs including GenericClientCompanion.
- Server: 149 JARs including 25 operational server-only modules.
- NFO isolated server: `Done (22.246s)` with no critical dependency, mixin,
  Copycats registry, or JEI/Simulated error.
- Native Windows server: `Done (18.636s)`.
- Companion status, debug, RCON, and chat receipts passed.
- Standard native soak: 318.241 seconds with zero generic-error growth, zero
  critical errors, zero disconnects, one connection attempt, and a minimum
  7.44 GiB free Windows memory.
- Extended pre-production observation exceeded 30 minutes with the same exact
  process identities and no error or disconnect growth.

After that clean acceptance window, the isolated Home PC server later tripped
its watchdog on a 92.10-second tick while the Windows/WSL host was under memory
and scheduling pressure. That event did not occur on the independently hosted,
memory-protected NFO production server. It is retained in the release receipts
instead of being treated as a successful long-duration Home PC result.

## Artifacts

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.6.0-curseforge.zip` | `720fb6f729e0f163f64b752c7eff3328a297c7d32eea73e5ff54f709db48c5fb` |
| `2b2m-1.6.0.mrpack` | `26c0d05b0564179a48d15e86feac60d4452d36ae1ed321304e913962709fb620` |
| `2b2m-1.6.0-staging-prism-instance.zip` | `11d1f09065bf8d904593a2b62a1cc76ef686253cf44036c3fd55d123f1703def` |
| `2b2m-1.6.0-server.zip` | `270a6e2a613ccb5baea60ceca65dcce1f856eebd57850c47d004cb25fd4ac861` |

The canonical Packwiz index SHA-256 is
`28d413395a0c1ba385849d06d140e3ab021a6c0d4d13d9a384671fcf311bfc23`.

The converted public Packwiz `pack.toml` and `index.toml` SHA-256 values are
`635a726a6a37a8c7f79bcefbf7db6d73e7f248539f6ce9b0696222b45d6c0540`
and `669d3d3a30dafdd2a087d4b8158fdf21e943e6a7081a6f50f47022a62587ff7b`.

## Production cutover

The deployed release payload is commit
`665a6bb00a056e3191f470210031c794eb88d39b`. Before replacement, production was
stopped and copied to
`/hdd/2b2m-backups/cutover-1.6.0-20260830T193001Z`. The backup is
25,539,392,059 bytes and includes 26,877 world files and the previous 149-mod
server set. Independent world and mod-manifest comparisons passed.

The production NFO server reached `Done (19.334s)` at 15:35:33 EDT with 149
mods. GenericMonitor reported `serverReady=true`, the watchdog timer was
restored, and the live configuration retained the Mekanism, Waystones, Quark,
and Copycats policies listed above.

The public website, update feed, Packwiz metadata, and downloads were replaced
with the matching 1.6.0 artifacts. The public Prism, CurseForge, and Modrinth
downloads hash to the exact values in the artifact table. CurseForge accepted
the release upload as file `8772502`.

GenericClientCompanion then joined the production server as `CompanionReview`
at 15:54:25 EDT. Its status and debug APIs stayed connected in
`minecraft:overworld`, its chat receipt appeared in the server log, and the
server console listed it as the only connected player. The final observation
at 15:56:51 EDT was more than two minutes after the join, with the same
production process, healthy watchdog and GenericMonitor, and no post-join
disconnect or critical event.

## Rollback boundary

The stopped server backup and the previous public website trees are retained in
the NFO release-staging directory. Server deployment preserved the world,
player/frequency data, `server.properties`, runtime credentials, watchdog
tooling, and operational service configuration. Rollback restores the stopped
server root and the previous public web trees before restarting the original
service state.
