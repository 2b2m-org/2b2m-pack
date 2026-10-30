# 2b2m 1.7.2

Advanced Peripherals is updated from 1.21.1-0.7.62b to the official
**1.21.1-0.8.2a alpha**. Minecraft 1.21.1 and NeoForge 21.1.265 are unchanged.
This adds the 0.8 peripheral and Smart Glasses rework. Existing Lua programs
may need migration to the changed peripheral names, methods and table shapes.
The upstream alpha remains experimental; this release does not harden AP.

The client pack retains 144 JARs, with AP as the only mod update. Production
retains 149 JARs. GenericMisc 0.1.36-ap0.8 adapts its player-event integration to
AP's new event parameter; only that class and its version metadata change
from the installed GenericMisc baseline. The other 147 server JARs retain
their exact bytes, including GenericMonitor 0.1.24 and its fluid-tick bound.

The existing AP detector limits, position-noise policy, chat wrapping and
chunk radius remain. The detector's renamed multidimensional key and chat
command-list syntax are translated for 0.8. Mekanism protection, free Waystones
travel and disabled Quark item sharing retain their production settings.

Fresh-world and physical stopped-world-copy boots passed. The world copy
qualified with a 12 GiB heap and three consecutive 20 TPS samples after startup.
The fresh Windows profile was built from the CurseForge overrides and all 144
client JAR hashes were verified. It joined production, initialized JEI,
authenticated voice chat and opened the Smart Glasses interface. Production
held 20 TPS with the test client online. Test items were removed and its original
inventory restored.

The three focused GenericMisc integration tests, pack exporter regression,
website's 81 tests and website build passed. The Packwiz feed, Prism ZIP,
CurseForge-format ZIP, Modrinth archive and website 1.7.2 metadata were verified
over HTTPS. These are bounded acceptance checks, not exhaustive AP gameplay
or security certification.

CurseForge file **9375813** is submitted and awaiting moderation. Matching
downloads are live at 2b2m.org. Production has a clean stopped-server recovery
copy and the normal watchdog/restart timers are active.
