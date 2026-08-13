#!/usr/bin/env python3
"""Convert approved ImageGen character sheets into exact Godot sprite sheets.

ImageGen respects the visual 4x4 arrangement but its silhouettes can cross the
mathematical 256 px cell boundaries. This processor detects the 16 independent
alpha components first, then normalizes them into 64x64 runtime cells.
"""

from __future__ import annotations

import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
PROCESSED = ROOT / "sources/imagegen/processed"
OUTPUT = ROOT / "assets/characters/player/animations"
QA_PATH = PROCESSED / "player-animation-runtime-qa.json"

SHEETS = {
    "idle": "player-idle-4x4-alpha-v001.png",
    "walk": "player-walk-4x4-alpha-v001.png",
    "jump": "player-jump-4x4-alpha-v001.png",
    "climb": "player-climb-4x4-alpha-v003.png",
    "grapple": "player-grapple-4x4-alpha-v001.png",
}

FRAME_SIZE = 64
FRAME_COUNT = 16
PIVOT = (32, 60)
SAFE_MAX_WIDTH = 60
SAFE_MAX_HEIGHT = 56
MIN_COMPONENT_AREA = 1000
ALPHA_THRESHOLD = 32


def detect_characters(image: Image.Image) -> list[dict]:
    alpha = np.asarray(image.getchannel("A"))
    mask = (alpha > ALPHA_THRESHOLD).astype(np.uint8)
    count, labels, stats, centroids = cv2.connectedComponentsWithStats(mask, 8)
    components = []
    for label in range(1, count):
        x, y, width, height, area = (int(value) for value in stats[label])
        if area < MIN_COMPONENT_AREA:
            continue
        components.append(
            {
                "label": label,
                "bbox": [x, y, width, height],
                "area": area,
                "centroid": [float(centroids[label][0]), float(centroids[label][1])],
                "mask": labels == label,
            }
        )
    if len(components) != FRAME_COUNT:
        raise RuntimeError(
            f"Expected {FRAME_COUNT} character components, found {len(components)}"
        )

    # ImageGen rows are visually ordered even when a silhouette crosses a cell
    # boundary. Grouping four successive vertical centroids preserves that order.
    components.sort(key=lambda item: item["centroid"][1])
    ordered = []
    for row_start in range(0, FRAME_COUNT, 4):
        row = components[row_start : row_start + 4]
        row.sort(key=lambda item: item["centroid"][0])
        ordered.extend(row)
    return ordered


def isolate_component(image: Image.Image, component: dict) -> Image.Image:
    x, y, width, height = component["bbox"]
    pixels = np.asarray(image).copy()
    alpha = pixels[:, :, 3]
    alpha[~component["mask"]] = 0
    pixels[:, :, 3] = alpha
    return Image.fromarray(pixels, "RGBA").crop((x, y, x + width, y + height))


def process_sheet(name: str, source_name: str) -> dict:
    source_path = PROCESSED / source_name
    image = Image.open(source_path).convert("RGBA")
    components = detect_characters(image)
    maximum_width = max(item["bbox"][2] for item in components)
    maximum_height = max(item["bbox"][3] for item in components)
    scale = min(SAFE_MAX_WIDTH / maximum_width, SAFE_MAX_HEIGHT / maximum_height)

    runtime = Image.new("RGBA", (FRAME_SIZE * 4, FRAME_SIZE * 4), (0, 0, 0, 0))
    frame_reports = []
    for index, component in enumerate(components):
        isolated = isolate_component(image, component)
        width = max(1, round(isolated.width * scale))
        height = max(1, round(isolated.height * scale))
        sprite = isolated.resize((width, height), Image.Resampling.NEAREST)
        x = PIVOT[0] - width // 2
        y = PIVOT[1] - height
        cell_x = (index % 4) * FRAME_SIZE
        cell_y = (index // 4) * FRAME_SIZE
        runtime.alpha_composite(sprite, (cell_x + x, cell_y + y))
        frame_reports.append(
            {
                "frame": index,
                "source_bbox": component["bbox"],
                "runtime_bbox": [x, y, width, height],
            }
        )

    OUTPUT.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT / f"{name}.png"
    runtime.save(output_path)
    return {
        "source": str(source_path.relative_to(ROOT)),
        "output": str(output_path.relative_to(ROOT)),
        "common_scale": round(scale, 6),
        "maximum_source_size": [maximum_width, maximum_height],
        "frames": frame_reports,
    }


def main() -> None:
    report = {
        "schema": "serre-mecanique.character-animation-runtime-qa.v1",
        "frame_size": [FRAME_SIZE, FRAME_SIZE],
        "pivot": list(PIVOT),
        "safe_maximum": [SAFE_MAX_WIDTH, SAFE_MAX_HEIGHT],
        "animations": {},
    }
    for name, source in SHEETS.items():
        report["animations"][name] = process_sheet(name, source)
    QA_PATH.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Processed {len(SHEETS)} sheets; QA: {QA_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
