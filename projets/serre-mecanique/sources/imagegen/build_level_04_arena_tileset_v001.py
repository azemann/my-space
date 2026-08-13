#!/usr/bin/env python3
"""Build the production 32x32 arena atlas from the ImageGen grid study."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw

from production_tileset_contract import (
    assert_horizontal_join,
    assert_no_horizontal_frame,
    assert_opaque,
    assert_vertical_join,
)


ROOT = Path(__file__).resolve().parents[2]
PREVIEW_SOURCE = ROOT / "sources" / "imagegen" / "generated" / "niveau-04-arene-preview-v001.png"
ALPHA_SOURCE = ROOT / "sources" / "imagegen" / "generated" / "niveau-04-arene-alpha-v001.png"
OUTPUT = ROOT / "assets" / "tilesets" / "niveau-04-arene-combat-32x32-v001.png"

TILE_SIZE = 32
COLUMNS = 16
ROWS = 5

# These cells are continuous wall or ground surfaces. Their alpha must fill the
# complete 32x32 cell. Props, ladders, ropes and suspended platforms retain
# transparency and internal breathing room.
FULL_SOLID_IDS = set(range(0, 20)) | set(range(23, 32)) | {47}
ONE_WAY_IDS = {40, 41, 42, 44}
VERTICAL_CONNECTOR_IDS = {37, 38, 39}
TOP_GROUND_IDS = {0, 1, 2}
SUBSURFACE_IDS = {3, 4, 5, 6, 7, 8}
SEAMLESS_WATER_IDS = {12, 26}


def is_generated_grid(pixel: tuple[int, int, int, int]) -> bool:
    red, green, blue, alpha = pixel
    return (
        alpha > 0
        and red > 105
        and 55 < green < 195
        and blue < 130
        and red > green
        and green > blue
    )


def connected_grid_mask(tile: Image.Image) -> set[tuple[int, int]]:
    """Find only gold grid pixels connected to a cell boundary."""
    pixels = tile.load()
    queue: deque[tuple[int, int]] = deque()
    visited: set[tuple[int, int]] = set()
    mask: set[tuple[int, int]] = set()

    # Resampling can leave one or two nearly transparent pixels between the
    # generated divider and the exact cell boundary. Seed the complete outer
    # three-pixel band so those separators are still identified.
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            if x < 3 or x >= TILE_SIZE - 3 or y < 3 or y >= TILE_SIZE - 3:
                if is_generated_grid(pixels[x, y]):
                    queue.append((x, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in visited:
            continue
        visited.add((x, y))
        if not is_generated_grid(pixels[x, y]):
            continue
        mask.add((x, y))
        for next_x, next_y in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= next_x < TILE_SIZE and 0 <= next_y < TILE_SIZE:
                queue.append((next_x, next_y))
    return mask


def nearest_clean_pixel(tile: Image.Image, x: int, y: int, grid_mask: set[tuple[int, int]]) -> tuple[int, int, int, int]:
    pixels = tile.load()
    for radius in range(1, TILE_SIZE):
        candidates = (
            (min(TILE_SIZE - 1, x + radius), y),
            (max(0, x - radius), y),
            (x, min(TILE_SIZE - 1, y + radius)),
            (x, max(0, y - radius)),
        )
        for candidate_x, candidate_y in candidates:
            if (candidate_x, candidate_y) not in grid_mask:
                return pixels[candidate_x, candidate_y]
    return (24, 30, 30, 255)


def paint_one_way_surface(tile: Image.Image) -> None:
    """Replace the padded ImageGen platform with an exact repeatable surface."""
    draw = ImageDraw.Draw(tile)
    draw.rectangle((0, 15, 31, 31), fill=(0, 0, 0, 0))
    draw.line((0, 15, 31, 15), fill=(13, 18, 19, 255), width=1)
    draw.line((0, 16, 31, 16), fill=(104, 112, 108, 255), width=1)
    draw.rectangle((0, 17, 31, 22), fill=(43, 49, 49, 255))
    for x in range(0, 32, 8):
        draw.polygon(((x, 17), (min(31, x + 4), 17), (min(31, x + 10), 22), (min(31, x + 6), 22)), fill=(172, 111, 44, 255))
    draw.line((0, 23, 31, 23), fill=(13, 18, 19, 255), width=1)
    for y in range(15, 24):
        tile.putpixel((31, y), tile.getpixel((0, y)))
        tile.putpixel((30, y), tile.getpixel((1, y)))


def paint_seamless_ground(tile: Image.Image, tile_id: int) -> None:
    """Paint terrain as continuous material, never as an outlined block."""
    soil = (73, 62, 43, 255)
    soil_light = (91, 76, 48, 255)
    soil_dark = (57, 50, 39, 255)
    moss = (87, 119, 46, 255)
    moss_light = (130, 151, 60, 255)
    tile.paste(soil, (0, 0, TILE_SIZE, TILE_SIZE))
    draw = ImageDraw.Draw(tile)

    if tile_id in TOP_GROUND_IDS:
        draw.line((0, 0, 31, 0), fill=moss_light, width=1)
        draw.rectangle((0, 1, 31, 3), fill=moss)
        draw.line((0, 4, 31, 4), fill=soil_light, width=1)
        interior_top = 6
    else:
        interior_top = 2

    # Variant detail is confined to the interior. The two-pixel perimeter keeps
    # the dominant material, so repetition cannot draw a frame around a cell.
    seed = tile_id * 17 + 11
    for index in range(9):
        x = 3 + ((seed + index * 11) % 25)
        y = interior_top + ((seed * 3 + index * 7) % max(1, 28 - interior_top))
        color = soil_light if index % 3 == 0 else soil_dark
        draw.rectangle((x, y, min(28, x + 2 + index % 2), min(29, y + 1)), fill=color)

    # Restore all join bands after adding detail.
    for y in range(TILE_SIZE):
        base = moss_light if y == 0 and tile_id in TOP_GROUND_IDS else moss if 1 <= y <= 3 and tile_id in TOP_GROUND_IDS else soil_light if y == 4 and tile_id in TOP_GROUND_IDS else soil
        draw.line((0, y, 1, y), fill=base, width=1)
        draw.line((30, y, 31, y), fill=base, width=1)
    draw.line((0, 31, 31, 31), fill=soil, width=1)
    if tile_id in SUBSURFACE_IDS:
        draw.line((0, 0, 31, 0), fill=soil, width=1)


def paint_seamless_water(tile: Image.Image) -> None:
    """Paint a repeatable coolant surface without a tank frame."""
    palette = (
        (111, 207, 199, 255),
        (48, 155, 155, 255),
        (31, 111, 117, 255),
        (24, 82, 91, 255),
    )
    draw = ImageDraw.Draw(tile)
    for y in range(TILE_SIZE):
        color = palette[0] if y == 0 else palette[1] if y < 4 else palette[2] if y < 15 else palette[3]
        draw.line((0, y, 31, y), fill=color, width=1)
    for x in (5, 13, 21, 29):
        draw.point((x, 2), fill=(143, 226, 214, 255))
        draw.line((x, 7, x, 10), fill=(43, 137, 139, 255), width=1)
    # Exact repeat bands: no dark tank rim may survive on either side.
    for y in range(TILE_SIZE):
        draw.point((0, y), fill=tile.getpixel((1, y)))
        draw.point((31, y), fill=tile.getpixel((30, y)))


def paint_vertical_connector(tile: Image.Image, tile_id: int) -> None:
    """Create vertically seamless ladder, rope and chain cells."""
    tile.paste((0, 0, 0, 0), (0, 0, TILE_SIZE, TILE_SIZE))
    draw = ImageDraw.Draw(tile)
    if tile_id == 37:
        draw.rectangle((8, 0, 11, 31), fill=(31, 22, 17, 255))
        draw.rectangle((9, 0, 10, 31), fill=(176, 111, 55, 255))
        draw.rectangle((20, 0, 23, 31), fill=(31, 22, 17, 255))
        draw.rectangle((21, 0, 22, 31), fill=(176, 111, 55, 255))
        for y in (3, 11, 19, 27):
            draw.rectangle((8, y, 23, y + 2), fill=(31, 22, 17, 255))
            draw.line((10, y + 1, 21, y + 1), fill=(194, 132, 63, 255), width=1)
    elif tile_id == 38:
        draw.rectangle((14, 0, 17, 31), fill=(28, 20, 15, 255))
        draw.rectangle((15, 0, 16, 31), fill=(178, 116, 59, 255))
        for y in range(3, 25, 8):
            draw.point((14, y), fill=(203, 143, 72, 255))
            draw.point((17, y + 4), fill=(203, 143, 72, 255))
    else:
        draw.line((15, 0, 16, 31), fill=(18, 22, 22, 255), width=2)
        for y in range(-2, 32, 6):
            draw.ellipse((12, y, 19, y + 7), outline=(112, 122, 118, 255), width=2)
        draw.rectangle((0, 0, 31, 0), fill=(0, 0, 0, 0))
        draw.rectangle((0, 31, 31, 31), fill=(0, 0, 0, 0))
        draw.line((15, 0, 16, 0), fill=(18, 22, 22, 255), width=2)
        draw.line((15, 31, 16, 31), fill=(18, 22, 22, 255), width=2)


def main() -> None:
    preview = Image.open(PREVIEW_SOURCE).convert("RGBA")
    alpha = Image.open(ALPHA_SOURCE).convert("RGBA")
    assert preview.size == alpha.size == (COLUMNS * TILE_SIZE, ROWS * TILE_SIZE)

    output = Image.new("RGBA", preview.size, (0, 0, 0, 0))
    for tile_id in range(COLUMNS * ROWS):
        x = (tile_id % COLUMNS) * TILE_SIZE
        y = (tile_id // COLUMNS) * TILE_SIZE
        box = (x, y, x + TILE_SIZE, y + TILE_SIZE)
        source = preview.crop(box) if tile_id in FULL_SOLID_IDS else alpha.crop(box)
        grid_mask = connected_grid_mask(source)
        cleaned = source.copy()
        cleaned_pixels = cleaned.load()

        for pixel_x, pixel_y in grid_mask:
            if tile_id in FULL_SOLID_IDS:
                replacement = nearest_clean_pixel(source, pixel_x, pixel_y, grid_mask)
                cleaned_pixels[pixel_x, pixel_y] = (*replacement[:3], 255)
            else:
                cleaned_pixels[pixel_x, pixel_y] = (0, 0, 0, 0)

        if tile_id in FULL_SOLID_IDS:
            for pixel_y in range(TILE_SIZE):
                for pixel_x in range(TILE_SIZE):
                    red, green, blue, _alpha = cleaned_pixels[pixel_x, pixel_y]
                    cleaned_pixels[pixel_x, pixel_y] = (red, green, blue, 255)

        if tile_id in ONE_WAY_IDS:
            paint_one_way_surface(cleaned)
        elif tile_id in VERTICAL_CONNECTOR_IDS:
            paint_vertical_connector(cleaned, tile_id)
        elif tile_id in TOP_GROUND_IDS or tile_id in SUBSURFACE_IDS:
            paint_seamless_ground(cleaned, tile_id)
        elif tile_id in SEAMLESS_WATER_IDS:
            paint_seamless_water(cleaned)

        output.alpha_composite(cleaned, (x, y))

    for tile_id in FULL_SOLID_IDS:
        x = (tile_id % COLUMNS) * TILE_SIZE
        y = (tile_id // COLUMNS) * TILE_SIZE
        alpha_extrema = output.getchannel("A").crop((x, y, x + TILE_SIZE, y + TILE_SIZE)).getextrema()
        assert alpha_extrema == (255, 255), f"solid tile {tile_id} is not edge-to-edge"

    for tile_id in ONE_WAY_IDS:
        x = (tile_id % COLUMNS) * TILE_SIZE
        y = (tile_id // COLUMNS) * TILE_SIZE
        surface = output.getchannel("A").crop((x, y + 15, x + TILE_SIZE, y + 24))
        assert surface.getextrema() == (255, 255), f"one-way tile {tile_id} has a seam"

    for tile_id in VERTICAL_CONNECTOR_IDS:
        x = (tile_id % COLUMNS) * TILE_SIZE
        y = (tile_id // COLUMNS) * TILE_SIZE
        top = output.getchannel("A").crop((x, y, x + TILE_SIZE, y + 1)).getbbox()
        bottom = output.getchannel("A").crop((x, y + 31, x + TILE_SIZE, y + 32)).getbbox()
        assert top and bottom, f"vertical connector {tile_id} does not join its neighbours"

    # Visual continuity contract: opacity alone is insufficient because a dark
    # painted outline is still perceived as an empty seam in Tiled.
    for tile_id in TOP_GROUND_IDS | SUBSURFACE_IDS | SEAMLESS_WATER_IDS:
        assert_opaque(output, tile_id, label="modular")
        assert_no_horizontal_frame(output, tile_id)
    for left_id, right_id in ((0, 1), (1, 0), (3, 4), (4, 3), (26, 26)):
        assert_horizontal_join(output, left_id, right_id)
    for top_id in TOP_GROUND_IDS:
        for bottom_id in SUBSURFACE_IDS:
            assert_vertical_join(output, top_id, bottom_id)
    for tile_id in VERTICAL_CONNECTOR_IDS:
        assert_vertical_join(output, tile_id, tile_id)
    for left_id, right_id in ((40, 41), (41, 41), (41, 42)):
        assert_horizontal_join(output, left_id, right_id, rows=range(15, 24))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    output.save(OUTPUT, optimize=True)
    print(OUTPUT)
    print(f"{len(FULL_SOLID_IDS)} solids, {len(ONE_WAY_IDS)} platforms and {len(VERTICAL_CONNECTOR_IDS)} vertical connectors validated")


if __name__ == "__main__":
    main()
