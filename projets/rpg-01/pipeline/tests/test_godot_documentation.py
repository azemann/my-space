from __future__ import annotations

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
GAME_ROOT = ROOT / "game"

EXPORTED_PROPERTY = re.compile(r"^@export(?:_[a-z_]+)?(?:\([^)]*\))?\s+var\s+")
PUBLIC_FUNCTION = re.compile(r"^(?:static\s+)?func\s+(?!_)[a-zA-Z][a-zA-Z0-9_]*")
DOCUMENTED_API = re.compile(r"^(?:signal\s+|enum\s+)|^(?:static\s+)?func\s+(?!_)")


def previous_non_empty(lines: list[str], index: int) -> str:
    for candidate in reversed(lines[:index]):
        if candidate.strip():
            return candidate.strip()
    return ""


class GodotDocumentationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.scripts = sorted(GAME_ROOT.rglob("*.gd"))
        self.assertGreaterEqual(len(self.scripts), 25)

    def test_every_game_script_has_a_class_description(self) -> None:
        missing: list[str] = []
        for path in self.scripts:
            lines = path.read_text(encoding="utf-8").splitlines()
            extends_index = next((index for index, line in enumerate(lines) if line.startswith("extends ")), -1)
            description_window = lines[extends_index + 1 : extends_index + 7]
            if extends_index < 0 or not any(line.startswith("## ") for line in description_window):
                missing.append(str(path.relative_to(ROOT)))
        self.assertEqual(missing, [], "Scripts sans description de classe")

    def test_every_inspector_property_has_a_tooltip(self) -> None:
        missing: list[str] = []
        for path in self.scripts:
            lines = path.read_text(encoding="utf-8").splitlines()
            for index, line in enumerate(lines):
                if EXPORTED_PROPERTY.match(line) and not previous_non_empty(lines, index).startswith("##"):
                    missing.append(f"{path.relative_to(ROOT)}:{index + 1}")
        self.assertEqual(missing, [], "Propriétés d'Inspecteur sans infobulle")

    def test_every_public_script_api_has_a_description(self) -> None:
        missing: list[str] = []
        for path in self.scripts:
            lines = path.read_text(encoding="utf-8").splitlines()
            for index, line in enumerate(lines):
                if DOCUMENTED_API.match(line) and not previous_non_empty(lines, index).startswith("##"):
                    missing.append(f"{path.relative_to(ROOT)}:{index + 1}")
        self.assertEqual(missing, [], "Signaux, énumérations ou fonctions publiques sans description")

    def test_every_shader_and_uniform_has_a_description(self) -> None:
        missing: list[str] = []
        shaders = sorted(GAME_ROOT.rglob("*.gdshader"))
        self.assertGreaterEqual(len(shaders), 2)
        for path in shaders:
            lines = path.read_text(encoding="utf-8").splitlines()
            shader_type_index = next((index for index, line in enumerate(lines) if line.startswith("shader_type ")), -1)
            if shader_type_index < 0 or not previous_non_empty(lines, shader_type_index).startswith("//"):
                missing.append(f"{path.relative_to(ROOT)}:description")
            for index, line in enumerate(lines):
                if line.startswith("uniform ") and not previous_non_empty(lines, index).startswith("//"):
                    missing.append(f"{path.relative_to(ROOT)}:{index + 1}")
        self.assertEqual(missing, [], "Shaders ou paramètres uniform sans description")

    def test_every_tres_has_a_readable_resource_name(self) -> None:
        resources = sorted(
            path for path in ROOT.rglob("*.tres")
            if ".godot" not in path.parts
        )
        self.assertGreaterEqual(len(resources), 14)
        missing = [
            str(path.relative_to(ROOT))
            for path in resources
            if not re.search(r'^resource_name = ".+"$', path.read_text(encoding="utf-8"), re.MULTILINE)
        ]
        self.assertEqual(missing, [], "Ressources sans nom lisible")


if __name__ == "__main__":
    unittest.main()
