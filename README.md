# Brotato Mods

Mods for Brotato using its built-in Godot ModLoader.

## Current mods

- `DanielSolin-FreeRerolls` makes shop and level-up rerolls free.
- `DanielSolin-RelatedEffects` previews stat changes caused by active
  stat-scaling effects.

The preview matches standard item effects against active stat links. It skips
custom effect classes and fractional derived values.

## Development

- Keep each mod in `mods-unpacked/<Namespace>-<Name>/`.
- Package with `python3 scripts/package_mod.py DanielSolin-RelatedEffects`.
- The ZIP appears in `dist/` with ModLoader's expected `mods-unpacked/` path.
- Steam's default ModLoader profile scans subscribed Workshop IDs only.
- Local mode sets `steam_workshop_enabled = false` and scans the game's `mods/` folder.
- Restart Brotato after mod changes. Check `%APPDATA%/Brotato/logs/modloader.log`.

Keep the repository limited to original mod code and assets.
