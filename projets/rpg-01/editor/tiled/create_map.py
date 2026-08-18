#!/usr/bin/env python3
"""Create a blank RPG TMX with the canonical layer contract."""

from argparse import ArgumentParser
from pathlib import Path
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
TILESETS = ROOT / "maps/tilesets"

TILE_GROUPS = {
    "Terrain": ["Ground", "GroundVariations", "Paths", "CultivatedSoil", "StoneFloors"],
    "Water": ["WaterBase", "WaterBanks", "WaterEffects"],
    "Relief": ["CliffBack", "CliffFaces", "CliffFront", "Stairs"],
    "Architecture": ["Floors", "Bridges", "WallsBack", "Buildings", "Fences", "WallsFront"],
    "Decoration": ["Shadows", "GroundDecor", "PropsBack", "Vegetation", "YSortedProps", "Canopy", "Foreground"],
}
OBJECT_GROUPS = {
    "HeightZones": "height_zone",
    "ElevationTransitions": "elevation_transition",
    "CollisionOverrides": "collision",
    "Entrances": "entrance",
    "Exits": "exit",
    "Interactions": "interaction",
    "Entities": "entity",
    "SpawnPoints": "spawn",
    "EncounterZones": "encounter_zone",
    "CameraZones": "camera_zone",
    "AudioZones": "audio_zone",
}
PLACED_OBJECT_GROUPS = {
    "ArchitectureObjects": (20, False),
    "BoundaryObjects": (30, False),
    "GroundObjects": (5, False),
    "YSortedObjects": (40, True),
    "WaterObjects": (15, False),
    "ForegroundObjects": (80, False),
}
ENVIRONMENT_ANIMATION_DEFAULTS = {
    "WaterBase": "water_calm",
    "WaterBanks": "shoreline_foam",
    "WaterEffects": "water_flow",
}


def property_node(parent: ET.Element, name: str, value: str, kind: str = "string") -> None:
    values = {"name": name, "value": value}
    if kind != "string":
        values["type"] = kind
    ET.SubElement(parent, "property", values)


def build(level_id: str, output: Path, width: int, height: int) -> None:
    root = ET.Element("map", {
        "version": "1.10", "tiledversion": "1.12.2", "orientation": "orthogonal",
        "renderorder": "right-down", "width": str(width), "height": str(height),
        "tilewidth": "32", "tileheight": "32", "infinite": "0",
        "backgroundcolor": "#15231b", "nextobjectid": "1",
    })
    properties = ET.SubElement(root, "properties")
    property_node(properties, "level_id", level_id)
    property_node(properties, "level_name", level_id.replace("-", " ").title())
    property_node(properties, "height_levels", "2", "int")
    property_node(properties, "traversal_contract_version", "1", "int")
    property_node(properties, "camera_contract_version", "1", "int")
    first_gid = 1
    for tsx in sorted(TILESETS.glob("*.tsx")):
        tile_count = int(ET.parse(tsx).getroot().get("tilecount", "0"))
        if tile_count <= 0:
            raise ValueError(f"TSX sans tuile : {tsx}")
        ET.SubElement(root, "tileset", {
            "firstgid": str(first_gid),
            "source": Path("../tilesets", tsx.name).as_posix(),
        })
        first_gid += tile_count
    layer_id = 1
    empty_csv = ",".join("0" for _ in range(width * height))
    for group_name, layers in TILE_GROUPS.items():
        group = ET.SubElement(root, "group", {"id": str(layer_id), "name": group_name})
        layer_id += 1
        for layer_name in layers:
            layer = ET.SubElement(group, "layer", {
                "id": str(layer_id), "name": layer_name,
                "width": str(width), "height": str(height),
            })
            layer_id += 1
            layer_properties = ET.SubElement(layer, "properties")
            property_node(layer_properties, "z_index", str(layer_id), "int")
            property_node(layer_properties, "y_sort", "true" if layer_name == "YSortedProps" else "false", "bool")
            traversal = (
                "blocked" if layer_name in {"WaterBase", "WaterBanks", "CliffBack", "CliffFaces", "CliffFront"}
                else "transition" if layer_name == "Stairs"
                else "walk" if layer_name in {"Ground", "GroundVariations", "Paths", "CultivatedSoil", "StoneFloors"}
                else "visual"
            )
            property_node(layer_properties, "traversal_intent", traversal)
            animation_profile = ENVIRONMENT_ANIMATION_DEFAULTS.get(layer_name)
            if animation_profile:
                property_node(layer_properties, "environment_animation_profile", animation_profile)
            ET.SubElement(layer, "data", {"encoding": "csv"}).text = empty_csv
    placed = ET.SubElement(root, "group", {"id": str(layer_id), "name": "PlacedObjects"})
    layer_id += 1
    for layer_name, (z_index, y_sort) in PLACED_OBJECT_GROUPS.items():
        group = ET.SubElement(placed, "objectgroup", {"id": str(layer_id), "name": layer_name, "draworder": "topdown"})
        layer_id += 1
        group_properties = ET.SubElement(group, "properties")
        property_node(group_properties, "godot_role", "tile_objects")
        property_node(group_properties, "z_index", str(z_index), "int")
        property_node(group_properties, "y_sort", "true" if y_sort else "false", "bool")
    gameplay = ET.SubElement(root, "group", {"id": str(layer_id), "name": "Gameplay"})
    layer_id += 1
    for layer_name, role in OBJECT_GROUPS.items():
        group = ET.SubElement(gameplay, "objectgroup", {"id": str(layer_id), "name": layer_name, "visible": "0"})
        layer_id += 1
        group_properties = ET.SubElement(group, "properties")
        property_node(group_properties, "godot_role", role)
    root.set("nextlayerid", str(layer_id))
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space=" ")
    ET.ElementTree(root).write(output, encoding="utf-8", xml_declaration=True)


def main() -> int:
    parser = ArgumentParser()
    parser.add_argument("level_id", nargs="?", default="rpg-map-template")
    parser.add_argument("--width", type=int, default=40)
    parser.add_argument("--height", type=int, default=30)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    output = args.output or ROOT / "maps/source" / f"{args.level_id}.tmx"
    if not output.is_absolute():
        output = ROOT / output
    build(args.level_id, output, args.width, args.height)
    print(f"Carte Tiled créée : {output.relative_to(ROOT)} ({args.width}×{args.height})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
