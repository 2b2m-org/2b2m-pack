# 2b2m 1.5.0 Release Record

Status: deployed and validated on the NFO production server on August 6, 2026.

## Release References

- Pack content commit: `fa88c184495c01efb8ff6df248b44f58170ae54d`
- Git branches: `main` and `staging`
- Minecraft: `1.21.1`
- NeoForge: `21.1.248`
- CurseForge project: `1530503` (`org-2b2m`)
- CurseForge upload: file ID `8591594`
- Production Packwiz feed: `https://2b2m.org/packwiz/pack.toml`

CurseForge accepted the upload and returned file ID `8591594`. The public project
page still showed 1.4.1 during the cutover, so 1.5.0 publication remains subject to
CurseForge processing or moderation. The production Packwiz feed is already live.

## Compatibility Decisions

- Evolved Mekanism uses the published `1.21.1-1.2.1-fix3` file. No patched
  third-party mod jar is shipped in the client pack.
- MineColonies, BlockUI, Domum Ornamentum, Multi-Piston, Structurize, and TownTalk
  were removed by owner decision.
- Sodium remains on stable `0.8.12`. The offered `0.8.13-beta.1` update is
  intentionally deferred.
- Advanced Peripherals player detection is exact through 256 blocks, degrades
  beyond that range, and stops at 1024 blocks. Cross-dimensional detection and
  additional player information are disabled.
- Modpack Update Checker schema 9 uses its supported `stable` release type.

## Artifact Audit

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.5.0-curseforge.zip` | `11bc62a2cdc1b1bb801338201b6a290a5d5cebfc3bd011f6febd0face46fbd43` |
| `2b2m-1.5.0.mrpack` | `09e095a361afacbbf4763a534069bc223c0bda9e69238292eaf1101034b86cd9` |
| `2b2m-1.5.0-staging-prism-instance.zip` | `f671d8151f9f2a37d65476dfd56a2e5cf73990f872e946108fb1d68ce38b7417` |
| `2b2m-1.5.0-server.zip` | `c40e1bf412a487912ffa3a20fec66e7cb2e961d17ba01b52afebee7a8bd9e12c` |

All four archives pass ZIP integrity checks. The source contains 144 client-pack
mod entries: 124 server-capable and 20 client-only. No client artifact contains a
`Generic*` or GenericDupeGuard jar.

Production loads the 124 Packwiz server-capable jars plus 26 existing NFO-only
operational jars, for 150 server jars total. The client pack does not acquire
those server-only jars.

## Pre-Production Validation

- The post-removal Mac candidate reached `Done (4.949s)` on NeoForge `21.1.248`
  with the existing eight-dimension staging world.
- A clean public-feed bootstrap downloaded all 634 indexed files and exactly 144
  client jars, with none of the removed stack or server-only jars.
- Workstation20 updated its Prism instance from the staging Packwiz feed and
  joined the Mac as `topher4022`. Sable UDP and Simple Voice Chat UDP both
  authenticated. Physical voice audio was not exercised because the saved Razer
  Kaira endpoints were absent.

## Production Cutover

- Maintenance warnings were sent before the final stop. The old server completed
  `save-all flush` and stopped cleanly at `2026-08-06 20:20:19 EDT`.
- The stopped-state backup is
  `/hdd/2b2m-backups/cutover-1.5.0-20260807T001105Z`. A final
  `rsync -ani --delete` comparison was empty.
- The live and backup `world/level.dat` SHA-256 at cutover was
  `5510c8f823c6feaa1dea7e4bc85dadae058d66cdc4bb0c713b842e2aa00abe21`.
- NeoForge `21.1.248`, the 1.5.0 pack, production-only mods/configuration, the
  GraalVM runner, and the 10 GiB heap setting were installed without copying or
  migrating a Mac world.
- The production Packwiz feed was promoted from 1.4.1 to 1.5.0 before the game
  service restart.

### Public Website Metadata

The NFO website metadata and prerendered routes were regenerated from the clean
1.5.0 Packwiz manifest after the game cutover. The public `/`, `/pack`,
`/about`, and `/llms.txt` routes now report pack 1.5.0, 144 client mods, and
NeoForge 21.1.248. Draconic Evolution replaces MineColonies in the site
headliners, and the active pack, about, home, and language-model routes contain
no MineColonies reference.

The static deployment did not restart the website or Minecraft service. Exact
pre-change source and `wwwroot` rollback files are stored under
`/hdd/2b2m/.release-staging/1.5.0-fa88c18-cutover/website-before-1.5.0`; the
checksum-verified deployed source and 5,100-file static tree are under the
adjacent `website-1.5.0-deployed` directory. Public route, active-asset, and
`/api/status` HTTP probes all returned 200 after deployment.

### Server-Only Compatibility Fix

The first production boot stopped before opening ports because
`genericanticheat-server-0.1.31.jar` wrapped a `Slot.set` call removed by
Sophisticated Core `1.4.81`. The production world had not loaded.

GenericAntiCheat `0.1.32` now wraps Sophisticated Core's validated
`StorageContainerMenuBase.setGhostSlot` path while retaining unsafe-item and slot
bounds checks. Its full 150-mod isolated smoke reached `Done (20.817s)` with zero
mixin or startup failures. The fix source is on GenericAntiCheat `main` at
`40e1794b01bc4b2518e49e2103a9c9c828f3ced0`; the deployed server-only jar SHA-256
is `982678f0f8c6bb391da7eb3012bf38163b1c17a005bb5453d4a5779604c6eaed`.

The production restart then reached a fresh `Done (14.689s)` at
`2026-08-06 20:34:44 EDT`. TCP 25565, Sable UDP 25565, and voice UDP 24454 are
owned by the new JVM. The Minecraft watchdog, GenericDupeGuard health endpoint,
GenericMonitor health endpoint, and `minecraft-events-worker.service` all pass.

## Production Client Evidence

- Five external player profiles joined successfully during the acceptance
  window; four remained online after the controlled Workstation20 exit.
- Workstation20 launched the exact 144-jar client through Prism with the
  `topher4022` Minecraft profile and connected through the public production
  hostname.
- `topher4022` entered the world, completed Sable UDP authentication, received
  the voice secret, and completed the public voice UDP connection before the
  controlled client shutdown.
- Workstation20 again logged only the known missing-Razer audio-device failure;
  gameplay, Sable, and voice network transport all passed.
- A live sample with four players reported TPS `20.0 / 19.94 / 16.89` over the
  last 5 seconds, 10 seconds, and 1 minute. The lower one-minute average includes
  the simultaneous first-login cleanup burst after the intentional mod removal.

### Settled Performance Audit

The longer production observation caught intermittent overload spikes while the
same live world was active. This is not new to 1.5.0: the old production JVM
logged 12 `Can't keep up` events in the hour before cutover and the same guarded
Sable load pattern, including a 1.275-second tick. After the new JVM's 20-minute
Sable startup guard elapsed, a final three-sample series with three players held
20.0 TPS over 5 seconds each; the final 15-second and 60-second rates were 20.0
and 19.35 TPS. The final 60-second average tick time was 33.06 ms with a 256.12
ms maximum. The watchdog and both health APIs continued to pass, and there were
no error-priority journal entries after readiness.

### Live Draconic Evolution Load Observation

With four players online, a player later traveled to and activated the newly
added Draconic Evolution Chaos Guardian encounter in the End. The approach and
first arena/encounter generation window produced intermittent `Can't keep up`
warnings, including 13.137-, 12.467-, and 10.587-second stalls. The journal
then recorded the guardian progressing through `PREPARING_TO_SUMMON_PILLARS`,
`SUMMONING_PILLARS`, and `SUMMONING_GUARDIAN` from 21:02:27 through 21:02:43
EDT. This is live encounter-generation load, not a boot, compatibility, or
service failure; the pre-1.5.0 JVM had also shown intermittent lag, so the full
lag history cannot be attributed solely to Draconic Evolution.

The server remained online throughout. A post-encounter Spark sample at
21:14:21 EDT reported 19.63/19.82/19.97 TPS over 5 seconds, 10 seconds, and one
minute, with 30.3 ms median and 261.2 ms maximum tick time over the last minute.
The watchdog and health gates remained healthy, and no error-priority, fatal,
injection-failure, or failed-start journal entry appeared after readiness. No
Draconic Evolution, world, or Sable configuration was changed in response.

## Expected Removal Cleanup

Old player recipe books remove stale MineColonies, Domum Ornamentum,
Multi-Piston, and Structurize recipe IDs on first login. Chunks in the former
colony area also report recoverable substitutions for removed blocks and discard
the removed `minecolonies:ship` structure reference. These messages are the
expected data-loss consequence of the approved mod removal; they did not block
startup or client joins.

The NFO staging relay services remain inactive. The website and production game
server remain on the NFO host; no Mac routing or production world copy is part of
this release.
