# Brotato Mods

Three mods for Brotato's built-in ModLoader. The manifests target Brotato
1.2.0.1 and ModLoader 6.2 or 6.3.

## NightGrind

Turn Brotato into a grind: replay a wave to build your character before taking
on the next one.

- Nightmare is the only difficulty available.
- Dropped materials are reduced to one third of the usual amount on average.
- After a wave, choose **Replay** to play it again or **Next** to advance.
  Advancing asks for confirmation.
- Harvesting has no effect, including negative Harvesting.
- Automatic material attraction and Lootworm are disabled.
- Materials left at the end of a wave disappear.

Items with disabled effects can still appear in crates with their original descriptions.

## RelatedEffects

See how an item changes stats linked to another stat in the shop. For example,
with Retromation's Hoodie, a Dodge change also shows the resulting Attack
Speed change. Previews cover standard item effects; custom effects and
fractional results are skipped.

## FreeRerolls

Reroll shop offers and level-up upgrades for free.

## Installation

These mods are provided as source. To build a ZIP, install Python 3, download
this repository, and run the command for the mod you want from the repository
directory:

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
