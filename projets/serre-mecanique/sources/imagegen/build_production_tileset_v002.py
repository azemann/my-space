#!/usr/bin/env python3
"""Apply the approved ImageGen palette without changing production geometry."""

from __future__ import annotations

import colorsys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets" / "tilesets" / "serre-mecanique-32x32.png"
PROP_SOURCE = ROOT / "sources" / "imagegen" / "generated" / "serre-mecanique-tileset-32x32-alpha-v001.png"
OUTPUT = ROOT / "assets" / "tilesets" / "niveau-02-serre-mecanique-32x32-v002.png"
ISOLATED_PROP_IDS = {
    52, 53, 54, 55, 56, 59, 60, 61, 62, 63,
    64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
}


def recolor(red: int, green: int, blue: int) -> tuple[int, int, int]:
    hue, saturation, value = colorsys.rgb_to_hsv(red / 255, green / 255, blue / 255)

    # Turquoise glazing and liquids.
    if 0.45 <= hue <= 0.66 and saturation > 0.18:
        hue = 0.48
        saturation = min(0.78, saturation * 1.10 + 0.08)
        value = value * 0.78 + 0.05
    # Moss, leaves and roots: darker yellow-green like the ImageGen study.
    elif 0.17 <= hue < 0.45 and saturation > 0.16:
        hue = 0.22 if hue < 0.30 else 0.27
        saturation = min(0.82, saturation * 1.08 + 0.05)
        value = value * 0.72 + 0.03
    # Copper and brass accents.
    elif hue < 0.17 or hue > 0.94:
        hue = 0.085
        saturation = min(0.78, saturation * 0.92 + 0.12)
        value = value * 0.82
    # Stone and iron receive a subtle cold-green tint.
    elif saturation < 0.20:
        luminance = value
        return (
            round(14 + luminance * 104),
            round(19 + luminance * 102),
            round(18 + luminance * 83),
        )
    else:
        value *= 0.78

    transformed = colorsys.hsv_to_rgb(hue, saturation, max(0.0, min(1.0, value)))
    return tuple(round(channel * 255) for channel in transformed)


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    output = Image.new("RGBA", source.size)
    output.putdata([
        (*recolor(red, green, blue), alpha) if alpha else (0, 0, 0, 0)
        for red, green, blue, alpha in source.getdata()
    ])

    # ImageGen's isolated props are useful as-is: unlike terrain, platforms,
    # pipes, water, ladders and chains, they do not need to join a neighbour.
    prop_source = Image.open(PROP_SOURCE).convert("RGBA")
    for tile_id in ISOLATED_PROP_IDS:
        x = (tile_id % 16) * 32
        y = (tile_id // 16) * 32
        tile = prop_source.crop((x, y, x + 32, y + 32))
        output.paste(tile, (x, y))

    # Every modular cell keeps the level-1 alpha mask bit-for-bit. This proves
    # that no seam or unexpected empty pixel was introduced in playable tiles.
    for tile_id in set(range(80)) - ISOLATED_PROP_IDS:
        x = (tile_id % 16) * 32
        y = (tile_id // 16) * 32
        box = (x, y, x + 32, y + 32)
        assert source.getchannel("A").crop(box).tobytes() == output.getchannel("A").crop(box).tobytes()
    assert output.size == (512, 160)
    output.save(OUTPUT, optimize=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
