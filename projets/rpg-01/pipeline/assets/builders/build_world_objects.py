#!/usr/bin/env python3
"""Build the named atlas with one documented scale normalization per family."""

from __future__ import annotations

import json
import math
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[3]
SOURCES = {
    "architecture": ROOT / "pipeline/assets/sources/imagegen/objects/architecture-props-rgba-v001.png",
    "nature": ROOT / "pipeline/assets/sources/imagegen/objects/nature-props-rgba-v001.png",
}
CATALOG = ROOT / "game/world/tileset/objects/naming_catalog.json"
OUTPUT = ROOT / "game/world/tileset/objects/objects_atlas.png"
METADATA = ROOT / "game/world/tileset/objects/objects_catalog.json"
PREVIEW = ROOT / "pipeline/assets/sources/previews/objects_catalog.png"
TILE = 32
ATLAS = (2048, 2048)
PADDING = 5
SCALE_BY_GROUP = {
    "architecture/building": 0.60,
    "architecture/building_parts": 0.60,
    "architecture/openings": 0.55,
    "architecture/traversal": 0.58,
    "architecture/boundary": 0.55,
    "props/utility": 0.45,
    "props/storage": 0.45,
    "props/information": 0.45,
    "props/agriculture": 0.45,
    "props/garden": 0.45,
    "nature/trees": 0.55,
    "nature/bushes": 0.50,
    "nature/rocks": 0.55,
    "nature/flowers": 0.52,
    "nature/ground_cover": 0.50,
    "nature/pebbles": 0.52,
    "nature/wood": 0.52,
    "nature/water_plants": 0.52,
    "nature/relief": 0.55,
    "agriculture/plots": 0.50,
    "agriculture/crops": 0.50,
}
CENTER_ANCHOR_GROUPS = {"architecture/traversal"}


def psychokinesis_profile(asset_id: str, group: str, role: str) -> dict:
    material = (
        "stone" if any(word in asset_id for word in ("stone", "rock", "boulder", "cliff", "well"))
        else "wood" if any(word in asset_id for word in ("wood", "tree", "log", "stump", "crate", "barrel", "fence", "gate"))
        else "plant" if group.startswith(("nature/", "agriculture/"))
        else "mixed"
    )
    if group.startswith("architecture/") or group == "nature/relief":
        return {"response": "anchored", "mass": "immense", "material": material, "breakable": False, "required_power": 0}
    if group == "nature/trees":
        return {"response": "reactive", "mass": "heavy", "material": "wood", "breakable": False, "required_power": 0}
    if group == "nature/rocks":
        level = 1 if role == "small_obstacle" else 3
        return {"response": "movable", "mass": "medium" if level == 1 else "heavy", "material": "stone", "breakable": False, "required_power": level}
    if group in {"props/storage", "nature/wood"}:
        return {"response": "movable", "mass": "medium", "material": "wood", "breakable": True, "required_power": 1}
    if role in {"decor", "harvestable", "soft_obstacle"}:
        return {"response": "reactive", "mass": "light", "material": material, "breakable": role == "harvestable", "required_power": 0}
    return {"response": "reactive", "mass": "medium", "material": material, "breakable": False, "required_power": 0}


def components(path: Path, family: str) -> list[dict]:
    image = Image.open(path).convert("RGBA")
    alpha = np.asarray(image.getchannel("A"))
    mask = np.uint8(alpha > 18) * 255
    # Join antialiased fragments belonging to one object without merging rows.
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
    mask = cv2.dilate(mask, np.ones((3, 3), np.uint8), iterations=1)
    count, _, stats, _ = cv2.connectedComponentsWithStats(mask, 8)
    found = []
    for label in range(1, count):
        x, y, width, height, area = map(int, stats[label])
        if area < 80 or width < 4 or height < 4:
            continue
        left = max(0, x - PADDING)
        top = max(0, y - PADDING)
        right = min(image.width, x + width + PADDING)
        bottom = min(image.height, y + height + PADDING)
        found.append({
            "source_bbox": [left, top, right, bottom],
            "source_x": x,
            "source_y": y,
            "image": image.crop((left, top, right, bottom)),
            "family": family,
        })
    # Stable visual reading order, tolerant of small vertical misalignment.
    found.sort(key=lambda item: (item["source_y"] // 80, item["source_x"]))
    for index, item in enumerate(found):
        item["legacy_id"] = f"{family}_{index:02d}"
    return found


def grid_extent(size: int) -> int:
    return math.ceil((size + PADDING * 2) / TILE)


def pack(items: list[dict]) -> None:
    # Deterministic shelf packing. Tall sprites first reduces wasted cells.
    ordered = sorted(items, key=lambda item: (-grid_extent(item["image"].height), -grid_extent(item["image"].width), item["id"]))
    atlas_cells_x = ATLAS[0] // TILE
    atlas_cells_y = ATLAS[1] // TILE
    cursor_x = cursor_y = shelf_height = 0
    for item in ordered:
        cells_w = grid_extent(item["image"].width)
        cells_h = grid_extent(item["image"].height)
        if cursor_x + cells_w > atlas_cells_x:
            cursor_x = 0
            cursor_y += shelf_height
            shelf_height = 0
        if cursor_y + cells_h > atlas_cells_y:
            raise RuntimeError("2048px object atlas is full")
        item["atlas_coordinates"] = [cursor_x, cursor_y]
        item["size_in_cells"] = [cells_w, cells_h]
        item["region_size_px"] = [cells_w * TILE, cells_h * TILE]
        cursor_x += cells_w
        shelf_height = max(shelf_height, cells_h)


def main() -> int:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    names = {entry["legacy_id"]: entry for entry in catalog["entries"]}
    items = []
    for family, source in SOURCES.items():
        items.extend(components(source, family))
    found_ids = {item["legacy_id"] for item in items}
    if found_ids != set(names):
        missing = sorted(set(names) - found_ids)
        unexpected = sorted(found_ids - set(names))
        raise RuntimeError(f"Catalog mismatch; missing={missing}, unexpected={unexpected}")
    for item in items:
        definition = names[item["legacy_id"]]
        item.update({
            "id": definition["id"],
            "group": definition["group"],
            "recommended_layer": definition["layer"],
            "default_role": definition["default_role"],
        })
        item["psychokinesis"] = psychokinesis_profile(item["id"], item["group"], item["default_role"])
        scale = SCALE_BY_GROUP[item["group"]]
        source_size = list(item["image"].size)
        normalized_size = (
            max(1, round(source_size[0] * scale)),
            max(1, round(source_size[1] * scale)),
        )
        item["image"] = item["image"].resize(normalized_size, Image.Resampling.LANCZOS)
        item["normalization_scale"] = scale
        item["source_content_size_px"] = source_size
        item["anchor_kind"] = "center" if item["group"] in CENTER_ANCHOR_GROUPS else "foot"
    pack(items)
    atlas = Image.new("RGBA", ATLAS, (0, 0, 0, 0))
    for item in items:
        x = item["atlas_coordinates"][0] * TILE
        y = item["atlas_coordinates"][1] * TILE
        region_w, region_h = item["region_size_px"]
        sprite = item["image"]
        # Packing remains bottom-aligned; metadata selects the semantic anchor.
        paste_x = x + (region_w - sprite.width) // 2
        paste_y = y + region_h - sprite.height - PADDING
        atlas.alpha_composite(sprite, (paste_x, paste_y))
        item["content_offset_px"] = [paste_x - x, paste_y - y]
        item["content_size_px"] = list(sprite.size)
        item["foot_anchor_px"] = [region_w // 2, region_h - PADDING]
        del item["image"]
        del item["source_x"]
        del item["source_y"]
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(OUTPUT, optimize=True)

    # Preview uses a checkerboard so alpha and accidental halos are visible.
    checker = Image.new("RGBA", ATLAS, (33, 39, 38, 255))
    draw = ImageDraw.Draw(checker)
    for y in range(0, ATLAS[1], TILE):
        for x in range(0, ATLAS[0], TILE):
            if (x // TILE + y // TILE) % 2:
                draw.rectangle((x, y, x + TILE - 1, y + TILE - 1), fill=(44, 51, 49, 255))
    checker.alpha_composite(atlas)
    used_bottom = max((item["atlas_coordinates"][1] + item["size_in_cells"][1]) * TILE for item in items)
    checker.crop((0, 0, ATLAS[0], used_bottom)).resize((1024, used_bottom // 2), Image.Resampling.LANCZOS).save(PREVIEW)

    metadata = {
        "schema_version": 2,
        "id": "world-objects-v005",
        "tile_size_px": [TILE, TILE],
        "atlas_size_px": list(ATLAS),
        "sprite_count": len(items),
        "packing": "32px aligned shelf packing; one-time family scale normalization; no per-instance scaling; bottom-center foot anchor",
        "normalization": {
            "authority": "group scale in pipeline/assets/builders/build_world_objects.py",
            "runtime_scale": 1.0,
            "profiles": SCALE_BY_GROUP,
        },
        "sources": {family: str(path.relative_to(ROOT)) for family, path in SOURCES.items()},
        "naming_catalog": str(CATALOG.relative_to(ROOT)),
        "sprites": [{key: value for key, value in item.items()} for item in sorted(items, key=lambda item: item["id"])],
    }
    METADATA.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"output": str(OUTPUT), "sprites": len(items), "used_height_px": used_bottom}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
