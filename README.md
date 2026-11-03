# Brotato Mods

Mods for Brotato using its built-in Godot ModLoader.

## Current mod

`DanielSolin-FreeRerolls` makes shop and level-up rerolls free while keeping
the normal item selection and game interface.

## Development

- Keep each mod in `mods-unpacked/<Namespace>-<Name>/`.
- Package one mod with `python3 scripts/package_mod.py DanielSolin-FreeRerolls`.
- The ZIP appears in `dist/` with ModLoader's expected `mods-unpacked/` path.
- Steam's default ModLoader profile scans subscribed Workshop IDs only.
- Local mode sets `steam_workshop_enabled = false` and scans the game's `mods/` folder.
- Restart Brotato after mod changes. Check `%APPDATA%/Brotato/logs/modloader.log`.

Keep the repository limited to original mod code and assets.
