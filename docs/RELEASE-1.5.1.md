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
error or fatal journal entry appeared during the immediate post-change
validation window.

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

The published pack and base server-archive mod payload did not change, so no
replacement full server archive was required for 1.5.1. The live server
initially received only the corrected configuration. A later, unrelated
production incident required the server-only GAC update recorded below; that
operational mod is not distributed to clients. The public Packwiz `pack.toml`
SHA-256 is
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

## Classic Peripherals Resource-Exhaustion Incident

At `2026-08-06T21:39:09-04:00`, an in-world ComputerCraft program called
Classic Peripherals 0.5.1 `randomBytes` with a resource-exhausting length. The
mod allowed values through `2,147,483,632`, allocated the requested byte array
on a ComputerCraft worker, and exhausted the 10-GiB Java heap. That worker held
Java's secure-random lock, so the main thread later blocked in
`UUID.randomUUID`; GenericDupeGuard appeared in the blocked main-thread stack
but did not initiate the allocation. The watchdog recorded a 60-second tick and
Minecraft stopped at 21:40:21. The preserved crash report is
`crash-2026-08-06_21.40.10-server.txt`, SHA-256
`6da6457b3e69080f1f52b3c587ddf324e1885748bbdac90c7a3c8d9bdd7ebdae`.

This was a latent server exploit rather than a 1.5.0/1.5.1 mod regression. The
live and stopped-state backup both contain the same Classic Peripherals 0.5.1
jar, SHA-256
`e3ca5355f51f2d101ec09efce4660f3642f14f4049815443a1573ea60a903239`.
The watchdog recovered production at 21:43:21, and it reached
`Done (14.447s)` at 21:44:33.

No released Classic Peripherals version provided a suitable length limit or
configuration switch. The third-party jar was not patched. Instead, the
existing NFO-only exploit-patch carrier was released as GenericAntiCheat
0.1.33, commit `ab69b0fee6d240f485143b3155ccda658903dad6`. It rejects negative
or over-4-KiB `randomBytes` requests before allocation while leaving normal
cryptographic operations enabled. The exact deployed jar SHA-256 is
`32a48dc7d1ce6ef9ac36c2bc28f353db3c2719314389b7474314173a85e45ec9`.

The exact jar completed a full isolated 150-mod boot at `Done (13.213s)` with no
fatal or injection failure. Mixin export proved that the guard executes before
the original allocation, and an executable harness accepted lengths 0 and
4,096 while rejecting 4,097 and `Integer.MAX_VALUE` with the bounded Lua error.
Production was cleanly saved and stopped after warning five connected players,
started on 0.1.33 at 22:12:41, and reached `Done (15.005s)` at 22:13:50.
Both health APIs returned HTTP 200 with `serverReady=true`; manual and scheduled
watchdog probes passed; three players reconnected during validation; and the
post-start log had no OOM, watchdog, fatal, or mixin-injection failure.

The deployment retained 150 active server jars. Its checksum manifest SHA-256
is `b0e89a9eb53f880bc3ca9150244e74ebf849ac3ae91e4ca39516a3cccf414995`.
Mekanism remained at `allowProtection = false`, and all 36 Teleporter, QIO,
Inventory, and Security frequency files were byte-for-byte unchanged across the
restart. The client pack, Packwiz feed, Prism bootstrap, CurseForge file, and
version number remain 1.5.1 because GenericAntiCheat is server-only.

## Waystones Configuration Correction

The release audit also found that the server cutover had restored Waystones'
packaged XP-cost defaults over production's free-travel configuration. This was
a configuration regression, not a mod or world-data change. Production keeps
the current Waystones schema while restoring `enableCosts = false` and changing
only the non-interdimensional distance multiplier from `0.01` to `0.0`.

The same two settings are corrected in the pack source so future server exports
preserve the intended behavior. The CurseForge client export excludes this
common/server configuration, so the published 1.5.1 client archive does not
need replacement. No Waystone data, destinations, or cooldown settings were
changed. The incorrect live file SHA-256 was
`53a2f31a27e4525fa5f80c197e3be05af761c74d04f53a31c97527f018265ca5`;
the corrected current-schema file SHA-256 is
`da2fe4f714dc63ee0fbe2e8587f1fa09ccaaa1d558c02c48481dedf9633b50fc`.
It was installed atomically at `2026-08-06T22:41:59-04:00` without restarting
Minecraft.

## Explicit Next-Restart Server Mod Staging

A separate user-requested audit staged GenericMisc 0.1.36 and GenericSpectate
0.1.6 after the current production JVM had already started. The running JVM
therefore remains on GenericMisc 0.1.35 and GenericSpectate 0.1.5; the newer
jars are an intentional next-restart payload, not unexplained disk drift.

GenericSpectate passed 9 unit/integration tests. GenericMisc passed 41
unit/integration tests and 10 runtime GameTests. The exact 150-jar next-restart
directory then completed an isolated full server boot at `Done (9.191s)` with
no fatal mod-load, mixin-injection, OOM, or watchdog failure. The only new smoke
error was the expected loopback port collision with production's running
GenericPacketLedger viewer.

| State | Manifest SHA-256 |
| --- | --- |
| Currently loaded runtime, 150 jars | `6548bde75445ec307f68b90b64536cfc04d3e936bc3c3027fc4d0b33d32ba962` |
| Staged next restart, 150 jars | `fde046abe0a0bb2fff744187b0b9e911d9ba43a3a64941d39312af3026a2c08a` |

The two source worktrees remain uncommitted by design for that separate task.
Their exact working-tree snapshots, diffs, test XML, old and new jars, smoke
log, and both manifests are preserved under
`/hdd/2b2m/.release-staging/1.5.0-fa88c18-cutover/next-restart-genericmisc-0.1.36-genericspectate-0.1.6`.

## Rollback and Scope

The stopped-state 1.5.0 backup remains at
`/hdd/2b2m-backups/cutover-1.5.0-20260807T001105Z`. The pre-hotfix configuration,
the corrected configuration, the pre-1.5.1 public feeds, and the pre-1.5.1
website remain preserved under the release-staging directory. This hotfix did
not route traffic through the Mac or activate a staging relay. The Mekanism
configuration correction itself did not restart Minecraft, replace a mod jar,
or modify world/frequency data. The later Classic Peripherals mitigation used a
controlled restart and replaced only the NFO-only GenericAntiCheat jar. Its old
and new jars, source bundle, stopped-world hash, pre-change log, both mod
manifests, and frequency-file manifest are preserved under
`/hdd/2b2m/.release-staging/1.5.0-fa88c18-cutover/gac-0.1.33-ab69b0f`.
