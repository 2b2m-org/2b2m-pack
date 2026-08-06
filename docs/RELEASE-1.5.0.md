# 2b2m 1.5.0 Release Record

This release is prepared and validated on the staging branch before any production server change.

## Compatibility Decisions

- Evolved Mekanism uses the published `1.21.1-1.2.1-fix3` file. No patched mod jar is shipped in the client pack.
- MineColonies, BlockUI, Domum Ornamentum, Multi-Piston, Structurize, and TownTalk are removed by owner decision. Existing production worlds must be backed up and evaluated for missing mod content before this candidate is deployed.
- Sodium remains on stable `0.8.12`. Packwiz offered `0.8.13-beta.1`, which is intentionally deferred until a stable release or a separate compatibility test.
- Advanced Peripherals player detection is exact through 256 blocks, degrades beyond that range, and stops at 1024 blocks. Cross-dimensional detection and additional player information are disabled.
- Modpack Update Checker schema 9 uses the supported `stable` release type. The Home PC canary caught and corrected the invalid `release` value before publication to production.

## Update Audit

On August 6, 2026, the stable FTB Quests, Sophisticated Backpacks, and Sophisticated Core updates were applied. A later audit found a MineColonies snapshot update, which became irrelevant when the MineColonies stack was removed. The Sodium beta remains the only deferred update.

## Artifact Audit

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.5.0-curseforge.zip` | `11bc62a2cdc1b1bb801338201b6a290a5d5cebfc3bd011f6febd0face46fbd43` |
| `2b2m-1.5.0.mrpack` | `09e095a361afacbbf4763a534069bc223c0bda9e69238292eaf1101034b86cd9` |
| `2b2m-1.5.0-staging-prism-instance.zip` | `f671d8151f9f2a37d65476dfd56a2e5cf73990f872e946108fb1d68ce38b7417` |
| `2b2m-1.5.0-server.zip` | `c40e1bf412a487912ffa3a20fec66e7cb2e961d17ba01b52afebee7a8bd9e12c` |

The source contains 144 client-pack mod entries: 124 server-capable and 20 client-only. The Modrinth export contains 117 manifest downloads and 27 exact CurseForge jar exceptions. The internal server archive contains the 124 server-capable pack mods plus 24 listed operational server-only extras.

All four archives pass ZIP integrity checks. The three client artifacts contain no `Generic*` or Dupe Guard jar.

## Staging Evidence

- The exact post-removal Mac candidate has all 124 server-capable Packwiz jars and reaches `Done (4.949s)` on NeoForge `21.1.248` while loading the existing eight-dimension staging world.
- Before the removal, the world and all 11 removed runtime files were preserved under `backups/minecolonies-removal-20260806T175157-0400`. The world archive SHA-256 is `8b5e61d39a6c8d7f583e26e4dcb989d4afd89cd40d8c08295d5b2765452c6b33`.
- The staging Packwiz tree and client downloads are published only under `staging.2b2m.org`; production remains unchanged.
- The earlier Home PC join validated the pre-removal 1.5.0 candidate only. The Home PC went offline before these artifacts were built, so a post-removal client join remains a release gate.

This removal test is an idle-server boot canary, not a player, capacity, or long-soak result. After seven minutes the server remained up at roughly 0.7-0.9 ms rolling tick time and 6.0 GiB process RSS. The post-removal client join is still required.

Advanced Peripherals logs two nonfatal optional-compat class probes for absent MineColonies classes. The candidate also retains the existing nonfatal dedicated-server class-filtering, Tracks tag, and advancement diagnostics seen before this removal. CBC Advanced Technologies rejects three cutting recipes during reload; its current `0.1.4c` jar still completes startup and declares the installed Create and Create Big Cannons versions compatible.

## Release Gates

- Refresh and validate the canonical Packwiz index.
- Build and inspect the CurseForge, Modrinth, Prism, and internal server artifacts.
- Boot the exact server candidate on the Mac staging host.
- Join it from the Home PC companion client and verify normal gameplay connectivity.
- Keep the NFO production server and its world unchanged until the separately approved cutover window.
