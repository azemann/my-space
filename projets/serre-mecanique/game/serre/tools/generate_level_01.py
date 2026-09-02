#!/usr/bin/env python3
"""Build a polished 32x32 Tiled platform level for Serre mecanique."""

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree as ET


TILE = 32
WIDTH = 50
HEIGHT = 24
ROOT = Path(__file__).resolve().parents[3]
MAP_PATH = ROOT / "maps" / "niveau-01-serre.tmx"


def empty_layer():
    return [0] * (WIDTH * HEIGHT)


def put(layer, x, y, tile_id):
    if 0 <= x < WIDTH and 0 <= y < HEIGHT:
        layer[y * WIDTH + x] = tile_id + 1


def fill(layer, x1, y1, x2, y2, tile_id):
    for y in range(y1, y2 + 1):
        for x in range(x1, x2 + 1):
            put(layer, x, y, tile_id)


def platform(layer, x1, x2, y, family="moss"):
    ids = (9, 10, 11) if family == "moss" else (12, 13, 14)
    for x in range(x1, x2 + 1):
        put(layer, x, y, ids[0] if x == x1 else (ids[2] if x == x2 else ids[1]))


def csv_text(data):
    rows = []
    for y in range(HEIGHT):
        rows.append(",".join(str(v) for v in data[y * WIDTH : (y + 1) * WIDTH]))
    return "\n" + ",\n".join(rows) + "\n"


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
        else:
            attrs["value"] = str(value)
        ET.SubElement(node, "property", **attrs)


def tile_layer(root, layer_id, name, data, *, opacity=1.0, parallax=(1.0, 1.0)):
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
    ET.SubElement(layer, "data", encoding="csv").text = csv_text(data)
    return layer


def object_group(root, layer_id, name, *, color=None, visible=True):
    attrs = {
        "id": str(layer_id),
        "name": name,
        "draworder": "topdown",
        "visible": "1" if visible else "0",
    }
    if color:
        attrs["color"] = color
    return ET.SubElement(root, "objectgroup", **attrs)


def rect(group, object_id, name, kind, x, y, width, height, props=None):
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
    )
    if props:
        properties(obj, props)
    return obj


def point(group, object_id, name, kind, x, y, props=None):
    obj = ET.SubElement(group, "object", id=str(object_id), name=name, type=kind, x=str(x), y=str(y))
    ET.SubElement(obj, "point")
    if props:
        properties(obj, props)
    return obj


def build_layers():
    backdrop = empty_layer()
    structures = empty_layer()
    terrain = empty_layer()
    platforms = empty_layer()
    gameplay = empty_layer()
    foreground = empty_layer()

    # Greenhouse glazing: repeating panes framed by iron columns.
    for y in range(2, 14):
        for x in range(1, WIDTH - 1):
            put(backdrop, x, y, 32 + ((x + y) % 5))
    for x in range(0, WIDTH, 8):
        fill(structures, x, 1, x, 19, 28)
    for y in (1, 7, 13):
        fill(structures, 0, y, WIDTH - 1, y, 29)
    for x in (7, 23, 39):
        put(structures, x, 6, 30)
        put(structures, x + 1, 6, 31)

    # A readable copper irrigation route across the upper greenhouse.
    for x in range(2, 16):
        put(structures, x, 4, 38)
    put(structures, 16, 4, 40)
    for y in range(5, 10):
        put(structures, 16, y, 39)
    put(structures, 16, 10, 42)
    for x in range(17, 29):
        put(structures, x, 10, 38)
    put(structures, 23, 10, 44)
    put(structures, 28, 10, 45)

    # Main ground with a toxic irrigation pit in the middle-left.
    for x in list(range(0, 12)) + list(range(17, WIDTH)):
        put(terrain, x, 20, 1)
        fill(terrain, x, 21, x, 23, 0)
    fill(gameplay, 12, 20, 16, 20, 51)
    fill(gameplay, 12, 21, 16, 23, 50)

    # Platforming route: low bridge, rising garden beds, then the exit gantry.
    platform(platforms, 4, 9, 17, "moss")
    platform(platforms, 10, 18, 18, "metal")
    platform(platforms, 21, 26, 16, "moss")
    platform(platforms, 28, 34, 13, "metal")
    platform(platforms, 36, 41, 10, "moss")
    platform(platforms, 43, 48, 7, "metal")

    # Gameplay-readable props.
    put(gameplay, 19, 19, 52)  # spring plant
    for x in range(31, 34):
        put(gameplay, x, 19, 48)
    for y in range(14, 20):
        put(gameplay, 29, y, 57)
    for y in range(11, 16):
        put(gameplay, 40, y, 58)
    put(gameplay, 39, 19, 53)  # valve / lever
    put(gameplay, 47, 6, 55)   # exit door
    put(gameplay, 46, 6, 59)   # lamp

    # Foreground foliage and machinery, kept away from playable silhouettes.
    for x, tile_id in ((1, 67), (7, 68), (18, 72), (24, 73), (35, 74), (42, 75)):
        put(foreground, x, 19, tile_id)
    for x, tile_id in ((3, 76), (22, 77), (37, 78)):
        put(foreground, x, 19, tile_id)
    for x in (6, 14, 25, 33, 45):
        put(foreground, x, 14 if x < 20 else 9, 64 + (x % 4))

    return backdrop, structures, terrain, platforms, gameplay, foreground


def main():
    MAP_PATH.parent.mkdir(parents=True, exist_ok=True)
    backdrop, structures, terrain, platforms, gameplay, foreground = build_layers()

    root = ET.Element(
        "map",
        version="1.10",
        tiledversion="1.12.2",
        orientation="orthogonal",
        renderorder="right-down",
        width=str(WIDTH),
        height=str(HEIGHT),
        tilewidth=str(TILE),
        tileheight=str(TILE),
        infinite="0",
        backgroundcolor="#10191a",
        nextlayerid="10",
        nextobjectid="40",
    )
    properties(
        root,
        {
            "level_id": "serre-01",
            "level_name": "La galerie d'irrigation",
            "collision_source": "object-layer",
            "music": "serre_ambiante",
            "pixel_perfect": True,
        },
    )
    ET.SubElement(root, "tileset", firstgid="1", source="../assets/tilesets/serre-mecanique-32x32.tsx")

    tile_layer(root, 1, "Arrière-plan — verrière", backdrop, opacity=0.48, parallax=(0.65, 0.75))
    tile_layer(root, 2, "Structures — poutres et tuyaux", structures, opacity=0.72, parallax=(0.85, 0.9))
    tile_layer(root, 3, "Terrain solide", terrain)
    tile_layer(root, 4, "Plateformes", platforms)
    tile_layer(root, 5, "Gameplay visible", gameplay)
    tile_layer(root, 6, "Décoration avant", foreground)

    collisions = object_group(root, 7, "Collisions", color="#ff5c5c")
    properties(collisions, {"purpose": "physics", "grid_aligned": True})
    rect(collisions, 1, "sol_gauche", "solid", 0, 640, 384, 128)
    rect(collisions, 2, "sol_droit", "solid", 544, 640, 1056, 128)
    rect(collisions, 3, "plateforme_01", "one_way", 128, 544, 192, 8)
    rect(collisions, 4, "pont_fosse", "one_way", 320, 576, 288, 8)
    rect(collisions, 5, "jardin_suspendu", "one_way", 672, 512, 192, 8)
    rect(collisions, 6, "passerelle_cuivre", "one_way", 896, 416, 224, 8)
    rect(collisions, 7, "palier_lianes", "one_way", 1152, 320, 192, 8)
    rect(collisions, 8, "passerelle_sortie", "one_way", 1376, 224, 192, 8)
    rect(collisions, 9, "fosse_toxique", "hazard", 384, 648, 160, 120, {"damage": 100, "respawn": True})
    rect(collisions, 10, "pics", "hazard", 992, 616, 96, 24, {"damage": 1})
    rect(collisions, 11, "echelle", "climbable", 928, 448, 32, 192)
    rect(collisions, 12, "chaine", "climbable", 1280, 352, 32, 160)
    rect(collisions, 13, "ressort", "bounce", 608, 608, 32, 32, {"impulse_y": -620})

    entities = object_group(root, 8, "Entités et interactions", color="#5ce1ff")
    point(entities, 20, "apparition_joueur", "player_spawn", 64, 640, {"facing": "right"})
    point(entities, 21, "checkpoint_01", "checkpoint", 736, 512, {"checkpoint_id": "cp_irrigation"})
    rect(entities, 22, "levier_irrigation", "interactable", 1248, 608, 32, 32, {"action": "open_exit", "target": "sortie_serre"})
    rect(entities, 23, "sortie_serre", "exit", 1504, 192, 32, 32, {"requires": "open_exit", "next_level": "serre-02"})
    for object_id, x, y in ((24, 256, 512), (25, 800, 480), (26, 1056, 384), (27, 1248, 288), (28, 1440, 192)):
        point(entities, object_id, f"graine_{object_id - 23:02d}", "collectible", x, y, {"value": 1})

    zones = object_group(root, 9, "Zones", color="#ffd65c", visible=False)
    rect(zones, 30, "limites_camera", "camera_bounds", 0, 0, 1600, 768)
    rect(zones, 31, "zone_ambiance_verriere", "audio_zone", 0, 0, 1600, 640, {"snapshot": "greenhouse_hum"})
    rect(zones, 32, "zone_mort", "death_zone", 0, 768, 1600, 64, {"respawn": True})
    rect(zones, 33, "declencheur_sortie", "trigger", 1408, 192, 160, 96, {"event": "show_exit_hint"})

    ET.indent(root, space=" ")
    ET.ElementTree(root).write(MAP_PATH, encoding="utf-8", xml_declaration=True)
    print(MAP_PATH)


if __name__ == "__main__":
    main()
