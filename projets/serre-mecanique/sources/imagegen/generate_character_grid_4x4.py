#!/usr/bin/env python3
"""Generate the fixed 4x4 character-animation grids and their manifest."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


COLS = 4
ROWS = 4
SOURCE_CELL = 256
RUNTIME_CELL = 64
SOURCE_SCALE = SOURCE_CELL // RUNTIME_CELL
SOURCE_SIZE = (COLS * SOURCE_CELL, ROWS * SOURCE_CELL)
RUNTIME_SIZE = (COLS * RUNTIME_CELL, ROWS * RUNTIME_CELL)
BACKGROUND = "#ff00ff"
GRID_COLOR = "#d19a4a"
CENTER_COLOR = "#57b8ad"
FOOT_COLOR = "#f2dc83"
SAFE_COLOR = "#8fd6a9"

RUNTIME_CENTER_X = 32
RUNTIME_FOOT_Y = 60
RUNTIME_SAFE_BOX = (8, 4, 56, 60)

ROOT = Path(__file__).resolve().parent
GUIDE_PATH = ROOT / "character-animation-grid-4x4-guide.png"
CLEAN_PATH = ROOT / "character-animation-grid-4x4-clean.png"
RUNTIME_PATH = ROOT / "character-animation-grid-4x4-runtime.png"
MANIFEST_PATH = ROOT / "character-animation-grid-4x4.json"


def scaled(value: int) -> int:
    return value * SOURCE_SCALE


def build_cells() -> list[dict]:
    cells = []
    for row in range(ROWS):
        for column in range(COLS):
            index = row * COLS + column
            source_x = column * SOURCE_CELL
            source_y = row * SOURCE_CELL
            runtime_x = column * RUNTIME_CELL
            runtime_y = row * RUNTIME_CELL
            cells.append(
                {
                    "id": f"{chr(65 + row)}{column + 1}",
                    "index": index,
                    "row": row,
                    "column": column,
                    "source_crop": [
                        source_x,
                        source_y,
                        source_x + SOURCE_CELL,
                        source_y + SOURCE_CELL,
                    ],
                    "runtime_region": [
                        runtime_x,
                        runtime_y,
                        RUNTIME_CELL,
                        RUNTIME_CELL,
                    ],
                    "pivot": [RUNTIME_CENTER_X, RUNTIME_FOOT_Y],
                    "safe_box": list(RUNTIME_SAFE_BOX),
                }
            )
    return cells


def main() -> None:
    clean = Image.new("RGB", SOURCE_SIZE, BACKGROUND)
    clean.save(CLEAN_PATH)

    guide = clean.copy()
    draw = ImageDraw.Draw(guide)
    line = 3
    for column in range(COLS + 1):
        x = min(SOURCE_SIZE[0] - 1, column * SOURCE_CELL)
        draw.line((x, 0, x, SOURCE_SIZE[1] - 1), fill=GRID_COLOR, width=line)
    for row in range(ROWS + 1):
        y = min(SOURCE_SIZE[1] - 1, row * SOURCE_CELL)
        draw.line((0, y, SOURCE_SIZE[0] - 1, y), fill=GRID_COLOR, width=line)

    for row in range(ROWS):
        for column in range(COLS):
            origin_x = column * SOURCE_CELL
            origin_y = row * SOURCE_CELL
            center_x = origin_x + scaled(RUNTIME_CENTER_X)
            foot_y = origin_y + scaled(RUNTIME_FOOT_Y)
            safe = (
                origin_x + scaled(RUNTIME_SAFE_BOX[0]),
                origin_y + scaled(RUNTIME_SAFE_BOX[1]),
                origin_x + scaled(RUNTIME_SAFE_BOX[2]),
                origin_y + scaled(RUNTIME_SAFE_BOX[3]),
            )
            draw.line(
                (center_x, origin_y + 4, center_x, origin_y + SOURCE_CELL - 5),
                fill=CENTER_COLOR,
                width=1,
            )
            draw.line(
                (origin_x + 4, foot_y, origin_x + SOURCE_CELL - 5, foot_y),
                fill=FOOT_COLOR,
                width=2,
            )
            draw.rectangle(safe, outline=SAFE_COLOR, width=2)
    guide.save(GUIDE_PATH)

    Image.new("RGBA", RUNTIME_SIZE, (0, 0, 0, 0)).save(RUNTIME_PATH)

    manifest = {
        "schema": "serre-mecanique.character-animation-grid.v1",
        "grid": [COLS, ROWS],
        "frame_count": COLS * ROWS,
        "source": {
            "canvas": list(SOURCE_SIZE),
            "cell": [SOURCE_CELL, SOURCE_CELL],
            "background": BACKGROUND,
            "scale_to_runtime": 1 / SOURCE_SCALE,
            "guide": GUIDE_PATH.name,
            "clean": CLEAN_PATH.name,
        },
        "runtime": {
            "canvas": list(RUNTIME_SIZE),
            "cell": [RUNTIME_CELL, RUNTIME_CELL],
            "transparent": True,
            "filter": "nearest",
            "sheet": RUNTIME_PATH.name,
        },
        "alignment": {
            "pivot": [RUNTIME_CENTER_X, RUNTIME_FOOT_Y],
            "foot_line_y": RUNTIME_FOOT_Y,
            "safe_box": list(RUNTIME_SAFE_BOX),
            "maximum_character_height": 56,
        },
        "cells": build_cells(),
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
