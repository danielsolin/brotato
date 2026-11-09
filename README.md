# Brotato Mods

Three mods for Brotato's built-in ModLoader. The manifests target Brotato
1.2.0.1 and ModLoader 6.2 or 6.3.

## NightGrind

Turn Brotato into a grind: replay a wave to build your character before taking
on the next one.

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3836266944)

- Nightmare is the only difficulty available.
- Dropped materials are reduced to one third of the usual amount on average.
- Replay a wave for materials equal to twice its number, or advance as usual.
- Harvesting has no effect, including negative Harvesting.
- Pickup range is fixed at 0%.
- Instant material attraction is disabled.
- Materials left at the end of a wave disappear.

Items that directly affect Harvesting, pickup range, or instant material attraction
are excluded from shops and crates.

## RelatedEffects

See how an item changes stats linked to another stat in the shop. For example,
with Retromation's Hoodie, a Dodge change also shows the resulting Attack
Speed change. Previews cover standard item effects; custom effects and
fractional results are skipped.

## FreeRerolls

Reroll shop offers and level-up upgrades for free.

## Installation

To install NightGrind, subscribe on Steam Workshop. To build a local ZIP for
any of the mods, install Python 3, download this repository, and run the
command for the mod you want from the repository directory:

```sh
python3 scripts/package_mod.py DanielSolin-NightGrind
python3 scripts/package_mod.py DanielSolin-RelatedEffects
python3 scripts/package_mod.py DanielSolin-FreeRerolls
```

Copy the desired ZIP from `dist/` into Brotato's `mods/` folder and enable it
in your ModLoader profile. Restart the game after installing or changing mods.

Your ModLoader configuration must scan local ZIP files. Steam's default
ModLoader profile scans subscribed Workshop mods instead. On Windows, the game
folder is typically `steamapps/common/Brotato/`; ModLoader's log is at
`%APPDATA%/Brotato/logs/modloader.log`.
