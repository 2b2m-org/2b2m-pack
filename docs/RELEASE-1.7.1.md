# 2b2m 1.7.1 join compatibility fix

Updates owo-lib from 0.12.15.5-beta.1 to 0.12.15.6-beta.1. This is the author's
fix for Accessories packet synchronization with NeoForge 21.1.265. All 41 stable
mod updates from 1.7.0 remain, with 144 client JARs and 149 server JARs.

The native Windows client reproduced an immediate post-login disconnect on
1.7.0. The server could not encode `accessories:main` because owo's sided packet
codec was not unpacked. The retained older beta targets an internal NeoForge
return ordinal that changed in recent loader builds. The author fixed this in
[owo-lib issue 507](https://github.com/wisp-forest/owo-lib/issues/507).

With the updated library on client and server, the same native Windows profile
joined `2b2m.org:25565` as `CompanionReview`, loaded the production overworld,
completed JEI item/recipe initialization and authenticated Simple Voice Chat.
This verifies the failing native join path; it is not exhaustive gameplay
coverage of all mods. No normal launcher instance was modified.

The public downloads and update metadata use 1.7.1 so existing installs receive
the correction. The 1.7.0 stopped-world recovery copy remains available; this
patch changes one library and no existing world blocks, player inventory or
operational JARs. The exact previous library and private native-client evidence
are retained under `/hdd/2b2m/.release-staging/1.7.0-20261030/client-acceptance`.
