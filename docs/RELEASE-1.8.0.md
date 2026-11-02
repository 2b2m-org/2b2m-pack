# 2b2m 1.8.0

Adds Oritech 1.2.13, Applied Energistics 2 19.2.18, and Powah! Rearchitected
6.2.10 for Minecraft 1.21.1 / NeoForge 21.1.265. Athena 4.0.6 and GuideME
21.1.22 are added as required dependencies; existing Architectury, GeckoLib
and Cloth Config satisfy the remaining dependencies. All 144 existing client
mod entries and 149 existing server JARs are unchanged. Clients must update
the complete pack.

Powah! Rearchitected is Technici4n's maintained continuation. Its 1.21.1
6.2.10 release was published April 29, 2026 with a block-state fix:
https://github.com/Technici4n/Powah/releases/tag/v6.2.10

The deployed client pack contains 149 JARs and production contains 154.
The complete pack passed fresh-world startup and a physical copy of the
stopped production world, with three consecutive 20 TPS samples after startup.
Powah generated power that reached an AE2 energy cell. A native Windows client
joined the copied world and opened Powah's Furnator, AE2's Inscriber and
Oritech's assembled machine screen. The matching profile also joined public
production successfully, with JEI and voice chat initialized.

Production was deployed after a verified stopped-world backup and the separate
host maintenance recovery check. Its updated Java 21 runtime and existing
settings were preserved. Health and stable TPS checks pass; normal recovery
timers are active. All 642 indexed public files, including 149 mod metadata
files, and all three downloadable archive hashes validate. The website's 81
tests/build and existing exporter regression pass. Packwiz, Prism, CurseForge
ZIP and Modrinth downloads are live. CurseForge file 9407479 is uploaded;
moderation availability is separate from the working direct downloads.

One public-client launch failed during Veil 4.3.2 construction with
ConcurrentModificationException in RenderTypeShardRegistry.addGenericShard;
the subsequent missing FTB Quests theme was a downstream error. Relaunching
the same files succeeded. Veil is bundled by the unchanged Sable JAR. The
intermittent startup race is retained as a follow-up; its introduction and
frequency are not established, and no Veil/Sable patch is part of this release.

Adding AE2 makes the already documented Advanced Peripherals 0.8.2a ME Bridge
and blank ME disk performance concerns applicable. AP remains unchanged; no
bridge/disk restriction or security patch is part of this release. Acceptance
is bounded and does not certify large storage networks or exhaustive gameplay.
