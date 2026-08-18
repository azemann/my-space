#!/usr/bin/env python3

import unittest
from pathlib import Path
import xml.etree.ElementTree as ET

from editor.tiled.map_contract import validate_map


ROOT = Path(__file__).resolve().parents[2]


class MapContractTests(unittest.TestCase):
    def test_valley_satisfies_future_map_contract(self) -> None:
        errors = validate_map(ROOT / "maps/source/vallee-des-sources.tmx")
        self.assertEqual(errors, [])

    def test_valley_visually_explains_paths_and_height_gates(self) -> None:
        root = ET.parse(ROOT / "maps/source/vallee-des-sources.tmx").getroot()
        width = int(root.get("width", "0"))
        layers = {layer.get("name"): layer for layer in root.findall(".//layer")}

        def cells(name: str) -> list[int]:
            return [int(value) for value in layers[name].find("data").text.split(",")]

        paths = cells("Paths")
        cliffs = cells("CliffFront")
        cliff_faces = cells("CliffFaces")
        at = lambda values, x, y: values[y * width + x]

        self.assertTrue(at(paths, 5, 20) and at(paths, 5, 21), "axe village trop étroit")
        self.assertTrue(at(paths, 11, 15) and at(paths, 12, 15), "axe nord-sud trop étroit")
        self.assertEqual(at(paths, 10, 29), 0, "un chemin ne doit pas traverser le flanc sud")
        self.assertTrue(at(paths, 9, 29) and at(paths, 11, 29))
        for x in (17, 18, 19):
            self.assertEqual(at(cliffs, x, 10), 0, "l'escalier nord doit rester visuellement ouvert")
        self.assertTrue(at(cliffs, 16, 10) and at(cliffs, 20, 10))
        for x in (6, 7, 8):
            self.assertEqual(at(cliffs, x, 34), 0, "l'escalier sud doit rester visuellement ouvert")
        self.assertGreaterEqual(sum(value != 0 for value in cliff_faces), 40)


if __name__ == "__main__":
    unittest.main()
