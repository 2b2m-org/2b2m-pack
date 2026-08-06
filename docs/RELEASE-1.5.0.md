# 2b2m 1.5.0 Release Record

This release is prepared and validated on the staging branch before any production server change.

## Compatibility Decisions

- Evolved Mekanism uses the published `1.21.1-1.2.1-fix3` file. No patched mod jar is shipped in the client pack.
- MineColonies, BlockUI, Domum Ornamentum, Multi-Piston, Structurize, and TownTalk remain in the pack because the production world contains MineColonies data.
- Sodium remains on stable `0.8.12`. Packwiz offered `0.8.13-beta.1`, which is intentionally deferred until a stable release or a separate compatibility test.
- Advanced Peripherals player detection is exact through 256 blocks, degrades beyond that range, and stops at 1024 blocks. Cross-dimensional detection and additional player information are disabled.

## Update Audit

On August 6, 2026, `packwiz update --all` found four remaining updates. The stable FTB Quests, Sophisticated Backpacks, and Sophisticated Core updates were applied. The Sodium beta was the only deferred update.

## Artifact Audit

| Artifact | SHA-256 |
| --- | --- |
| `2b2m-1.5.0-curseforge.zip` | `1bb09b7d27b366207a5203367d5df7737d2672543b744738f39d7dd857312145` |
| `2b2m-1.5.0.mrpack` | `e5133fd193b1fbc20bab4641d0b5153e6c59e8dd96870e9ef5a2a7ee9d8dff45` |
| `2b2m-1.5.0-staging-prism-instance.zip` | `b397527c3d9a1c0e047a44668704c53cfbab2e7962def14a1adfa27e24a23e17` |
| `2b2m-1.5.0-server.zip` | `0a5cf911650814b625f2ee4c4d228ee4432f911de2a5c8c1a40e0d34957d6728` |

The source contains 150 client-pack mod entries: 130 server-capable and 20 client-only. The Modrinth export contains 117 manifest downloads and 33 exact CurseForge jar exceptions. The internal server archive contains the 130 server-capable pack mods plus 24 listed operational server-only extras.

All four archives pass ZIP integrity checks. The three client artifacts contain no `Generic*` or Dupe Guard jar.

## Staging Evidence

- The exact Mac candidate has all 130 server-capable Packwiz jars with matching hashes and reaches `Done (5.317s)` on NeoForge `21.1.248`.
- MineColonies discovery completes with the restored compatibility set.
- The staging Packwiz tree and client downloads are published only under `staging.2b2m.org`; production remains unchanged.
- The clean Home PC Prism instance is installed and can reach the private Mac TCP endpoint. The authenticated join remains open until the saved Microsoft account is interactively reauthenticated.

The candidate retains the existing nonfatal dedicated-server class-filtering, Tracks tag, and advancement diagnostics also seen in production. CBC Advanced Technologies additionally rejects three cutting recipes during reload; its current `0.1.4c` jar still completes startup and declares the installed Create and Create Big Cannons versions compatible.

## Release Gates

- Refresh and validate the canonical Packwiz index.
- Build and inspect the CurseForge, Modrinth, Prism, and internal server artifacts.
- Boot the exact server candidate on the Mac staging host.
- Join it from the Home PC companion client and verify normal gameplay connectivity.
- Keep the NFO production server and its world unchanged until the separately approved cutover window.
