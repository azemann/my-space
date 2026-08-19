#!/usr/bin/env python3

import json
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "game/world/tileset/objects/naming_catalog.json"
ATLAS = ROOT / "game/world/tileset/objects/objects_atlas.png"
METADATA = ROOT / "game/world/tileset/objects/objects_catalog.json"
TERRAIN = ROOT / "game/world/tileset/terrain/terrain_atlas.png"
TILED_OBJECTS = ROOT / "pipeline/tiled/maps/tilesets/world_objects.tsx"
TILED_OBJECT_IMAGES = ROOT / "pipeline/tiled/maps/tilesets/objects"


class AssetCatalogTests(unittest.TestCase):
    def test_named_catalog_is_complete_and_unique(self) -> None:
        catalog = json.loads(CATALOG.read_text(encoding="utf-8"))["entries"]
        metadata = json.loads(METADATA.read_text(encoding="utf-8"))["sprites"]
        self.assertEqual(len(catalog), 71)
        self.assertEqual(len(metadata), 71)
        self.assertEqual(len({item["legacy_id"] for item in catalog}), 71)
        self.assertEqual(len({item["id"] for item in catalog}), 71)
        self.assertEqual({item["id"] for item in catalog}, {item["id"] for item in metadata})

    def test_groups_and_layers_are_explicit(self) -> None:
        entries = json.loads(CATALOG.read_text(encoding="utf-8"))["entries"]
        for entry in entries:
            self.assertIn("/", entry["group"], entry["id"])
            self.assertTrue(entry["layer"], entry["id"])
            self.assertTrue(entry["default_role"], entry["id"])

    def test_every_runtime_object_has_a_psychokinesis_profile(self) -> None:
        catalogs = [
            METADATA,
            ROOT / "game/world/tileset/beach/objects/beach_objects_catalog.json",
        ]
        valid_responses = {"anchored", "reactive", "movable"}
        valid_masses = {"light", "medium", "heavy", "immense"}
        for catalog_path in catalogs:
            for sprite in json.loads(catalog_path.read_text(encoding="utf-8"))["sprites"]:
                profile = sprite.get("psychokinesis", {})
                self.assertIn(profile.get("response"), valid_responses, sprite["id"])
                self.assertIn(profile.get("mass"), valid_masses, sprite["id"])
                self.assertTrue(profile.get("material"), sprite["id"])
                self.assertIsInstance(profile.get("breakable"), bool, sprite["id"])
                self.assertGreaterEqual(profile.get("required_power", -1), 0, sprite["id"])

    def test_every_beach_prop_is_immediately_movable(self) -> None:
        catalog_path = ROOT / "game/world/tileset/beach/objects/beach_objects_catalog.json"
        for sprite in json.loads(catalog_path.read_text(encoding="utf-8"))["sprites"]:
            profile = sprite["psychokinesis"]
            self.assertEqual(profile["response"], "movable", sprite["id"])
            self.assertEqual(profile["required_power"], 0, sprite["id"])

    def test_object_atlas_is_aligned_and_non_overlapping(self) -> None:
        with Image.open(ATLAS) as image:
            self.assertEqual(image.size, (2048, 2048))
            self.assertEqual(image.mode, "RGBA")
            self.assertEqual(image.getpixel((2047, 2047))[3], 0)
        sprites = json.loads(METADATA.read_text(encoding="utf-8"))["sprites"]
        occupied: set[tuple[int, int]] = set()
        for sprite in sprites:
            x, y = map(int, sprite["atlas_coordinates"])
            width, height = map(int, sprite["size_in_cells"])
            cells = {(cx, cy) for cy in range(y, y + height) for cx in range(x, x + width)}
            self.assertTrue(occupied.isdisjoint(cells), sprite["id"])
            occupied.update(cells)

    def test_terrain_atlas_uses_exact_32px_grid(self) -> None:
        with Image.open(TERRAIN) as image:
            self.assertEqual(image.size, (352, 352))
            self.assertEqual(image.width % 32, 0)
            self.assertEqual(image.height % 32, 0)

    def test_tiled_object_library_matches_godot_catalog(self) -> None:
        sprites = json.loads(METADATA.read_text(encoding="utf-8"))["sprites"]
        root = ET.parse(TILED_OBJECTS).getroot()
        tiles = root.findall("tile")
        self.assertEqual(root.get("objectalignment"), "bottom")
        self.assertEqual(len(tiles), len(sprites))
        self.assertEqual(len(list(TILED_OBJECT_IMAGES.glob("*.png"))), len(sprites))
        for tile, sprite in zip(tiles, sprites, strict=True):
            properties = {
                item.get("name"): item.get("value")
                for item in tile.findall("./properties/property")
            }
            self.assertEqual(properties["object_id"], sprite["id"])
            self.assertEqual(int(properties["godot_atlas_x"]), sprite["atlas_coordinates"][0])
            self.assertEqual(int(properties["godot_atlas_y"]), sprite["atlas_coordinates"][1])
            self.assertEqual(int(properties["foot_anchor_y"]), sprite["foot_anchor_px"][1])
            self.assertEqual(int(properties["content_offset_x"]), sprite["content_offset_px"][0])
            self.assertEqual(int(properties["content_offset_y"]), sprite["content_offset_px"][1])
            self.assertEqual(int(properties["content_width"]), sprite["content_size_px"][0])
            self.assertEqual(int(properties["content_height"]), sprite["content_size_px"][1])
            image_path = TILED_OBJECTS.parent / tile.find("image").get("source")
            with Image.open(image_path) as image:
                self.assertEqual(image.width, sprite["region_size_px"][0])
                self.assertEqual(image.height, sprite["foot_anchor_px"][1])

    def test_beach_objects_use_one_regular_sprite_sheet(self) -> None:
        catalog_path = ROOT / "game/world/tileset/beach/objects/beach_objects_catalog.json"
        atlas_path = ROOT / "game/world/tileset/beach/objects/beach_objects_atlas.png"
        tiled_path = ROOT / "pipeline/tiled/maps/tilesets/beach_objects.tsx"
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        root = ET.parse(tiled_path).getroot()
        image = root.find("image")
        self.assertEqual(catalog["layout"]["kind"], "uniform_grid")
        self.assertEqual(catalog["layout"]["cell_size_px"], [160, 96])
        self.assertEqual((root.get("columns"), root.get("tilecount")), ("6", "30"))
        self.assertIsNotNone(image)
        self.assertFalse(any(tile.find("image") is not None for tile in root.findall("tile")))
        for tile, sprite in zip(root.findall("tile"), catalog["sprites"], strict=True):
            properties = {
                item.get("name"): item.get("value")
                for item in tile.findall("./properties/property")
            }
            self.assertEqual(int(properties["foot_anchor_y"]), sprite["foot_anchor_px"][1])
            self.assertEqual(int(properties["content_offset_x"]), sprite["content_offset_px"][0])
            self.assertEqual(int(properties["content_offset_y"]), sprite["content_offset_px"][1])
            self.assertEqual(int(properties["content_width"]), sprite["content_size_px"][0])
            self.assertEqual(int(properties["content_height"]), sprite["content_size_px"][1])
        with Image.open(atlas_path) as atlas:
            self.assertEqual(atlas.size, (960, 480))
            self.assertEqual(atlas.mode, "RGBA")
            alpha = atlas.getchannel("A")
            for sprite in catalog["sprites"]:
                column, row = sprite["sheet_cell"]
                cell = alpha.crop((column * 160, row * 96, (column + 1) * 160, (row + 1) * 96))
                bounds = cell.getbbox()
                self.assertIsNotNone(bounds, sprite["id"])
                self.assertGreaterEqual(bounds[0], 5, sprite["id"])
                self.assertLessEqual(bounds[2], 155, sprite["id"])
                self.assertLessEqual(bounds[3], 91, sprite["id"])

    def test_beach_water_sequences_are_real_tiled_animations(self) -> None:
        catalog_path = ROOT / "game/world/tileset/beach/terrain/beach_terrain_catalog.json"
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        animated = {
            family["id"]: family
            for family in catalog["families"]
            if "tile_animation" in family
        }
        self.assertEqual(set(animated), {
            "14_beach_shallow_water", "15_beach_deep_water",
            "16_beach_shoreline", "17_beach_foam",
        })
        for family_id, family in animated.items():
            animation = family["tile_animation"]
            self.assertEqual(animation["frames"], 4)
            self.assertEqual(animation["direction"], [0, -1])
            texture_path = ROOT / family["texture"]
            with Image.open(texture_path) as texture:
                self.assertEqual(texture.size, (320, 128))
            tsx = ET.parse(ROOT / "pipeline/tiled/maps/tilesets" / f"{family_id}.tsx").getroot()
            for logical_id in animation["tiles"]:
                tile = tsx.find(f"tile[@id='{logical_id}']")
                self.assertIsNotNone(tile, family_id)
                frames = tile.findall("./animation/frame")
                self.assertEqual(len(frames), 4, family_id)
                self.assertEqual([int(frame.get("tileid")) for frame in frames], [
                    logical_id, logical_id + 10, logical_id + 20, logical_id + 30,
                ])


if __name__ == "__main__":
    unittest.main()
