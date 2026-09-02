#!/usr/bin/env python3
"""Create the editable Tiled starter map for level 2."""

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree as ET


WIDTH = 50
HEIGHT = 24
ROOT = Path(__file__).resolve().parents[3]
OUTPUT = ROOT / "maps" / "gabarits" / "niveau-02-gabarit.tmx"


def properties(parent, values):
    node = ET.SubElement(parent, "properties")
    for name, value in values.items():
        attrs = {"name": name}
        if isinstance(value, bool):
            attrs.update(type="bool", value=str(value).lower())
        elif isinstance(value, int):
            attrs.update(type="int", value=str(value))
        elif isinstance(value, float):
            attrs.update(type="float", value=str(value))
        elif isinstance(value, str) and value.startswith("#"):
            attrs.update(type="color", value=value)
        else:
            attrs["value"] = str(value)
        ET.SubElement(node, "property", **attrs)


def empty_csv():
    row = ",".join("0" for _ in range(WIDTH))
    return "\n" + ",\n".join(row for _ in range(HEIGHT)) + "\n"


def tile_layer(root, layer_id, name, *, z_index, opacity=1.0, parallax=(1.0, 1.0)):
    layer = ET.SubElement(
        root,
        "layer",
        id=str(layer_id),
        name=name,
        width=str(WIDTH),
        height=str(HEIGHT),
        opacity=str(opacity),
        parallaxx=str(parallax[0]),
        parallaxy=str(parallax[1]),
    )
    properties(layer, {"z_index": z_index, "locked_after_blockout": False})
    ET.SubElement(layer, "data", encoding="csv").text = empty_csv()


def object_group(root, layer_id, name, role, color, *, visible=True, z_index=0):
    group = ET.SubElement(
        root,
        "objectgroup",
        id=str(layer_id),
        name=name,
        color=color,
        draworder="topdown",
        visible="1" if visible else "0",
    )
    properties(group, {"godot_role": role, "z_index": z_index})
    return group


def rectangle(group, object_id, name, kind, x, y, width, height, props=None, rotation=0):
    obj = ET.SubElement(
        group,
        "object",
        id=str(object_id),
        name=name,
        type=kind,
        x=str(x),
        y=str(y),
        width=str(width),
        height=str(height),
        rotation=str(rotation),
    )
    if props:
        properties(obj, props)
    return obj


def point(group, object_id, name, kind, x, y, props=None):
    obj = ET.SubElement(
        group,
        "object",
        id=str(object_id),
        name=name,
        type=kind,
        x=str(x),
        y=str(y),
    )
    ET.SubElement(obj, "point")
    if props:
        properties(obj, props)
    return obj


def polygon(group, object_id, name, kind, x, y, points, props=None):
    obj = ET.SubElement(
        group,
        "object",
        id=str(object_id),
        name=name,
        type=kind,
        x=str(x),
        y=str(y),
    )
    ET.SubElement(obj, "polygon", points=" ".join(f"{px},{py}" for px, py in points))
    if props:
        properties(obj, props)
    return obj


def polyline(group, object_id, name, kind, x, y, points, props=None):
    obj = ET.SubElement(
        group,
        "object",
        id=str(object_id),
        name=name,
        type=kind,
        x=str(x),
        y=str(y),
    )
    ET.SubElement(obj, "polyline", points=" ".join(f"{px},{py}" for px, py in points))
    if props:
        properties(obj, props)
    return obj


def ellipse(group, object_id, name, kind, x, y, width, height, props=None):
    obj = rectangle(group, object_id, name, kind, x, y, width, height, props)
    ET.SubElement(obj, "ellipse")
    return obj


def main():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    root = ET.Element(
        "map",
        version="1.10",
        tiledversion="1.12.2",
        orientation="orthogonal",
        renderorder="right-down",
        width=str(WIDTH),
        height=str(HEIGHT),
        tilewidth="32",
        tileheight="32",
        infinite="0",
        backgroundcolor="#10191a",
        nextlayerid="30",
        nextobjectid="200",
    )
    properties(
        root,
        {
            "level_id": "niveau-02-a-definir",
            "level_name": "Niveau 2 — à définir",
            "music": "",
            "pixel_perfect": True,
            "template_version": 1,
        },
    )
    ET.SubElement(
        root,
        "tileset",
        firstgid="1",
        source="../../assets/tilesets/niveau-02-serre-mecanique-32x32-v002.tsx",
    )

    tile_layer(root, 1, "01 — Arrière-plan lointain", z_index=-30, opacity=0.45, parallax=(0.35, 0.45))
    tile_layer(root, 2, "02 — Arrière-plan proche", z_index=-20, opacity=0.7, parallax=(0.7, 0.8))
    tile_layer(root, 3, "03 — Structures", z_index=-10)
    tile_layer(root, 4, "04 — Terrain", z_index=0)
    tile_layer(root, 5, "05 — Plateformes", z_index=5)
    tile_layer(root, 6, "06 — Gameplay visible", z_index=10)
    tile_layer(root, 7, "07 — Décoration", z_index=20)
    tile_layer(root, 8, "08 — Premier plan", z_index=30, parallax=(1.08, 1.04))

    collisions = object_group(root, 10, "10 — Collisions", "collision", "#ff5c5c")
    rectangle(collisions, 1, "exemple_solide", "solid", 64, 640, 192, 64)
    rectangle(collisions, 2, "exemple_sens_unique", "one_way", 320, 576, 192, 8, {"one_way_margin": 3.0})
    polygon(collisions, 3, "exemple_pente", "slope", 576, 640, [(0, 0), (160, -96), (160, 0)])
    polyline(collisions, 4, "exemple_mur_irregulier", "wall", 800, 544, [(0, 96), (48, 32), (96, 64), (144, 0)])
    ellipse(collisions, 5, "exemple_collision_ronde", "solid", 1024, 576, 64, 64)

    movements = object_group(root, 11, "11 — Mouvements", "gameplay", "#5ce1ff")
    rectangle(movements, 20, "exemple_echelle", "climbable", 128, 352, 32, 224)
    rectangle(movements, 21, "exemple_ressort", "bounce", 256, 608, 32, 32, {"impulse_y": -620.0})
    rectangle(movements, 22, "exemple_convoyeur", "conveyor", 384, 608, 160, 32, {"speed_x": 120.0})
    rectangle(movements, 23, "exemple_vent", "wind", 608, 416, 96, 192, {"force_x": 180.0, "force_y": -40.0})
    rectangle(movements, 24, "exemple_zone_lente", "slow_zone", 768, 576, 128, 64, {"speed_factor": 0.55})

    hazards = object_group(root, 12, "12 — Dangers", "gameplay", "#ff8a5c")
    rectangle(hazards, 30, "exemple_danger", "hazard", 960, 608, 96, 32, {"damage": 1, "respawn": True})
    rectangle(hazards, 31, "exemple_zone_mort", "death_zone", 0, 768, 1600, 64, {"respawn": True})

    entities = object_group(root, 13, "13 — Entités", "gameplay", "#65d6a6")
    point(entities, 40, "apparition_joueur", "player_spawn", 64, 608, {"facing": "right"})
    point(entities, 41, "exemple_checkpoint", "checkpoint", 480, 544, {"checkpoint_id": "cp_01", "spawn_offset_y": -24.0})
    point(entities, 42, "exemple_ennemi", "enemy_spawn", 736, 608, {"archetype": "a_definir"})
    point(entities, 43, "exemple_pnj", "npc_spawn", 864, 608, {"dialogue_id": "a_definir"})
    point(entities, 44, "exemple_collectible", "collectible", 1152, 512, {"value": 1})

    interactions = object_group(root, 14, "14 — Interactions", "gameplay", "#c58cff")
    rectangle(interactions, 50, "exemple_interaction", "interactable", 1056, 576, 32, 32, {"action": "a_definir", "target": "a_definir"})
    rectangle(interactions, 51, "exemple_declencheur", "trigger", 1216, 480, 128, 128, {"event": "a_definir"})
    rectangle(interactions, 52, "exemple_sortie", "exit", 1472, 544, 64, 96, {"next_level": "niveau-03-a-definir"})
    rectangle(interactions, 53, "exemple_transition", "transition", 1376, 352, 96, 160, {"target": "zone_a_definir"})

    camera = object_group(root, 15, "15 — Caméra", "camera", "#ffd65c", visible=False)
    rectangle(camera, 60, "limites_camera", "camera_bounds", 0, 0, 1600, 768)
    rectangle(camera, 61, "exemple_focus_camera", "camera_focus", 640, 256, 320, 256, {"priority": 1, "zoom": 1.0})

    audio = object_group(root, 16, "16 — Audio", "audio", "#5cc8ff", visible=False)
    rectangle(audio, 70, "ambiance_principale", "audio_zone", 0, 0, 1600, 768, {"snapshot": "a_definir", "fade_time": 0.8})

    markers = object_group(root, 17, "17 — Repères et chemins", "object", "#ffffff", visible=False)
    point(markers, 80, "repere_libre", "marker", 320, 320, {"tag": "a_definir"})
    polyline(markers, 81, "chemin_patrouille", "path", 448, 320, [(0, 0), (128, -64), (256, 0)], {"loop": True})

    ET.indent(root, space=" ")
    ET.ElementTree(root).write(OUTPUT, encoding="utf-8", xml_declaration=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
