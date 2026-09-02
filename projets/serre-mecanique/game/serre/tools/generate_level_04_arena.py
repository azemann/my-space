#!/usr/bin/env python3
"""Generate the editable Tiled arena and TSX for level 4."""

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree as ET


TILE = 32
WIDTH = 50
HEIGHT = 24
ROOT = Path(__file__).resolve().parents[3]
MAP_PATH = ROOT / "maps" / "niveau-04-arene-parcours.tmx"
TSX_PATH = ROOT / "assets" / "tilesets" / "niveau-04-arene-combat-32x32-v001.tsx"
PNG_NAME = "niveau-04-arene-combat-32x32-v001.png"


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


def add_tile_definition(root, tile_id, kind, *, collision=None, props=None):
    tile = ET.SubElement(root, "tile", id=str(tile_id), type=kind)
    if props:
        properties(tile, props)
    if collision:
        x, y, width, height = collision
        group = ET.SubElement(tile, "objectgroup", draworder="index")
        ET.SubElement(
            group,
            "object",
            id="1",
            type=kind,
            x=str(x),
            y=str(y),
            width=str(width),
            height=str(height),
        )


def build_tsx():
    root = ET.Element(
        "tileset",
        version="1.10",
        tiledversion="1.12.2",
        name="niveau-04-arene-combat-32x32-v001",
        tilewidth="32",
        tileheight="32",
        tilecount="80",
        columns="16",
    )
    ET.SubElement(root, "image", source=PNG_NAME, width="512", height="160")

    solid_ids = (set(range(0, 12)) | set(range(13, 20)) | set(range(23, 26)) |
                 set(range(27, 32)) | {47, 64, 65, 68, 69})
    for tile_id in sorted(solid_ids):
        add_tile_definition(root, tile_id, "solid", collision=(0, 0, 32, 32), props={"destructible": tile_id < 12 or tile_id in {64, 65}})
    for tile_id in (40, 41, 42, 44):
        add_tile_definition(root, tile_id, "one_way", collision=(0, 16, 32, 8), props={"one_way_margin": 3.0})
    for tile_id in (37, 38, 39):
        add_tile_definition(root, tile_id, "climbable", collision=(8, 0, 16, 32))
    for tile_id in (12, 26, 57, 58, 63, 70, 71, 72):
        add_tile_definition(root, tile_id, "hazard", collision=(0, 10, 32, 22), props={"damage": 1})
    add_tile_definition(root, 79, "bounce", collision=(0, 22, 32, 10), props={"impulse_y": -620.0})

    ET.indent(root, space=" ")
    ET.ElementTree(root).write(TSX_PATH, encoding="utf-8", xml_declaration=True)


def empty_layer():
    return [0] * (WIDTH * HEIGHT)


def put(layer, x, y, tile_id):
    if 0 <= x < WIDTH and 0 <= y < HEIGHT:
        layer[y * WIDTH + x] = tile_id + 1


def fill(layer, x1, y1, x2, y2, tile_id):
    for y in range(y1, y2 + 1):
        for x in range(x1, x2 + 1):
            put(layer, x, y, tile_id)


def platform(layer, x1, x2, y):
    for x in range(x1, x2 + 1):
        put(layer, x, y, 40 if x == x1 else 42 if x == x2 else 41)


def csv_text(data):
    rows = [",".join(str(value) for value in data[y * WIDTH:(y + 1) * WIDTH]) for y in range(HEIGHT)]
    return "\n" + ",\n".join(rows) + "\n"


def tile_layer(root, layer_id, name, data, *, z_index, opacity=1.0, parallax=(1.0, 1.0)):
    layer = ET.SubElement(
        root, "layer", id=str(layer_id), name=name, width=str(WIDTH), height=str(HEIGHT),
        opacity=str(opacity), parallaxx=str(parallax[0]), parallaxy=str(parallax[1]),
    )
    properties(layer, {"z_index": z_index, "locked_after_blockout": False})
    ET.SubElement(layer, "data", encoding="csv").text = csv_text(data)


def object_group(root, layer_id, name, role, color, *, visible=True, z_index=0):
    group = ET.SubElement(
        root, "objectgroup", id=str(layer_id), name=name, color=color,
        draworder="topdown", visible="1" if visible else "0",
    )
    properties(group, {"godot_role": role, "z_index": z_index})
    return group


def rectangle(group, object_id, name, kind, x, y, width, height, props=None):
    obj = ET.SubElement(
        group, "object", id=str(object_id), name=name, type=kind,
        x=str(x), y=str(y), width=str(width), height=str(height),
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
    far = empty_layer()
    near = empty_layer()
    structures = empty_layer()
    terrain = empty_layer()
    platforms = empty_layer()
    gameplay = empty_layer()
    decoration = empty_layer()
    foreground = empty_layer()

    # Sparse industrial backdrop: it frames the arena without hiding players.
    for x in range(1, WIDTH - 1, 3):
        put(far, x, 3 + (x % 3), 16 + (x % 4))
    for x in (0, 10, 20, 29, 39, 49):
        for y in range(2, 21):
            put(near, x, y, 32 + ((x + y) % 5))
    for x in range(4, 46):
        put(structures, x, 2, 30 if x % 5 else 45)
    for x, y, tile_id in ((3, 6, 48), (8, 8, 49), (16, 5, 53), (25, 3, 56),
                          (33, 5, 53), (41, 8, 49), (46, 6, 48)):
        put(decoration, x, y, tile_id)

    # Three ground islands leave two lethal trenches and make lateral routes valuable.
    for x in list(range(0, 9)) + list(range(20, 30)) + list(range(41, 50)):
        put(terrain, x, 20, 0 if x % 3 else 1)
        fill(terrain, x, 21, x, 23, 3 if x % 2 else 4)
    for x in list(range(9, 20)) + list(range(30, 41)):
        put(gameplay, x, 22, 26)

    # Symmetric parkour: safe outer climb, fast middle route, risky crown.
    route = [
        (2, 7, 18), (7, 12, 16), (11, 16, 14), (15, 21, 12),
        (19, 24, 10), (22, 27, 8), (25, 30, 10),
        (28, 34, 12), (33, 38, 14), (37, 42, 16), (42, 47, 18),
        (17, 22, 18), (27, 32, 18), (21, 28, 15),
    ]
    for x1, x2, y in route:
        platform(platforms, x1, x2, y)

    # Two ladders, a rope and a chain create route changes during a fight.
    for y in range(14, 16):
        put(gameplay, 11, y, 37)
        put(gameplay, 38, y, 37)
    for y in range(8, 15):
        put(gameplay, 23, y, 38)
        put(gameplay, 26, y, 39)

    put(gameplay, 18, 19, 79)
    put(gameplay, 31, 19, 79)
    for x in (23, 24, 25, 26):
        put(gameplay, x, 19, 57 if x % 2 else 58)

    # Cover and future combat landmarks.
    for x, y, tile_id in ((4, 17, 64), (6, 17, 65), (14, 13, 68), (19, 9, 69),
                          (30, 9, 69), (35, 13, 68), (43, 17, 65), (45, 17, 64),
                          (21, 14, 70), (28, 14, 72)):
        put(gameplay, x, y, tile_id)
    for x, y, tile_id in ((3, 19, 50), (8, 15, 52), (16, 11, 54), (22, 7, 73),
                          (25, 7, 74), (27, 7, 75), (33, 11, 54), (41, 15, 52), (46, 19, 50)):
        put(decoration, x, y, tile_id)
    for x, tile_id in ((1, 77), (12, 78), (37, 78), (48, 77)):
        put(foreground, x, 4, tile_id)

    return far, near, structures, terrain, platforms, gameplay, decoration, foreground, route


def build_map():
    *layers, route = build_layers()
    root = ET.Element(
        "map", version="1.10", tiledversion="1.12.2", orientation="orthogonal",
        renderorder="right-down", width=str(WIDTH), height=str(HEIGHT),
        tilewidth=str(TILE), tileheight=str(TILE), infinite="0",
        backgroundcolor="#10191a", nextlayerid="30", nextobjectid="240",
    )
    properties(root, {
        "level_id": "serre-04-arena",
        "level_name": "L'arène des semences",
        "level_mode": "arena",
        "max_players": 4,
        "music": "serre_arena",
        "pixel_perfect": True,
        "template_version": 1,
    })
    ET.SubElement(root, "tileset", firstgid="1", source="../assets/tilesets/niveau-04-arene-combat-32x32-v001.tsx")

    layer_specs = [
        (1, "01 — Arrière-plan lointain", -30, 0.40, (0.35, 0.45)),
        (2, "02 — Arrière-plan proche", -20, 0.62, (0.70, 0.80)),
        (3, "03 — Structures", -10, 0.78, (0.90, 0.94)),
        (4, "04 — Terrain", 0, 1.0, (1.0, 1.0)),
        (5, "05 — Plateformes", 5, 1.0, (1.0, 1.0)),
        (6, "06 — Gameplay visible", 10, 1.0, (1.0, 1.0)),
        (7, "07 — Décoration", 20, 1.0, (1.0, 1.0)),
        (8, "08 — Premier plan", 30, 0.90, (1.08, 1.04)),
    ]
    for data, (layer_id, name, z_index, opacity, parallax) in zip(layers, layer_specs):
        tile_layer(root, layer_id, name, data, z_index=z_index, opacity=opacity, parallax=parallax)

    collisions = object_group(root, 10, "10 — Collisions", "collision", "#ff5c5c")
    rectangle(collisions, 1, "base_ouest", "solid", 0, 640, 9 * TILE, 128)
    rectangle(collisions, 2, "ile_centrale", "solid", 20 * TILE, 640, 10 * TILE, 128)
    rectangle(collisions, 3, "base_est", "solid", 41 * TILE, 640, 9 * TILE, 128)
    for object_id, (x1, x2, y) in enumerate(route, start=10):
        rectangle(collisions, object_id, f"plateforme_{object_id - 9:02d}", "one_way", x1 * TILE, y * TILE + 16, (x2 - x1 + 1) * TILE, 8, {"one_way_margin": 3.0})

    movements = object_group(root, 11, "11 — Mouvements", "gameplay", "#5ce1ff")
    rectangle(movements, 40, "echelle_ouest", "climbable", 11 * TILE + 8, 14 * TILE, 16, 2 * TILE)
    rectangle(movements, 41, "echelle_est", "climbable", 38 * TILE + 8, 14 * TILE, 16, 2 * TILE)
    rectangle(movements, 42, "corde_centrale", "climbable", 23 * TILE + 8, 8 * TILE, 16, 7 * TILE)
    rectangle(movements, 43, "chaine_centrale", "climbable", 26 * TILE + 8, 8 * TILE, 16, 7 * TILE)
    rectangle(movements, 44, "propulseur_ouest", "bounce", 18 * TILE, 19 * TILE, TILE, TILE, {"impulse_y": -650.0})
    rectangle(movements, 45, "propulseur_est", "bounce", 31 * TILE, 19 * TILE, TILE, TILE, {"impulse_y": -650.0})

    dangers = object_group(root, 12, "12 — Dangers", "gameplay", "#ff8a5c")
    rectangle(dangers, 50, "fosse_ouest", "death_zone", 9 * TILE, 21 * TILE, 11 * TILE, 3 * TILE, {"respawn": True})
    rectangle(dangers, 51, "fosse_est", "death_zone", 30 * TILE, 21 * TILE, 11 * TILE, 3 * TILE, {"respawn": True})
    rectangle(dangers, 52, "pics_centraux", "hazard", 23 * TILE, 19 * TILE + 10, 4 * TILE, 22, {"damage": 1, "respawn": True})
    rectangle(dangers, 53, "zone_mort", "death_zone", 0, 768, WIDTH * TILE, 64, {"respawn": True})

    entities = object_group(root, 13, "13 — Entités", "gameplay", "#65d6a6")
    point(entities, 60, "apparition_joueur_1", "player_spawn", 3 * TILE, 640, {"facing": "right", "player_slot": 1})
    for object_id, name, x, y, slot, facing in (
        (61, "apparition_joueur_2", 47, 20, 2, "left"),
        (62, "apparition_joueur_3", 16, 12, 3, "right"),
        (63, "apparition_joueur_4", 34, 12, 4, "left"),
    ):
        point(entities, object_id, name, "marker", x * TILE, y * TILE, {"tag": "arena_player_spawn", "player_slot": slot, "facing": facing})
    for object_id, x, y in ((70, 9, 16), (71, 19, 10), (72, 25, 8), (73, 30, 10), (74, 40, 16)):
        point(entities, object_id, f"arme_{object_id - 69:02d}", "marker", x * TILE + 16, y * TILE, {"tag": "weapon_spawn"})

    interactions = object_group(root, 14, "14 — Interactions", "gameplay", "#c58cff")
    rectangle(interactions, 80, "objectif_couronne", "trigger", 22 * TILE, 6 * TILE, 6 * TILE, 2 * TILE, {"event": "arena_crown_entered"})
    rectangle(interactions, 81, "caisse_ouest", "interactable", 4 * TILE, 17 * TILE, TILE, TILE, {"action": "open_weapon_crate"})
    rectangle(interactions, 82, "caisse_est", "interactable", 45 * TILE, 17 * TILE, TILE, TILE, {"action": "open_weapon_crate"})

    camera = object_group(root, 15, "15 — Caméra", "camera", "#ffd65c", visible=False)
    rectangle(camera, 90, "limites_camera", "camera_bounds", 0, 0, WIDTH * TILE, HEIGHT * TILE)
    rectangle(camera, 91, "focus_arene", "camera_focus", 10 * TILE, 4 * TILE, 30 * TILE, 17 * TILE, {"priority": 1, "zoom": 0.85})

    audio = object_group(root, 16, "16 — Audio", "audio", "#5cc8ff", visible=False)
    rectangle(audio, 100, "ambiance_arene", "audio_zone", 0, 0, WIDTH * TILE, HEIGHT * TILE, {"snapshot": "arena_industrial", "fade_time": 0.8})

    markers = object_group(root, 17, "17 — Repères et chemins", "object", "#ffffff", visible=False)
    point(markers, 110, "centre_arene", "marker", 25 * TILE, 7 * TILE, {"tag": "arena_center"})
    point(markers, 111, "camera_depart", "marker", 25 * TILE, 12 * TILE, {"tag": "arena_camera_start"})

    ET.indent(root, space=" ")
    ET.ElementTree(root).write(MAP_PATH, encoding="utf-8", xml_declaration=True)


def main():
    TSX_PATH.parent.mkdir(parents=True, exist_ok=True)
    MAP_PATH.parent.mkdir(parents=True, exist_ok=True)
    build_tsx()
    build_map()
    print(TSX_PATH)
    print(MAP_PATH)


if __name__ == "__main__":
    main()
