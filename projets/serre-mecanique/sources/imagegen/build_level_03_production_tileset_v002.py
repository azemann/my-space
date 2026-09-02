#!/usr/bin/env python3
"""Build level 3 from validated modular masks and the supplied isolated props."""

from __future__ import annotations

import colorsys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
GEOMETRY_SOURCE = ROOT / "assets" / "tilesets" / "serre-mecanique-32x32.png"
PROP_SOURCE = ROOT / "sources" / "imagegen" / "generated" / "serre-mecanique-tileset-32x32-alpha-v001.png"
OUTPUT = ROOT / "assets" / "tilesets" / "niveau-03-serre-mecanique-32x32-v002.png"

# These sprites stand alone and therefore need internal breathing room. Every
# other slot is modular and must preserve the proven level-1 alpha geometry.
ISOLATED_PROP_IDS = {
    52, 53, 54, 55, 56, 59, 60, 61, 62, 63,
    64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
}


def recolor(red: int, green: int, blue: int) -> tuple[int, int, int]:
    """Apply the supplied greenhouse palette without changing geometry."""
    hue, saturation, value = colorsys.rgb_to_hsv(red / 255, green / 255, blue / 255)

    if 0.45 <= hue <= 0.66 and saturation > 0.18:
        hue = 0.48
        saturation = min(0.78, saturation * 1.10 + 0.08)
        value = value * 0.78 + 0.05
    elif 0.17 <= hue < 0.45 and saturation > 0.16:
        hue = 0.22 if hue < 0.30 else 0.27
        saturation = min(0.82, saturation * 1.08 + 0.05)
        value = value * 0.72 + 0.03
    elif hue < 0.17 or hue > 0.94:
        hue = 0.085
        saturation = min(0.78, saturation * 0.92 + 0.12)
        value = value * 0.82
    elif saturation < 0.20:
        return (
            round(14 + value * 104),
            round(19 + value * 102),
            round(18 + value * 83),
        )
    else:
        value *= 0.78

    transformed = colorsys.hsv_to_rgb(hue, saturation, max(0.0, min(1.0, value)))
    return tuple(round(channel * 255) for channel in transformed)


def main() -> None:
    geometry = Image.open(GEOMETRY_SOURCE).convert("RGBA")
    props = Image.open(PROP_SOURCE).convert("RGBA")
    assert geometry.size == props.size == (512, 160)

    output = Image.new("RGBA", geometry.size)
    output.putdata([
        (*recolor(red, green, blue), alpha) if alpha else (0, 0, 0, 0)
        for red, green, blue, alpha in geometry.getdata()
    ])

    for tile_id in ISOLATED_PROP_IDS:
        x = (tile_id % 16) * 32
        y = (tile_id // 16) * 32
        box = (x, y, x + 32, y + 32)
        output.paste(props.crop(box), (x, y))

    geometry_alpha = geometry.getchannel("A")
    output_alpha = output.getchannel("A")
    for tile_id in set(range(80)) - ISOLATED_PROP_IDS:
        x = (tile_id % 16) * 32
        y = (tile_id // 16) * 32
        box = (x, y, x + 32, y + 32)
        assert geometry_alpha.crop(box).tobytes() == output_alpha.crop(box).tobytes()

    for tile_id in ISOLATED_PROP_IDS:
        x = (tile_id % 16) * 32
        y = (tile_id // 16) * 32
        box = (x, y, x + 32, y + 32)
        assert props.crop(box).tobytes() == output.crop(box).tobytes()

    output.save(OUTPUT, optimize=True)
    print(OUTPUT)
    print("54 modular masks preserved; 26 isolated props preserved")


if __name__ == "__main__":
    main()
