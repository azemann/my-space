#!/usr/bin/env python3
"""Generate the deterministic 4x4 ImageGen guide for Serre mécanique."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


WIDTH = 1536
HEIGHT = 1024
COLS = 4
ROWS = 4
CELL_WIDTH = WIDTH // COLS
CELL_HEIGHT = HEIGHT // ROWS
LINE_WIDTH = 6

BACKGROUND = "#10191a"
GRID = "#d19a4a"

ROOT = Path(__file__).resolve().parent
PNG_PATH = ROOT / "serre-mecanique-grid-template-4x4.png"
JSON_PATH = ROOT / "serre-mecanique-grid-template-4x4.json"

TILESET_WIDTH = 2048
TILESET_HEIGHT = 1024
TILESET_COLS = 16
TILESET_ROWS = 5
TILESET_CELL = 128
TILESET_GRID_TOP = (TILESET_HEIGHT - TILESET_ROWS * TILESET_CELL) // 2
TILESET_PNG_PATH = ROOT / "serre-mecanique-tileset-grid-16x5.png"
TILESET_JSON_PATH = ROOT / "serre-mecanique-tileset-grid-16x5.json"


def main() -> None:
    image = Image.new("RGB", (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(image)

    for column in range(COLS + 1):
        x = min(WIDTH - 1, column * CELL_WIDTH)
        draw.line((x, 0, x, HEIGHT - 1), fill=GRID, width=LINE_WIDTH)

    for row in range(ROWS + 1):
        y = min(HEIGHT - 1, row * CELL_HEIGHT)
        draw.line((0, y, WIDTH - 1, y), fill=GRID, width=LINE_WIDTH)

    image.save(PNG_PATH)

    cells = []
    for row in range(ROWS):
        for column in range(COLS):
            index = row * COLS + column
            cells.append(
                {
                    "id": f"{chr(65 + row)}{column + 1}",
                    "index": index,
                    "row": row,
                    "column": column,
                    "crop_box": [
                        column * CELL_WIDTH + LINE_WIDTH,
                        row * CELL_HEIGHT + LINE_WIDTH,
                        (column + 1) * CELL_WIDTH - LINE_WIDTH,
                        (row + 1) * CELL_HEIGHT - LINE_WIDTH,
                    ],
                }
            )

    manifest = {
        "schema": "serre-mecanique.imagegen-grid.v1",
        "canvas": [WIDTH, HEIGHT],
        "grid": [COLS, ROWS],
        "cell": [CELL_WIDTH, CELL_HEIGHT],
        "line_width": LINE_WIDTH,
        "background": BACKGROUND,
        "grid_color": GRID,
        "cells": cells,
    }
    JSON_PATH.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    tileset_image = Image.new("RGB", (TILESET_WIDTH, TILESET_HEIGHT), BACKGROUND)
    tileset_draw = ImageDraw.Draw(tileset_image)
    grid_bottom = TILESET_GRID_TOP + TILESET_ROWS * TILESET_CELL

    for column in range(TILESET_COLS + 1):
        x = min(TILESET_WIDTH - 1, column * TILESET_CELL)
        tileset_draw.line(
            (x, TILESET_GRID_TOP, x, grid_bottom), fill=GRID, width=LINE_WIDTH
        )

    for row in range(TILESET_ROWS + 1):
        y = TILESET_GRID_TOP + row * TILESET_CELL
        tileset_draw.line(
            (0, y, TILESET_WIDTH - 1, y), fill=GRID, width=LINE_WIDTH
        )

    tileset_image.save(TILESET_PNG_PATH)

    tileset_cells = []
    for row in range(TILESET_ROWS):
        for column in range(TILESET_COLS):
            index = row * TILESET_COLS + column
            tileset_cells.append(
                {
                    "id": f"T{index:02d}",
                    "index": index,
                    "row": row,
                    "column": column,
                    "crop_box": [
                        column * TILESET_CELL + LINE_WIDTH,
                        TILESET_GRID_TOP + row * TILESET_CELL + LINE_WIDTH,
                        (column + 1) * TILESET_CELL - LINE_WIDTH,
                        TILESET_GRID_TOP + (row + 1) * TILESET_CELL - LINE_WIDTH,
                    ],
                }
            )

    tileset_manifest = {
        "schema": "serre-mecanique.imagegen-tileset-grid.v1",
        "canvas": [TILESET_WIDTH, TILESET_HEIGHT],
        "grid_origin": [0, TILESET_GRID_TOP],
        "grid_size": [TILESET_WIDTH, TILESET_ROWS * TILESET_CELL],
        "grid": [TILESET_COLS, TILESET_ROWS],
        "cell": [TILESET_CELL, TILESET_CELL],
        "line_width": LINE_WIDTH,
        "background": BACKGROUND,
        "grid_color": GRID,
        "cells": tileset_cells,
    }
    TILESET_JSON_PATH.write_text(
        json.dumps(tileset_manifest, indent=2) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()
