#!/usr/bin/env python3
"""Validate fixed-canvas player frames and build a deterministic Godot sheet."""

from __future__ import annotations

from argparse import ArgumentParser
from hashlib import sha256
from pathlib import Path
import json
import os
import tempfile

from PIL import Image


ROOT = Path(__file__).resolve().parents[3]
PROFILE_PATH = ROOT / "pipeline/assets/sources/player/player-sprite-profile.json"
FRAMES_ROOT = ROOT / "pipeline/assets/sources/player/frames"
OUTPUT_ROOT = ROOT / "game/actors/player/generated"


def digest(path: Path) -> str:
    return sha256(path.read_bytes()).hexdigest()


def recorded_path(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def frame_paths(profile: dict) -> list[tuple[str, str, int, int, Path]]:
    result = []
    for animation, definition in profile["animations"].items():
        count = int(definition["frame_count_per_direction"])
        durations = definition["durations_ms"]
        if len(durations) != count:
            raise ValueError(f"durées incohérentes pour {animation}")
        for direction in profile["directions"]:
            for index in range(count):
                path = FRAMES_ROOT / animation / direction / f"frame-{index:02d}.png"
                result.append((animation, direction, index, int(durations[index]), path))
    return result


def validate_frame(path: Path, canvas: tuple[int, int], root: tuple[int, int]) -> tuple[int, int, int, int]:
    if not path.is_file():
        raise FileNotFoundError(path)
    with Image.open(path) as image:
        if image.mode != "RGBA":
            raise ValueError(f"frame non RGBA : {path}")
        if image.size != canvas:
            raise ValueError(f"canvas incohérent : {path}={image.size}, attendu={canvas}")
        alpha = image.getchannel("A")
        bbox = alpha.getbbox()
        if bbox is None:
            raise ValueError(f"frame transparente : {path}")
        if not (0 <= root[0] < canvas[0] and 0 <= root[1] < canvas[1]):
            raise ValueError("root hors canvas")
        return bbox


def build(profile_path: Path = PROFILE_PATH, output_root: Path = OUTPUT_ROOT) -> tuple[Path, Path]:
    profile = json.loads(profile_path.read_text(encoding="utf-8"))
    canvas = tuple(map(int, profile["source_canvas_px"]))
    root = tuple(map(int, profile["source_root_px"]))
    records = []
    entries = frame_paths(profile)
    max_frames = max(int(item["frame_count_per_direction"]) for item in profile["animations"].values())
    rows = len(profile["animations"]) * len(profile["directions"])
    sheet = Image.new("RGBA", (canvas[0] * max_frames, canvas[1] * rows), (0, 0, 0, 0))
    row = 0
    previous_key = None
    for animation, direction, index, duration, path in entries:
        key = (animation, direction)
        if key != previous_key:
            if previous_key is not None:
                row += 1
            previous_key = key
        bbox = validate_frame(path, canvas, root)
        with Image.open(path) as frame:
            sheet.alpha_composite(frame, (index * canvas[0], row * canvas[1]))
        records.append({
            "animation": animation, "direction": direction, "index": index,
            "duration_ms": duration, "cell": [index, row], "source": recorded_path(path),
            "source_sha256": digest(path), "alpha_bbox_px": list(bbox), "root_px": list(root),
        })
    output_root.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".png", dir=output_root, delete=False) as temporary:
        temporary_path = Path(temporary.name)
    try:
        sheet.save(temporary_path)
        sheet_path = output_root / "player_sheet.png"
        os.replace(temporary_path, sheet_path)
    finally:
        temporary_path.unlink(missing_ok=True)
    manifest = {
        "schema_version": 1, "asset_id": profile["asset_id"],
        "placement_policy": "fixed_canvas_explicit_root", "canvas_px": list(canvas),
        "root_px": list(root), "sheet": {"image": "player_sheet.png", "size_px": list(sheet.size),
        "columns": max_frames, "sha256": digest(sheet_path)}, "frames": records,
    }
    manifest_path = output_root / "player_sheet.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return sheet_path, manifest_path


def main() -> int:
    parser = ArgumentParser()
    parser.add_argument("--profile", type=Path, default=PROFILE_PATH)
    parser.add_argument("--output", type=Path, default=OUTPUT_ROOT)
    args = parser.parse_args()
    sheet, manifest = build(args.profile.resolve(), args.output.resolve())
    print(sheet.relative_to(ROOT))
    print(manifest.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
