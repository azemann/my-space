#!/usr/bin/env python3
"""Normalize the ImageGen beach board into deterministic 32 px strips."""

from pathlib import Path
import json

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "source-art/imagegen/beach/beach-terrain-source-v001.png"
OUTPUT_DIR = ROOT / "game/world/tileset/beach/terrain/families"
MANIFEST = ROOT / "game/world/tileset/beach/terrain/beach_terrain_catalog.json"
PREVIEW = ROOT / "source-art/previews/beach-terrain-preview.png"
TILE = 32
X_LINES = [1, 147, 294, 441, 588, 734, 881, 1028, 1175, 1322, 1469]
Y_LINES = [1, 146, 290, 432, 572, 708, 833, 957, 1069]
FAMILIES = [
    ("12_beach_dry_sand", "Sable sec et variations", "sand", "walk", "Terrain/Ground"),
    ("13_beach_wet_sand", "Sable humide et transitions", "wet_sand", "walk", "Terrain/GroundVariations"),
    ("14_beach_shallow_water", "Eau marine peu profonde", "shallow_water", "blocked", "Water/WaterBase"),
    ("15_beach_deep_water", "Eau marine profonde", "deep_water", "blocked", "Water/WaterBase"),
    ("16_beach_shoreline", "Rivage sable et mer", "shoreline", "blocked", "Water/WaterBanks"),
    ("17_beach_foam", "Écume et vagues", "foam", "visual", "Water/WaterEffects"),
    ("18_beach_dunes", "Dunes et herbes côtières", "dune", "walk", "Terrain/GroundVariations"),
    ("19_beach_rock_coast", "Rebords rocheux côtiers", "coastal_cliff", "blocked", "Relief/CliffFaces"),
]
ANIMATIONS = {
    "14_beach_shallow_water": {
        "frames": 4, "duration_ms": 180, "mode": "random_start",
        "direction": [0, -1], "kind": "north_scroll", "tiles": [0, 1, 2, 3],
    },
    "15_beach_deep_water": {
        "frames": 4, "duration_ms": 220, "mode": "random_start",
        "direction": [0, -1], "kind": "north_scroll", "tiles": [0, 1, 2, 3],
    },
    "16_beach_shoreline": {
        "frames": 4, "duration_ms": 170, "mode": "default",
        "direction": [0, -1], "kind": "north_surge", "tiles": [0],
    },
    "17_beach_foam": {
        "frames": 4, "duration_ms": 140, "mode": "default",
        "direction": [0, -1], "kind": "north_surge", "tiles": [0],
    },
}


def cell(source: Image.Image, column: int, row: int) -> Image.Image:
    return source.crop((
        X_LINES[column] + 3,
        Y_LINES[row] + 3,
        X_LINES[column + 1] - 3,
        Y_LINES[row + 1] - 3,
    )).resize((TILE, TILE), Image.Resampling.LANCZOS)


def north_frame(tile: Image.Image, amount: int, wrap: bool) -> Image.Image:
    """Move pixels north; shore frames keep water at the southern edge."""
    if amount == 0:
        return tile.copy()
    result = Image.new("RGBA", tile.size)
    result.paste(tile.crop((0, amount, TILE, TILE)), (0, 0))
    if wrap:
        result.paste(tile.crop((0, 0, TILE, amount)), (0, TILE - amount))
    else:
        southern_row = tile.crop((0, TILE - 1, TILE, TILE)).resize((TILE, amount))
        result.paste(southern_row, (0, TILE - amount))
    return result


def main() -> int:
    source = Image.open(SOURCE).convert("RGBA")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    preview = Image.new("RGBA", (10 * TILE, len(FAMILIES) * TILE))
    families = []
    tiles = []
    for row, (family_id, description, kind, traversal, layer) in enumerate(FAMILIES):
        animation = ANIMATIONS.get(family_id)
        frame_count = int(animation["frames"]) if animation else 1
        strip = Image.new("RGBA", (10 * TILE, frame_count * TILE))
        for column in range(10):
            tile = cell(source, column, row)
            animated = animation is not None and column in animation["tiles"]
            offsets = [0, 1, 2, 1]
            for frame in range(frame_count):
                frame_tile = north_frame(
                    tile,
                    offsets[frame] if animated else 0,
                    animation["kind"] == "north_scroll" if animation else False,
                )
                strip.paste(frame_tile, (column * TILE, frame * TILE))
            preview.paste(tile, (column * TILE, row * TILE))
            tiles.append({
                "id": f"{family_id}.variant_{column:02d}",
                "family": family_id,
                "atlas_coordinates": [column, 0],
            })
        texture = OUTPUT_DIR / f"{family_id}.png"
        strip.save(texture, optimize=True)
        family = {
            "id": family_id,
            "description": description,
            "texture": str(texture.relative_to(ROOT)),
            "source_id": 11 + row,
            "tile_count": 10,
            "terrain_kind": kind,
            "traversal": traversal,
            "recommended_layer": layer,
        }
        if animation:
            family["tile_animation"] = animation
        families.append(family)
    preview.resize((640, 512), Image.Resampling.NEAREST).save(PREVIEW)
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps({
        "schema_version": 1,
        "tile_size_px": [TILE, TILE],
        "source": str(SOURCE.relative_to(ROOT)),
        "families": families,
        "tiles": tiles,
    }, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("Plage : 80 tuiles, 8 familles, grille 32 px.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
