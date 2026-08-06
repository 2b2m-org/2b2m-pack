# 2b2m 1.5.0 Release Record

This release is prepared and validated on the staging branch before any production server change.

## Compatibility Decisions

- Evolved Mekanism uses the published `1.21.1-1.2.1-fix3` file. No patched mod jar is shipped in the client pack.
- MineColonies, BlockUI, Domum Ornamentum, Multi-Piston, Structurize, and TownTalk remain in the pack because the production world contains MineColonies data.
- Sodium remains on stable `0.8.12`. Packwiz offered `0.8.13-beta.1`, which is intentionally deferred until a stable release or a separate compatibility test.
- Advanced Peripherals player detection is exact through 256 blocks, degrades beyond that range, and stops at 1024 blocks. Cross-dimensional detection and additional player information are disabled.
- Modpack Update Checker schema 9 uses the supported `stable` release type. The Home PC canary caught and corrected the invalid `release` value before publication to production.

## Update Audit

On August 6, 2026, `packwiz update --all` found four remaining updates. The stable FTB Quests, Sophisticated Backpacks, and Sophisticated Core updates were applied. The Sodium beta was the only deferred update.

## Artifact Audit

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.5.0-curseforge.zip` | `887c4432adcce72469082a9968e933e71f1a2f565a9acc01c020873da48074d2` |
| `2b2m-1.5.0.mrpack` | `5595b4725042d5b9e60e0a19f59cb6a5d68d65fe894f74ebd8f05a7061125321` |
| `2b2m-1.5.0-staging-prism-instance.zip` | `82fc76a5df27bb5b539192f09650b4723218015fc50852df2f7b402166b6d7b2` |
| `2b2m-1.5.0-server.zip` | `0a5cf911650814b625f2ee4c4d228ee4432f911de2a5c8c1a40e0d34957d6728` |

The source contains 150 client-pack mod entries: 130 server-capable and 20 client-only. The Modrinth export contains 117 manifest downloads and 33 exact CurseForge jar exceptions. The internal server archive contains the 130 server-capable pack mods plus 24 listed operational server-only extras.

All four archives pass ZIP integrity checks. The three client artifacts contain no `Generic*` or Dupe Guard jar.

## Staging Evidence

- The exact Mac candidate has all 130 server-capable Packwiz jars with matching hashes and reaches `Done (5.102s)` after a clean configuration restart on NeoForge `21.1.248`.
- MineColonies discovery completes with the restored compatibility set.
- The staging Packwiz tree and client downloads are published only under `staging.2b2m.org`; production remains unchanged.
- The clean Home PC Prism instance downloaded the corrected staging feed, authenticated `topher4022`, joined the private Mac endpoint, and completed Sable UDP authentication. After the planned Mac restart it automatically rejoined and connected directly to Simple Voice Chat on `100.87.45.11:24454`.

This is a one-player canary, not a capacity or long-soak result. A short post-restart sample showed a 5.5 ms rolling server tick and 4.7 ms last tick, with about 7.0 GiB process RSS and 3.5 GiB heap used. The first cold join before the restart briefly reached a 45.4 ms rolling tick and a 114.1 ms last tick, then recovered without a disconnect.

The candidate retains the existing nonfatal dedicated-server class-filtering, Tracks tag, and advancement diagnostics also seen in production. CBC Advanced Technologies additionally rejects three cutting recipes during reload; its current `0.1.4c` jar still completes startup and declares the installed Create and Create Big Cannons versions compatible.

## Release Gates

- Refresh and validate the canonical Packwiz index.
- Build and inspect the CurseForge, Modrinth, Prism, and internal server artifacts.
- Boot the exact server candidate on the Mac staging host.
- Join it from the Home PC companion client and verify normal gameplay connectivity.
- Keep the NFO production server and its world unchanged until the separately approved cutover window.
