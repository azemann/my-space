#!/usr/bin/env python3
"""Remove ImageGen dividers and normalize the v006 source to 32 px cells."""

from pathlib import Path
import json

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "pipeline/assets/sources/imagegen/terrain/world-terrain-source-v001.png"
OUTPUT_DIR = ROOT / "game/world/tileset/terrain/families"
MASTER = ROOT / "game/world/tileset/terrain/terrain_atlas.png"
MANIFEST = ROOT / "game/world/tileset/terrain/terrain_catalog.json"
TILE = 32

# Detected divider centers in the 1254 px ImageGen source. The final partial
# strip is deliberately excluded: it is not a complete tile.
X_LINES = [1, 112, 221, 330, 440, 550, 659, 769, 878, 988, 1098, 1208]
Y_LINES = [1, 117, 228, 340, 451, 562, 673, 784, 896, 1007, 1119, 1231]
FAMILIES = [
    ("01_grass_paths", "Herbe et premiers chemins"),
    ("02_dirt_transitions", "Jonctions de chemins en terre"),
    ("03_stone_paving", "Pavés et bordures de pierre"),
    ("04_water_bases", "Eau et premières cascades"),
    ("05_water_banks", "Berges, coins et bassins"),
    ("06_cliff_tops", "Sommets et rebords de falaise"),
    ("07_cliff_faces", "Faces rocheuses"),
    ("08_cliff_transitions", "Coins et transitions de falaise"),
    ("09_stone_stairs", "Escaliers de pierre"),
    ("10_waterfalls_upper", "Cascades et raccords supérieurs"),
    ("11_waterfalls_lower", "Cascades et raccords inférieurs"),
]


def cell(source: Image.Image, column: int, row: int) -> Image.Image:
    left, right = X_LINES[column] + 2, X_LINES[column + 1] - 2
    top, bottom = Y_LINES[row] + 2, Y_LINES[row + 1] - 2
    return source.crop((left, top, right, bottom)).resize(
        (TILE, TILE), Image.Resampling.LANCZOS
    )


def enrich_wide_path_variants(strip: Image.Image) -> Image.Image:
    """Reserve variants 06..10 for seamless two-cell-wide dirt roads."""
    result = strip.copy()
    source_cross = strip.crop((4 * TILE, 0, 5 * TILE, TILE))
    dirt = source_cross.crop((8, 8, 24, 24)).resize(
        (TILE, TILE), Image.Resampling.LANCZOS
    )
    top = strip.crop((7 * TILE, 0, 8 * TILE, TILE)).copy()
    # The source top edge also contains narrow side shoulders. Replacing their
    # lower portion with dirt makes adjacent cells meet without grass seams.
    for x in range(TILE):
        for y in range(TILE):
            if y >= 8 and (x < 7 or x >= TILE - 7):
                top.putpixel((x, y), dirt.getpixel((x, y)))
    bottom = top.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
    left = top.transpose(Image.Transpose.ROTATE_90)
    right = left.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    for column, tile in enumerate((dirt, top, bottom, left, right), start=6):
        result.paste(tile, (column * TILE, 0))
    return result


def main() -> int:
    source = Image.open(SOURCE).convert("RGBA")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    master = Image.new("RGBA", (11 * TILE, 11 * TILE))
    catalog = []
    for row, (family_id, description) in enumerate(FAMILIES):
        strip = Image.new("RGBA", (11 * TILE, TILE))
        for column in range(11):
            tile = cell(source, column, row)
            strip.paste(tile, (column * TILE, 0))
            master.paste(tile, (column * TILE, row * TILE))
            catalog.append({
                "id": f"{family_id}.variant_{column:02d}",
                "family": family_id,
                "description": description,
                "master_coordinates": [column, row],
                "strip_coordinates": [column, 0],
            })
        if row == 1:
            strip = enrich_wide_path_variants(strip)
            master.paste(strip, (0, row * TILE))
        strip.save(OUTPUT_DIR / f"{family_id}.png", optimize=True)
    master.save(MASTER, optimize=True)
    MANIFEST.write_text(json.dumps({
        "schema_version": 1,
        "tile_size_px": [TILE, TILE],
        "grid_size": [11, 11],
        "source": str(SOURCE.relative_to(ROOT)),
        "master": str(MASTER.relative_to(ROOT)),
        "families": [
            {"id": family_id, "description": description, "texture": f"game/world/tileset/terrain/families/{family_id}.png"}
            for family_id, description in FAMILIES
        ],
        "tiles": catalog,
    }, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Terrain v006 : {len(catalog)} tuiles, 11 familles, grille {TILE}px")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
