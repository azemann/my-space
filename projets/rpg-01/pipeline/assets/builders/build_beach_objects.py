#!/usr/bin/env python3
"""Extract and normalize the 30 beach props into one regular sprite sheet."""

from pathlib import Path
import json

import cv2
import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "pipeline/assets/sources/imagegen/beach/beach-objects-rgba-v002.png"
OUTPUT = ROOT / "game/world/tileset/beach/objects/beach_objects_atlas.png"
METADATA = ROOT / "game/world/tileset/beach/objects/beach_objects_catalog.json"
PREVIEW = ROOT / "pipeline/assets/sources/previews/beach-objects-preview.png"
TILE = 32
SHEET_COLUMNS = 6
SHEET_ROWS = 5
SPRITE_CELL = (160, 96)
NAMES = [
    ("beach.shell_cluster", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.starfish", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.pebble_cluster", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.seaweed", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.driftwood_sticks", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.driftwood_log", "nature/beach_obstacle", "YSortedObjects", "solid_interactable"),
    ("wreck.broken_mast", "wreckage", "YSortedObjects", "solid_interactable"),
    ("wreck.torn_sail", "wreckage", "YSortedObjects", "solid_interactable"),
    ("wreck.hull_planks", "wreckage", "GroundObjects", "decor_ground"),
    ("wreck.boat_rib", "wreckage", "YSortedObjects", "solid_interactable"),
    ("wreck.rope_coil", "wreckage", "GroundObjects", "interactable"),
    ("wreck.loose_rope", "wreckage", "GroundObjects", "decor_ground"),
    ("wreck.crate", "wreckage", "YSortedObjects", "solid_interactable"),
    ("wreck.crate_broken", "wreckage", "YSortedObjects", "solid_interactable"),
    ("story.corked_bottle", "story/clue", "GroundObjects", "interactable"),
    ("story.cloth_bundle", "story/clue", "GroundObjects", "interactable"),
    ("story.travel_satchel", "story/clue", "YSortedObjects", "interactable"),
    ("wreck.barrel_buried", "wreckage", "YSortedObjects", "solid_interactable"),
    ("wreck.fishing_net", "wreckage", "GroundObjects", "decor_ground"),
    ("wreck.anchor_fragment", "wreckage", "YSortedObjects", "solid_interactable"),
    ("telekinesis.practice_stone", "gameplay/telekinesis", "YSortedObjects", "interactable"),
    ("beach.rock_movable", "nature/beach_obstacle", "YSortedObjects", "solid_interactable"),
    ("beach.boulder_heavy", "nature/beach_obstacle", "YSortedObjects", "solid_footprint"),
    ("beach.palm_sapling", "nature/beach_vegetation", "YSortedObjects", "tree_trunk_obstacle"),
    ("beach.grass_tuft", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.dune_shrub", "nature/beach_vegetation", "YSortedObjects", "small_obstacle"),
    ("beach.tide_pool", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("beach.foam_debris", "nature/beach_ground", "GroundObjects", "decor_ground"),
    ("wreck.sign_fragment", "wreckage", "YSortedObjects", "interactable"),
    ("story.metallic_shard", "story/clue", "GroundObjects", "interactable"),
]


def psychokinesis_profile(asset_id: str, group: str, role: str) -> dict:
    material = (
        "stone" if any(word in asset_id for word in ("stone", "rock", "boulder", "pebble", "pool"))
        else "wood" if group == "wreckage" or "driftwood" in asset_id
        else "metal" if any(word in asset_id for word in ("anchor", "metallic"))
        else "glass" if "bottle" in asset_id
        else "plant" if "nature/" in group
        else "mixed"
    )
    light_assets = {
        "beach.shell_cluster", "beach.starfish", "beach.pebble_cluster", "beach.seaweed",
        "beach.driftwood_sticks", "wreck.rope_coil", "wreck.loose_rope",
        "story.corked_bottle", "story.cloth_bundle", "story.metallic_shard",
        "telekinesis.practice_stone", "beach.grass_tuft", "beach.foam_debris",
    }
    heavy_assets = {
        "wreck.broken_mast", "wreck.torn_sail", "wreck.boat_rib", "wreck.barrel_buried",
        "beach.boulder_heavy", "beach.palm_sapling",
    }
    mass = "light" if asset_id in light_assets else "heavy" if asset_id in heavy_assets else "medium"
    return {
        "response": "movable",
        "mass": mass,
        "material": material,
        "breakable": material in {"wood", "glass"},
        "required_power": 0,
    }


def main() -> int:
    source = Image.open(SOURCE).convert("RGBA")
    alpha = np.asarray(source.getchannel("A"))
    component_count, labels, stats, centroids = cv2.connectedComponentsWithStats(
        (alpha > 18).astype(np.uint8), connectivity=8
    )
    components_by_sprite = {index: [] for index in range(len(NAMES))}
    for label in range(1, component_count):
        if stats[label, cv2.CC_STAT_AREA] < 3:
            continue
        center_x, center_y = centroids[label]
        column = min(SHEET_COLUMNS - 1, int(center_x * SHEET_COLUMNS / source.width))
        row = min(SHEET_ROWS - 1, int(center_y * SHEET_ROWS / source.height))
        components_by_sprite[row * SHEET_COLUMNS + column].append(label)

    items = []
    for index, definition in enumerate(NAMES):
        component_labels = components_by_sprite[index]
        if not component_labels:
            raise RuntimeError(f"Objet absent à l'index {index}")
        component_mask = np.isin(labels, component_labels).astype(np.uint8)
        # Recover the soft antialiased fringe around each opaque component without
        # admitting pieces from the neighbouring source cell.
        component_mask = cv2.dilate(component_mask, np.ones((3, 3), np.uint8), iterations=2)
        isolated = source.copy()
        isolated.putalpha(Image.fromarray(alpha * component_mask))
        crop = isolated
        alpha_box = crop.getchannel("A").point(lambda value: 255 if value > 18 else 0).getbbox()
        crop = crop.crop(alpha_box)
        scale = 0.48
        crop = crop.resize((max(1, round(crop.width * scale)), max(1, round(crop.height * scale))), Image.Resampling.LANCZOS)
        if crop.width > SPRITE_CELL[0] - 10 or crop.height > SPRITE_CELL[1] - 10:
            raise RuntimeError(f"Objet trop grand pour une cellule {SPRITE_CELL} : {definition[0]} {crop.size}")
        cells = [SPRITE_CELL[0] // TILE, SPRITE_CELL[1] // TILE]
        items.append({"id": definition[0], "group": definition[1], "recommended_layer": definition[2],
                      "default_role": definition[3], "psychokinesis": psychokinesis_profile(definition[0], definition[1], definition[3]),
                      "image": crop, "size_in_cells": cells})

    atlas = Image.new("RGBA", (SHEET_COLUMNS * SPRITE_CELL[0], SHEET_ROWS * SPRITE_CELL[1]), (0, 0, 0, 0))
    for index, item in enumerate(items):
        row, column = divmod(index, SHEET_COLUMNS)
        item["sheet_cell"] = [column, row]
        item["atlas_coordinates"] = [
            column * (SPRITE_CELL[0] // TILE),
            row * (SPRITE_CELL[1] // TILE),
        ]
        x, y = (value * TILE for value in item["atlas_coordinates"])
        region = list(SPRITE_CELL)
        image = item.pop("image")
        paste = [x + (region[0] - image.width) // 2, y + region[1] - image.height - 5]
        atlas.alpha_composite(image, tuple(paste))
        item["region_size_px"] = region
        item["content_size_px"] = list(image.size)
        item["content_offset_px"] = [paste[0] - x, paste[1] - y]
        item["foot_anchor_px"] = [region[0] // 2, region[1] - 5]
        item["anchor_kind"] = "foot"
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(OUTPUT, optimize=True)
    atlas.resize((atlas.width // 2, atlas.height // 2), Image.Resampling.LANCZOS).save(PREVIEW)
    METADATA.write_text(json.dumps({
        "schema_version": 1, "id": "beach-objects-v002", "source_id": 21,
        "layout": {"kind": "uniform_grid", "columns": SHEET_COLUMNS, "rows": SHEET_ROWS,
                   "cell_size_px": list(SPRITE_CELL)},
        "tile_size_px": [TILE, TILE], "source": str(SOURCE.relative_to(ROOT)),
        "atlas_size_px": list(atlas.size), "sprite_count": len(items), "sprites": items,
    }, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Plage : {len(items)} objets nommés, atlas {atlas.width}×{atlas.height}px.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
