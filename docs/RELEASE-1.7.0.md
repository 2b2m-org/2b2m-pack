# 2b2m 1.7.0 stable mod refresh

Deployed and verified on NFO on October 30, 2026. The public Packwiz feed,
Prism instance, CurseForge-format ZIP, Modrinth pack and website serve 1.7.0.
CurseForge file **9373761** is approved. This release is superseded by
[1.7.1](RELEASE-1.7.1.md), which fixes the native player join failure discovered
in follow-up client testing.

## Release contents

The release updates 41 mods for Minecraft 1.21.1 and moves NeoForge from
21.1.248 to 21.1.265. The roster remains 144 client JARs and 149 server JARs,
including 25 operational server-only JARs preserved byte-for-byte.
See the [changelog](../update-feed/versions/1.7.0/changelog.txt) for every update.

Artifacts stays at 13.2.3 because the installed Reliquified Artifacts requires
that exact version. Xaero Minimap 26.4.2 and World Map 1.45.0 stay compatible
with Open Parties and Claims 0.30.3; newer map releases require newer OpenPAC
and XaeroLib. New prerelease builds are excluded from this stable refresh.

Create: Ultimate Factory and Lithostitched returned repeated Modrinth CDN
HTTP 503 errors. The exporter retains their exact working CurseForge files
and embeds them in the Modrinth archive. The exception is scoped to the two
file hashes. Distribution permission and credits are in
[THIRD-PARTY-NOTICES.txt](../THIRD-PARTY-NOTICES.txt).

Quark's configuration schema adds four fields while preserving every shared
production value. Evolved Mekanism's runtime schema adds 30 fields with no
shared-value changes. Mekanism access protection remains disabled, Waystones
travel remains free, Quark item sharing remains disabled, and GenericMonitor
0.1.24 keeps the fluid batch bound at 256 per dimension per tick.

## Verification

- All 144 downloaded client JARs match canonical hashes, including renamed
  Modrinth filenames. A clean-origin Packwiz bootstrap completed after the two
  download-source corrections.
- The exporter regression failed before its fix and passes after it. It checks
  that the two unavailable mirrors retain CurseForge sources while a healthy
  exact match still converts.
- All 81 website tests pass; the production build passes. Public homepage,
  pack page and version-bearing asset bytes match that build.
- The complete 149-JAR server boots against a new world and a physical copy of
  the stopped production world. The production-world test held 20 TPS.
- Production reached `Done (21.285s)`, reported ready, and remained at 20 TPS
  (14.16 MSPT in the final sample) with the same process. Both restart
  timers and the active watchdog are healthy. Public Minecraft status from M2
  reports the 1.7.0 MOTD.
- Public Packwiz index hashes, all three public download ZIPs and the raw GitHub
  update feed validate. Native player login and gameplay were not exercised.

A temporary overlay filesystem caused SQLite opening to exceed the test
watchdog. Replacing it with a physical world copy passed with the same mods;
production uses its normal filesystem. The staging copy also briefly inherited
production Discord incident settings. All staging Discord notifications are
now disabled and the staging servers are stopped.

One Sable sub-level dependency error appeared once in both the original 1.6.0
restart and the updated copied-world boot; it is a pre-existing limitation,
not a new failure of this release. The separate event-worker failure remains
outside this update.

## Recovery and evidence

The stopped-server recovery copy is `/hdd/2b2m-backups/cutover-1.7.0-20261030T140847Z`. Its world contains
28,526 files and 27,491,798,160 bytes. Final rsync comparison passed before
replacement. World/player/frequency data, operational configurations and service
ownership are preserved; only the MOTD value changes in server properties.

Private receipts, source archives, old web trees, exact candidate JARs and the
prepared deployment/rollback command live at `/hdd/2b2m/.release-staging/1.7.0-20261030`. For rollback, stop the
watchdog and daily restart timers and `minecraft.service`, restore the backup's
world, mods, configuration, runner, run scripts, server properties and release
marker, then start the original service and timers. Restoring an old world
snapshot discards gameplay since cutover; assess that boundary before recovery.

The two mirror exceptions use the original author-hosted files. Create:
Ultimate Factory explicitly permits inclusion in public or private modpacks on
its [project page](https://www.curseforge.com/minecraft/mc-mods/create-ultimate-factory).
Lithostitched uses the [MIT license](https://github.com/Apollounknowndev/lithostitched).
Create: Connected's [license](https://github.com/hlysine/create_connected/blob/main/LICENSE)
permits modpack redistribution with its source link, supplied in the notices.
