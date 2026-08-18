#!/usr/bin/env python3
"""Validate the authoring contract shared by every playable RPG map."""

from __future__ import annotations

from argparse import ArgumentParser
from pathlib import Path
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
REQUIRED_GAMEPLAY_LAYERS = {
    "HeightZones", "ElevationTransitions", "CollisionOverrides", "Entrances",
    "Exits", "Interactions", "SpawnPoints", "CameraZones",
}
REQUIRED_BOUNDARIES = {
    "WorldBoundaryNorth", "WorldBoundarySouth", "WorldBoundaryWest", "WorldBoundaryEast",
}


def properties(node: ET.Element) -> dict[str, str]:
    return {
        item.get("name", ""): item.get("value", item.text or "")
        for item in node.findall("./properties/property")
    }


def validate_map(path: Path) -> list[str]:
    root = ET.parse(path).getroot()
    errors: list[str] = []
    map_props = properties(root)
    for key in ("level_id", "traversal_contract_version", "camera_contract_version"):
        if not map_props.get(key):
            errors.append(f"propriété de carte absente : {key}")

    gameplay = next((group for group in root.findall("group") if group.get("name") == "Gameplay"), None)
    if gameplay is None:
        return errors + ["groupe Gameplay absent"]
    groups = {group.get("name", ""): group for group in gameplay.findall("objectgroup")}
    for name in sorted(REQUIRED_GAMEPLAY_LAYERS - groups.keys()):
        errors.append(f"calque gameplay absent : {name}")

    collisions = groups.get("CollisionOverrides")
    if collisions is not None:
        names = [item.get("name", "") for item in collisions.findall("object")]
        for name in sorted(REQUIRED_BOUNDARIES - set(names)):
            errors.append(f"bord physique absent : {name}")
        if len(names) != len(set(names)):
            errors.append("noms de collisions dupliqués")
        for item in collisions.findall("object"):
            has_area = float(item.get("width", "0")) > 0 and float(item.get("height", "0")) > 0
            has_geometry = item.find("polygon") is not None or item.find("polyline") is not None
            if not has_area and not has_geometry:
                errors.append(f"collision sans géométrie : {item.get('name', item.get('id'))}")

    spawns = groups.get("SpawnPoints")
    spawn_ids: list[str] = []
    if spawns is not None:
        spawn_ids = [properties(item).get("spawn_id", "") for item in spawns.findall("object")]
        if not spawn_ids:
            errors.append("aucun spawn joueur")
        if "" in spawn_ids or len(spawn_ids) != len(set(spawn_ids)):
            errors.append("spawn_id absent ou dupliqué")

    camera_zones = groups.get("CameraZones")
    if camera_zones is not None:
        zones = camera_zones.findall("object")
        if not zones:
            errors.append("aucune zone caméra")
        for zone in zones:
            zone_props = properties(zone)
            for key in ("limit_left", "limit_top", "limit_right", "limit_bottom", "zoom"):
                if key not in zone_props:
                    errors.append(f"zone caméra {zone.get('name')} sans {key}")

    height_zones = groups.get("HeightZones")
    levels = {
        int(properties(item).get("height_level", "0"))
        for item in height_zones.findall("object")
    } if height_zones is not None else set()
    transitions = groups.get("ElevationTransitions")
    linked_levels: set[int] = set()
    if transitions is not None:
        for item in transitions.findall("object"):
            item_props = properties(item)
            if "from_height" not in item_props or "to_height" not in item_props:
                errors.append(f"transition sans hauteurs : {item.get('name')}")
                continue
            linked_levels.update((int(item_props["from_height"]), int(item_props["to_height"])))
    for level in sorted(levels - {0} - linked_levels):
        errors.append(f"hauteur {level} sans transition")

    return errors


def assert_map_contract(path: Path) -> None:
    errors = validate_map(path)
    if errors:
        raise ValueError(f"Contrat de carte invalide ({path}):\n- " + "\n- ".join(errors))


def main() -> int:
    parser = ArgumentParser()
    parser.add_argument("maps", nargs="*", type=Path)
    args = parser.parse_args()
    paths = args.maps or sorted((ROOT / "maps/source").glob("*.tmx"))
    failed = False
    for path in paths:
        absolute = path if path.is_absolute() else ROOT / path
        errors = validate_map(absolute)
        if errors:
            failed = True
            print(f"ERREUR {absolute.relative_to(ROOT)}")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"OK {absolute.relative_to(ROOT)}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
