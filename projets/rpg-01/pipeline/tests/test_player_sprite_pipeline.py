from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from hashlib import sha256

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = ROOT / "pipeline/assets/player/build_player_sheet.py"
SPEC = importlib.util.spec_from_file_location("build_player_sheet", MODULE_PATH)
assert SPEC and SPEC.loader
builder = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(builder)


class PlayerSpritePipelineTests(unittest.TestCase):
    def test_player_provenance_required_fields_and_hashes(self) -> None:
        path = ROOT / "pipeline/assets/sources/player/generation/provenance.json"
        receipt = json.loads(path.read_text(encoding="utf-8"))
        required = {"schemaVersion", "lotId", "status", "generatedAt", "tool", "pipeline", "assets", "transformations", "validation", "knownLimits"}
        self.assertTrue(required.issubset(receipt))
        self.assertEqual(receipt["schemaVersion"], "1.0.0")
        self.assertEqual(receipt["status"], "candidate")
        for asset in receipt["assets"]:
            asset_path = ROOT / asset["path"]
            self.assertTrue(asset_path.is_file(), asset["path"])
            actual = sha256(asset_path.read_bytes()).hexdigest()
            self.assertEqual(actual, asset["sha256"], asset["path"])

    def test_project_frames_match_the_player_contract(self) -> None:
        profile = json.loads((ROOT / "pipeline/assets/sources/player/player-sprite-profile.json").read_text(encoding="utf-8"))
        canvas = tuple(profile["source_canvas_px"])
        root = tuple(profile["source_root_px"])
        entries = builder.frame_paths(profile)
        self.assertEqual(len(entries), 24)
        heights = []
        bottoms = []
        for _, _, _, _, path in entries:
            bbox = builder.validate_frame(path, canvas, root)
            heights.append(bbox[3] - bbox[1])
            bottoms.append(bbox[3])
        self.assertGreaterEqual(min(heights), profile["target_visual_height_px"][0])
        self.assertLessEqual(max(heights), profile["target_visual_height_px"][1])
        self.assertLessEqual(max(abs(value - root[1]) for value in bottoms), 1)

    def test_fixed_canvas_build_preserves_root_and_order(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            temp = Path(temporary)
            frames = temp / "frames"
            profile = {
                "asset_id": "test.player", "source_canvas_px": [16, 16],
                "source_root_px": [8, 14], "directions": ["south", "north"],
                "animations": {
                    "idle": {"frame_count_per_direction": 1, "durations_ms": [300]},
                    "walk": {"frame_count_per_direction": 2, "durations_ms": [100, 120]},
                },
            }
            for animation, definition in profile["animations"].items():
                for direction in profile["directions"]:
                    folder = frames / animation / direction
                    folder.mkdir(parents=True)
                    for index in range(definition["frame_count_per_direction"]):
                        image = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
                        image.putpixel((7 + index, 13), (255, 0, 0, 255))
                        image.save(folder / f"frame-{index:02d}.png")
            profile_path = temp / "profile.json"
            profile_path.write_text(json.dumps(profile), encoding="utf-8")
            original_frames_root = builder.FRAMES_ROOT
            builder.FRAMES_ROOT = frames
            try:
                sheet_path, manifest_path = builder.build(profile_path, temp / "output")
            finally:
                builder.FRAMES_ROOT = original_frames_root
            with Image.open(sheet_path) as sheet:
                self.assertEqual(sheet.size, (32, 64))
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.assertEqual(manifest["root_px"], [8, 14])
            self.assertEqual([item["duration_ms"] for item in manifest["frames"]], [300, 300, 100, 120, 100, 120])
            self.assertTrue(all(item["root_px"] == [8, 14] for item in manifest["frames"]))

    def test_rejects_mismatched_canvas(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "bad.png"
            Image.new("RGBA", (15, 16), (255, 0, 0, 255)).save(path)
            with self.assertRaisesRegex(ValueError, "canvas incohérent"):
                builder.validate_frame(path, (16, 16), (8, 14))


if __name__ == "__main__":
    unittest.main()
