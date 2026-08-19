from __future__ import annotations

from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]


class ProjectLayoutTests(unittest.TestCase):
    def test_runtime_and_pipeline_have_separate_roots(self) -> None:
        required = [
            ROOT / "game",
            ROOT / "pipeline/assets/builders",
            ROOT / "pipeline/assets/player",
            ROOT / "pipeline/assets/sources",
            ROOT / "pipeline/tiled/tools",
            ROOT / "pipeline/tiled/maps/source",
            ROOT / "pipeline/tiled/maps/templates",
            ROOT / "pipeline/tiled/maps/tilesets",
            ROOT / "pipeline/tests",
        ]
        self.assertEqual([str(path.relative_to(ROOT)) for path in required if not path.is_dir()], [])
        self.assertEqual(
            [name for name in ("editor", "maps", "source-art") if (ROOT / name).exists()],
            [],
            "Les anciens dossiers dispersés ne doivent pas réapparaître à la racine",
        )

    def test_runtime_never_loads_an_art_source(self) -> None:
        forbidden = "res://pipeline/assets/sources/"
        offenders: list[str] = []
        for suffix in ("*.gd", "*.gdshader", "*.tscn", "*.tres"):
            for path in (ROOT / "game").rglob(suffix):
                if forbidden in path.read_text(encoding="utf-8"):
                    offenders.append(str(path.relative_to(ROOT)))
        self.assertEqual(offenders, [], "Le runtime charge une source de fabrication")

    def test_tiled_image_paths_resolve_after_the_move(self) -> None:
        missing: list[str] = []
        tileset_root = ROOT / "pipeline/tiled/maps/tilesets"
        for path in tileset_root.glob("*.tsx"):
            document = ET.parse(path).getroot()
            for image in document.iter("image"):
                target = (path.parent / image.attrib["source"]).resolve()
                if not target.is_file():
                    missing.append(f"{path.name}: {image.attrib['source']}")
        self.assertEqual(missing, [], "Images TSX introuvables depuis la nouvelle arborescence")


if __name__ == "__main__":
    unittest.main()
