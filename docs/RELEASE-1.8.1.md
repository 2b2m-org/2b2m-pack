# 2b2m 1.8.1

Adds AE2WTLIB 19.5.1, ExtendedAE 1.21-2.2.43-neoforge, AdvancedAE 1.6.12-1.21.1 and required Glodium 1.21-2.2-neoforge. Minecraft 1.21.1, NeoForge 21.1.265 and all 149 existing client mod entries remain unchanged. The server adds the same four JARs to its 154-JAR baseline. Clients must update the complete pack.

The existing AE2 19.2.18, GuideME and GeckoLib versions satisfy the new requirements. AE2WTLib API and AE2 Addon Library are bundled by upstream JARs. The production Draconic Evolution smaller reactor explosion safeguard is retained.

All 153 client mod hashes match the exported manifest, and all 149 prior client
metadata files and 154 prior server JARs are unchanged. The CurseForge, Modrinth
and Prism archives validate. The existing Modrinth exporter regression and the
website's 81 tests/typechecked build pass.

The 158-JAR runtime booted a physical copy of the verified stopped-production
snapshot. A matching native Windows client joined and opened ExtendedAE's
extended pattern provider, AdvancedAE's reaction chamber, and AE2WTLib's wireless
pattern encoding terminal. The wireless check used a charged test terminal with
its link component set to a powered, naturally placed wireless access point;
it does not certify the manual pairing-slot UI. All test machines/items remained
in the disposable copied world. Three consecutive 20-TPS samples passed with the
client connected. Earlier private startup and periodic brief dips are retained
in the raw receipt; the test shared NFO with production under lower scheduling
priority and a 12-GiB heap. No cause is inferred from those dips.

ExtendedAE emits a startup loot-table parse message for its AppliedE-only
transmutation interface when AppliedE is absent. That optional integration is
not present in this pack. Other existing startup warnings remain; no upstream
mod JAR was patched. Acceptance is bounded and does not certify large ME networks
or exhaustive automation/recipe behavior.

Production is deployed after a verified stopped-world backup. The original Java
runner and existing mod/configuration policy are preserved, including
`disableLargeReactorBoom=true`. Health and three consecutive 20-TPS samples pass;
normal watchdog and daily-restart timers are active. The matching Windows client
also joined public production with JEI and authenticated voice chat, and three
20-TPS samples passed while connected. No test items or machines were added to
production.

Packwiz, Prism, CurseForge ZIP, Modrinth archive and the website now serve 1.8.1.
All 646 indexed public files, including 153 mod metadata files, and all three
archive hashes validate. CurseForge file 9410941 is uploaded and pending
moderation; direct website downloads are live at https://2b2m.org/pack/.

Private receipts, deployment scripts and the recovery-copy pointer are retained
on NFO under `/hdd/2b2m/.release-staging/1.8.1-ae-20261102`. The stopped recovery
copy is `/hdd/2b2m-backups/cutover-1.8.1-20261102T203000Z`. It shares unchanged
files with the prior immutable backup through rsync link-dest; use a copy or
ordinary rsync for recovery, and never launch a server directly in either backup.
Off-host recovery remains unverified. The native Windows profile is retained for
future acceptance; test processes, proofs, private relay/world and task worktree
are removed after source publication and evidence archival.
