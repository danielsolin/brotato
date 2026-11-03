#!/usr/bin/env python3
"""Package one unpacked Brotato mod for ModLoader."""

import argparse
import json
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODS_DIR = ROOT / "mods-unpacked"
DIST_DIR = ROOT / "dist"


def package_mod(mod_id: str) -> Path:
    mod_dir = MODS_DIR / mod_id
    manifest_path = mod_dir / "manifest.json"
    main_path = mod_dir / "mod_main.gd"

    if not manifest_path.is_file():
        raise ValueError(f"Missing manifest: {manifest_path}")
    if not main_path.is_file():
        raise ValueError(f"Missing entry point: {main_path}")

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    expected_id = f"{manifest['namespace']}-{manifest['name']}"
    if expected_id != mod_id:
        raise ValueError(f"Folder ID must match manifest ID: {expected_id}")

    version = manifest["version_number"]
    archive_path = DIST_DIR / f"{mod_id}-{version}.zip"
    DIST_DIR.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(mod_dir.rglob("*")):
            if not path.is_file():
                continue
            if ".godot" in path.relative_to(mod_dir).parts:
                continue

            archive_name = Path("mods-unpacked") / mod_id / path.relative_to(mod_dir)
            archive.write(path, archive_name.as_posix())

    return archive_path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mod_id", help="Mod folder name, for example DanielSolin-FreeRerolls")
    args = parser.parse_args()

    try:
        archive_path = package_mod(args.mod_id)
    except (KeyError, json.JSONDecodeError, ValueError) as error:
        parser.error(str(error))

    print(archive_path.relative_to(ROOT))


if __name__ == "__main__":
    main()
