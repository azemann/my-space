#!/usr/bin/env python3
"""Expose canonical Godot terrain and object sources as external Tiled TSX files."""

from pathlib import Path
import json
import os
import xml.etree.ElementTree as ET

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
CATALOG = ROOT / "game/world/tileset/terrain/terrain_catalog.json"
BEACH_CATALOG = ROOT / "game/world/tileset/beach/terrain/beach_terrain_catalog.json"
OBJECT_CATALOG = ROOT / "game/world/tileset/objects/objects_catalog.json"
OBJECT_ATLAS = ROOT / "game/world/tileset/objects/objects_atlas.png"
BEACH_OBJECT_CATALOG = ROOT / "game/world/tileset/beach/objects/beach_objects_catalog.json"
BEACH_OBJECT_ATLAS = ROOT / "game/world/tileset/beach/objects/beach_objects_atlas.png"
OUTPUT = ROOT / "pipeline/tiled/maps/tilesets"
OBJECT_IMAGES = OUTPUT / "objects"


def property_node(parent: ET.Element, name: str, value: object, kind: str = "string") -> None:
    serialized = str(value).lower() if isinstance(value, bool) else str(value)
    attributes = {"name": name, "value": serialized}
    if kind != "string":
        attributes["type"] = kind
    ET.SubElement(parent, "property", attributes)


def export_objects(catalog_path: Path, atlas_path: Path, output_name: str, source_id: int,
                   use_sprite_sheet: bool = False) -> int:
    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    sprites = catalog["sprites"]
    atlas = Image.open(atlas_path).convert("RGBA")
    image_dir = OBJECT_IMAGES / output_name
    if not use_sprite_sheet:
        image_dir.mkdir(parents=True, exist_ok=True)
    exported = []
    for tile_id, sprite in enumerate(sprites):
        atlas_x, atlas_y = sprite["atlas_coordinates"]
        region_w, region_h = sprite["region_size_px"]
        foot_x, foot_y = sprite["foot_anchor_px"]
        image = atlas.crop((atlas_x * 32, atlas_y * 32, atlas_x * 32 + region_w, atlas_y * 32 + foot_y))
        filename = f"{tile_id:02d}_{sprite['id'].replace('.', '_')}.png"
        if not use_sprite_sheet:
            image.save(image_dir / filename)
        exported.append((tile_id, sprite, filename, image.width, image.height, foot_x))

    layout = catalog.get("layout", {})
    sheet_cell = layout.get("cell_size_px")
    root = ET.Element("tileset", {
        "version": "1.10", "tiledversion": "1.12.2", "name": output_name,
        "tilewidth": str(sheet_cell[0] if use_sprite_sheet else max(item[3] for item in exported)),
        "tileheight": str(sheet_cell[1] if use_sprite_sheet else max(item[4] for item in exported)),
        "tilecount": str(len(exported)),
        "columns": str(layout["columns"] if use_sprite_sheet else 0),
        "objectalignment": "bottom",
    })
    properties = ET.SubElement(root, "properties")
    property_node(properties, "godot_source_id", source_id, "int")
    property_node(properties, "godot_mapping", "explicit_atlas_coordinates")
    property_node(properties, "description", "Objets nommés du monde, ancrés par leur point de pied")
    if use_sprite_sheet:
        relative_atlas = Path(os.path.relpath(atlas_path, OUTPUT)).as_posix()
        ET.SubElement(root, "image", {
            "source": relative_atlas, "width": str(atlas.width), "height": str(atlas.height)
        })
    for tile_id, sprite, filename, width, height, foot_x in exported:
        tile = ET.SubElement(root, "tile", {"id": str(tile_id), "class": sprite["default_role"]})
        tile_properties = ET.SubElement(tile, "properties")
        property_node(tile_properties, "object_id", sprite["id"])
        property_node(tile_properties, "godot_atlas_x", sprite["atlas_coordinates"][0], "int")
        property_node(tile_properties, "godot_atlas_y", sprite["atlas_coordinates"][1], "int")
        property_node(tile_properties, "recommended_layer", sprite["recommended_layer"])
        property_node(tile_properties, "default_role", sprite["default_role"])
        property_node(tile_properties, "asset_group", sprite["group"])
        property_node(tile_properties, "foot_anchor_x", foot_x, "int")
        property_node(tile_properties, "foot_anchor_y", sprite["foot_anchor_px"][1], "int")
        property_node(tile_properties, "content_offset_x", sprite["content_offset_px"][0], "int")
        property_node(tile_properties, "content_offset_y", sprite["content_offset_px"][1], "int")
        property_node(tile_properties, "content_width", sprite["content_size_px"][0], "int")
        property_node(tile_properties, "content_height", sprite["content_size_px"][1], "int")
        property_node(tile_properties, "tiled_image_width", width, "int")
        property_node(tile_properties, "tiled_image_height", height, "int")
        profile = sprite["psychokinesis"]
        property_node(tile_properties, "psychokinesis_response", profile["response"])
        property_node(tile_properties, "psychokinesis_mass", profile["mass"])
        property_node(tile_properties, "psychokinesis_material", profile["material"])
        property_node(tile_properties, "psychokinesis_breakable", profile["breakable"], "bool")
        property_node(tile_properties, "psychokinesis_required_power", profile["required_power"], "int")
        if not use_sprite_sheet:
            ET.SubElement(tile, "image", {
                "source": f"objects/{output_name}/{filename}", "width": str(width), "height": str(height)
            })
    ET.indent(root, space=" ")
    ET.ElementTree(root).write(OUTPUT / f"{output_name}.tsx", encoding="utf-8", xml_declaration=True)
    return len(exported)


def main() -> int:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    beach_catalog = json.loads(BEACH_CATALOG.read_text(encoding="utf-8"))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    families = [dict(family, source_id=source_id, tile_count=11) for source_id, family in enumerate(catalog["families"])]
    families.extend(beach_catalog["families"])
    for family in families:
        source_id = int(family["source_id"])
        tile_count = int(family.get("tile_count", 11))
        texture = ROOT / family["texture"]
        texture_width, texture_height = Image.open(texture).size
        columns = texture_width // 32
        atlas_tile_count = columns * (texture_height // 32)
        relative_texture = Path(os.path.relpath(texture, OUTPUT)).as_posix()
        root = ET.Element("tileset", {
            "version": "1.10",
            "tiledversion": "1.12.2",
            "name": family["id"],
            "tilewidth": "32",
            "tileheight": "32",
            "tilecount": str(atlas_tile_count),
            "columns": str(columns),
        })
        properties = ET.SubElement(root, "properties")
        property_node(properties, "godot_source_id", source_id, "int")
        property_node(properties, "description", family["description"])
        animation = family.get("tile_animation")
        if animation:
            property_node(properties, "godot_mapping", "explicit_atlas_coordinates")
        ET.SubElement(root, "image", {
            "source": relative_texture, "width": str(texture_width), "height": str(texture_height)
        })
        if animation:
            frame_count = int(animation["frames"])
            duration = int(animation["duration_ms"])
            for logical_id in animation["tiles"]:
                tile = ET.SubElement(root, "tile", {"id": str(logical_id)})
                tile_properties = ET.SubElement(tile, "properties")
                property_node(tile_properties, "godot_atlas_x", logical_id, "int")
                property_node(tile_properties, "godot_atlas_y", 0, "int")
                sequence = ET.SubElement(tile, "animation")
                for frame in range(frame_count):
                    frame_id = frame * columns + logical_id
                    ET.SubElement(sequence, "frame", {"tileid": str(frame_id), "duration": str(duration)})
                    if frame == 0:
                        continue
                    frame_tile = ET.SubElement(root, "tile", {"id": str(frame_id)})
                    frame_properties = ET.SubElement(frame_tile, "properties")
                    property_node(frame_properties, "godot_atlas_x", logical_id, "int")
                    property_node(frame_properties, "godot_atlas_y", 0, "int")
        ET.indent(root, space=" ")
        ET.ElementTree(root).write(
            OUTPUT / f"{family['id']}.tsx", encoding="utf-8", xml_declaration=True
        )
    object_count = export_objects(OBJECT_CATALOG, OBJECT_ATLAS, "world_objects", 20)
    beach_object_count = export_objects(
        BEACH_OBJECT_CATALOG, BEACH_OBJECT_ATLAS, "beach_objects", 21, use_sprite_sheet=True
    )
    print(f"Tiled : {len(families)} terrains et {object_count + beach_object_count} objets reliés au TileSet Godot canonique.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
