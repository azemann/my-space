#!/usr/bin/env python3
"""Extract the generated 4x4 walk board with explicit, documented roots."""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path
import json
import shutil

import cv2
import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "source-art/player/generation/walk-board-rgba.png"
OUTPUT = ROOT / "source-art/player/frames"
RECEIPT = ROOT / "source-art/player/generation/walk-extraction.json"
DIRECTIONS = ["south", "west", "east", "north"]
SOURCE_ROOT_X = [196, 475, 769, 1045]
SOURCE_ROOT_Y = [315, 604, 899, 1190]
SOURCE_CANVAS = 320
SOURCE_ROOT_LOCAL = (160, 280)
TARGET_CANVAS = 64
TARGET_ROOT = (32, 56)
SCALED_CANVAS = 58
TARGET_TRANSLATION = (3, 5)


def file_hash(path: Path) -> str:
    return sha256(path.read_bytes()).hexdigest()


def main() -> int:
    image = Image.open(SOURCE).convert("RGBA")
    pixels = np.array(image)
    mask = (pixels[:, :, 3] >= 128).astype("uint8")
    count, labels, stats, _ = cv2.connectedComponentsWithStats(mask, 8)
    components = []
    for label in range(1, count):
        x, y, width, height, area = map(int, stats[label])
        if area >= 500:
            components.append((label, x, y, width, height, area))
    components.sort(key=lambda item: (item[2], item[1]))
    if len(components) != 16:
        raise ValueError(f"16 silhouettes attendues, {len(components)} trouvées")

    records = []
    for row, direction in enumerate(DIRECTIONS):
        folder = OUTPUT / "walk" / direction
        folder.mkdir(parents=True, exist_ok=True)
        for column in range(4):
            label, x, y, width, height, area = components[row * 4 + column]
            isolated = pixels.copy()
            isolated[:, :, 3] = np.where(labels == label, pixels[:, :, 3], 0)
            root_x = SOURCE_ROOT_X[column]
            root_y = SOURCE_ROOT_Y[row]
            left = root_x - SOURCE_ROOT_LOCAL[0]
            top = root_y - SOURCE_ROOT_LOCAL[1]
            right = left + SOURCE_CANVAS
            bottom = top + SOURCE_CANVAS
            if left < 0 or top < 0 or right > image.width or bottom > image.height:
                raise ValueError(f"canvas source hors planche pour {direction}/{column}")
            frame = Image.fromarray(isolated, "RGBA").crop((left, top, right, bottom))
            frame = frame.resize((SCALED_CANVAS, SCALED_CANVAS), Image.Resampling.NEAREST)
            normalized = Image.new("RGBA", (TARGET_CANVAS, TARGET_CANVAS), (0, 0, 0, 0))
            normalized.alpha_composite(frame, TARGET_TRANSLATION)
            frame = normalized
            target = folder / f"frame-{column:02d}.png"
            frame.save(target)
            records.append({
                "animation": "walk", "direction": direction, "index": column,
                "component_bbox_px": [x, y, width, height], "component_area_px": area,
                "source_root_px": [root_x, root_y], "source_crop_px": [left, top, SOURCE_CANVAS, SOURCE_CANVAS],
                "source_root_local_px": list(SOURCE_ROOT_LOCAL), "target_canvas_px": [TARGET_CANVAS, TARGET_CANVAS],
                "target_root_px": list(TARGET_ROOT), "scale": SCALED_CANVAS / SOURCE_CANVAS,
                "target_translation_px": list(TARGET_TRANSLATION),
                "translation_policy": "explicit_grid_root_not_bbox_center",
                "output": target.relative_to(ROOT).as_posix(), "sha256": file_hash(target),
            })

    # Initial idle is deliberately static: duplicate a validated authored view,
    # rather than inventing a fake breathing motion by shifting the silhouette.
    for direction in DIRECTIONS:
        idle_folder = OUTPUT / "idle" / direction
        idle_folder.mkdir(parents=True, exist_ok=True)
        source = OUTPUT / "walk" / direction / "frame-00.png"
        for index in range(2):
            shutil.copyfile(source, idle_folder / f"frame-{index:02d}.png")

    receipt = {
        "schema_version": 1, "asset_id": "player.hero.walk", "data_status": "measured",
        "source": SOURCE.relative_to(ROOT).as_posix(), "source_sha256": file_hash(SOURCE),
        "source_canvas_px": [SOURCE_CANVAS, SOURCE_CANVAS], "source_root_local_px": list(SOURCE_ROOT_LOCAL),
        "target_canvas_px": [TARGET_CANVAS, TARGET_CANVAS], "target_root_px": list(TARGET_ROOT),
        "uniform_scale": SCALED_CANVAS / SOURCE_CANVAS,
        "uniform_translation_px": list(TARGET_TRANSLATION), "per_frame_scaling": False,
        "bbox_recentering": False, "frames": records,
        "known_limits": ["idle frames are static duplicates pending a dedicated authored idle pass"],
    }
    RECEIPT.write_text(json.dumps(receipt, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Joueur : {len(records)} frames de marche extraites, root {TARGET_ROOT}, échelle uniforme {SCALED_CANVAS / SOURCE_CANVAS:.5f}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
