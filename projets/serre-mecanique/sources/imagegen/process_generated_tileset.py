#!/usr/bin/env python3
"""Normalize an ImageGen atlas and build non-destructive 32x32 candidates."""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent
MANIFEST_PATH = ROOT / "serre-mecanique-tileset-grid-16x5.json"


def remove_connected_dark_background(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    visited: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in visited:
            continue
        visited.add((x, y))
        red, green, blue, _alpha = pixels[x, y]
        # The generated backdrop is near-black green. Restrict removal to dark,
        # border-connected pixels so enclosed shadows inside assets survive.
        if max(red, green, blue) > 48 or red + green + blue > 108:
            continue
        pixels[x, y] = (red, green, blue, 0)
        if x > 0:
            queue.append((x - 1, y))
        if x + 1 < width:
            queue.append((x + 1, y))
        if y > 0:
            queue.append((x, y - 1))
        if y + 1 < height:
            queue.append((x, y + 1))

    return rgba


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("--version", default="v001")
    args = parser.parse_args()

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    canvas_width, canvas_height = manifest["canvas"]
    source = Image.open(args.source).convert("RGB")
    normalized = source.resize((canvas_width, canvas_height), Image.Resampling.LANCZOS)

    output_dir = ROOT / "generated"
    output_dir.mkdir(parents=True, exist_ok=True)
    normalized_path = output_dir / f"serre-mecanique-tileset-source-normalized-{args.version}.png"
    preview_path = output_dir / f"serre-mecanique-tileset-32x32-preview-{args.version}.png"
    alpha_path = output_dir / f"serre-mecanique-tileset-32x32-alpha-{args.version}.png"
    normalized.save(normalized_path)

    columns, rows = manifest["grid"]
    preview = Image.new("RGB", (columns * 32, rows * 32), "#10191a")
    alpha = Image.new("RGBA", (columns * 32, rows * 32), (0, 0, 0, 0))

    for cell in manifest["cells"]:
        left, top, right, bottom = cell["crop_box"]
        tile = normalized.crop((left, top, right, bottom))
        tile_preview = tile.resize((32, 32), Image.Resampling.LANCZOS)
        tile_alpha = remove_connected_dark_background(tile)
        tile_alpha = tile_alpha.resize((32, 32), Image.Resampling.LANCZOS)
        x = cell["column"] * 32
        y = cell["row"] * 32
        preview.paste(tile_preview, (x, y))
        alpha.alpha_composite(tile_alpha, (x, y))

    preview.save(preview_path)
    alpha.save(alpha_path)
    print(normalized_path)
    print(preview_path)
    print(alpha_path)


if __name__ == "__main__":
    main()
