# 2b2m 1.6.0 Stable Mod Refresh

Status: production deployment authorized on August 30, 2026.

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

## Artifacts

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.6.0-curseforge.zip` | `720fb6f729e0f163f64b752c7eff3328a297c7d32eea73e5ff54f709db48c5fb` |
| `2b2m-1.6.0.mrpack` | `26c0d05b0564179a48d15e86feac60d4452d36ae1ed321304e913962709fb620` |
| `2b2m-1.6.0-staging-prism-instance.zip` | `11d1f09065bf8d904593a2b62a1cc76ef686253cf44036c3fd55d123f1703def` |
| `2b2m-1.6.0-server.zip` | `270a6e2a613ccb5baea60ceca65dcce1f856eebd57850c47d004cb25fd4ac861` |

The canonical Packwiz index SHA-256 is
`28d413395a0c1ba385849d06d140e3ab021a6c0d4d13d9a384671fcf311bfc23`.

The artifacts remain unpublished until the exact release commit is pushed and
the controlled production cutover begins.

## Rollback boundary

The production server, website, Packwiz feed, and downloads must each be
backed up before replacement. Server deployment preserves the world,
player/frequency data, `server.properties`, runtime credentials, watchdog
tooling, and operational service configuration. Rollback restores the stopped
server root and the previous public web trees before restarting the original
service state.
