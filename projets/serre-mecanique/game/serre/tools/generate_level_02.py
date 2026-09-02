#!/usr/bin/env python3
"""Build level 2 with the dedicated ImageGen greenhouse tileset."""

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree as ET


TILE = 32
WIDTH = 50
HEIGHT = 24
ROOT = Path(__file__).resolve().parents[3]
MAP_PATH = ROOT / "maps" / "niveau-02-racines.tmx"


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
        put(layer, x, y, ids[0] if x == x1 else ids[2] if x == x2 else ids[1])


def csv_text(data):
    rows = []
    for y in range(HEIGHT):
        rows.append(",".join(str(value) for value in data[y * WIDTH : (y + 1) * WIDTH]))
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
        elif isinstance(value, str) and value.startswith("#"):
            attrs.update(type="color", value=value)
        else:
            attrs["value"] = str(value)
        ET.SubElement(node, "property", **attrs)


def tile_layer(root, layer_id, name, data, *, z_index, opacity=1.0, parallax=(1.0, 1.0)):
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
    ET.SubElement(layer, "data", encoding="csv").text = csv_text(data)


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


def rectangle(group, object_id, name, kind, x, y, width, height, props=None):
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


def polyline(group, object_id, name, kind, x, y, points, props=None):
    obj = ET.SubElement(group, "object", id=str(object_id), name=name, type=kind, x=str(x), y=str(y))
    ET.SubElement(obj, "polyline", points=" ".join(f"{px},{py}" for px, py in points))
    if props:
        properties(obj, props)
    return obj


def build_layers():
    far_background = empty_layer()
    near_background = empty_layer()
    structures = empty_layer()
    terrain = empty_layer()
    platforms = empty_layer()
    gameplay = empty_layer()
    decoration = empty_layer()
    foreground = empty_layer()

    # A continuous glasshouse wall, varied enough to avoid a mechanical repeat.
    for y in range(2, 20):
        for x in range(1, WIDTH - 1):
            put(far_background, x, y, 32 + ((x * 3 + y * 5) % 5))
    for x in range(0, WIDTH, 7):
        fill(near_background, x, 1, x, 20, 28)
    for y in (1, 8, 15):
        fill(near_background, 0, y, WIDTH - 1, y, 29)
    for x in (6, 20, 34, 46):
        put(near_background, x, 7, 30)
        put(near_background, x + 1, 7, 31)

    # Copper irrigation circuit: readable landmark spanning the whole chamber.
    for x in range(2, 13):
        put(structures, x, 4, 38)
    put(structures, 13, 4, 40)
    for y in range(5, 10):
        put(structures, 13, y, 39)
    put(structures, 13, 10, 42)
    for x in range(14, 29):
        put(structures, x, 10, 38)
    put(structures, 21, 10, 44)
    put(structures, 29, 10, 41)
    for y in range(5, 10):
        put(structures, 29, y, 39)
    put(structures, 29, 4, 43)
    for x in range(30, 47):
        put(structures, x, 4, 38)
    put(structures, 36, 4, 45)

    # Ground is deliberately split by two toxic irrigation channels.
    for x in list(range(0, 9)) + list(range(14, 24)) + list(range(29, WIDTH)):
        put(terrain, x, 20, 1)
        fill(terrain, x, 21, x, 23, 0)
    for x in list(range(9, 14)) + list(range(24, 29)):
        put(gameplay, x, 20, 51)
        fill(gameplay, x, 21, x, 23, 50)

    # Main route: all ordinary upward steps are two tiles / 64 px or less.
    route = [
        (3, 7, 18, "moss"),
        (8, 12, 16, "metal"),
        (13, 17, 14, "moss"),
        (16, 21, 11, "metal"),
        (21, 25, 13, "moss"),
        (26, 30, 15, "metal"),
        (31, 35, 13, "moss"),
        (36, 41, 11, "metal"),
        (40, 44, 8, "moss"),
        (44, 47, 6, "metal"),
    ]
    for x1, x2, y, family in route:
        platform(platforms, x1, x2, y, family)

    # Visible gameplay objects aligned with their editable object zones.
    for y in range(11, 14):
        put(gameplay, 16, y, 57)
    for y in range(8, 11):
        put(gameplay, 40, y, 58)
    put(gameplay, 30, 19, 52)
    put(gameplay, 25, 19, 48)
    put(gameplay, 26, 19, 49)
    put(gameplay, 34, 12, 60)
    put(gameplay, 22, 12, 60)
    put(gameplay, 11, 15, 60)
    put(gameplay, 43, 7, 60)
    put(gameplay, 46, 5, 55)
    put(gameplay, 45, 5, 53)

    # Midground machines and plants leave every playable silhouette readable.
    for x, tile_id in ((2, 62), (7, 63), (15, 77), (20, 61), (32, 79), (38, 78), (48, 77)):
        put(decoration, x, 19, tile_id)
    for x, tile_id in ((5, 72), (18, 73), (23, 74), (35, 75), (42, 76), (47, 62)):
        put(decoration, x, 19 if x < 30 else 10, tile_id)

    for x, tile_id, y in ((1, 64, 3), (6, 65, 2), (18, 66, 3), (27, 67, 2), (37, 64, 3), (48, 65, 2)):
        put(foreground, x, y, tile_id)

    return far_background, near_background, structures, terrain, platforms, gameplay, decoration, foreground


def main():
    MAP_PATH.parent.mkdir(parents=True, exist_ok=True)
    layers = build_layers()
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
        nextlayerid="30",
        nextobjectid="200",
    )
    properties(
        root,
        {
            "level_id": "serre-02",
            "level_name": "La chambre des racines",
            "music": "serre_racines",
            "pixel_perfect": True,
            "template_version": 1,
        },
    )
    ET.SubElement(root, "tileset", firstgid="1", source="../assets/tilesets/niveau-02-serre-mecanique-32x32-v002.tsx")

    names = [
        (1, "01 — Arrière-plan lointain", -30, 0.40, (0.35, 0.45)),
        (2, "02 — Arrière-plan proche", -20, 0.66, (0.70, 0.80)),
        (3, "03 — Structures", -10, 0.82, (0.90, 0.94)),
        (4, "04 — Terrain", 0, 1.0, (1.0, 1.0)),
        (5, "05 — Plateformes", 5, 1.0, (1.0, 1.0)),
        (6, "06 — Gameplay visible", 10, 1.0, (1.0, 1.0)),
        (7, "07 — Décoration", 20, 1.0, (1.0, 1.0)),
        (8, "08 — Premier plan", 30, 0.92, (1.08, 1.04)),
    ]
    for data, (layer_id, name, z_index, opacity, parallax) in zip(layers, names):
        tile_layer(root, layer_id, name, data, z_index=z_index, opacity=opacity, parallax=parallax)

    collisions = object_group(root, 10, "10 — Collisions", "collision", "#ff5c5c")
    rectangle(collisions, 1, "sol_depart", "solid", 0, 640, 288, 128)
    rectangle(collisions, 2, "sol_central", "solid", 448, 640, 320, 128)
    rectangle(collisions, 3, "sol_sortie", "solid", 928, 640, 672, 128)
    for object_id, (x1, x2, y, _family) in enumerate(
        [(3, 7, 18, "moss"), (8, 12, 16, "metal"), (13, 17, 14, "moss"),
         (16, 21, 11, "metal"), (21, 25, 13, "moss"), (26, 30, 15, "metal"),
         (31, 35, 13, "moss"), (36, 41, 11, "metal"), (40, 44, 8, "moss"),
         (44, 47, 6, "metal")],
        start=10,
    ):
        rectangle(collisions, object_id, f"palier_{object_id - 9:02d}", "one_way", x1 * TILE, y * TILE, (x2 - x1 + 1) * TILE, 8, {"one_way_margin": 3.0})

    movements = object_group(root, 11, "11 — Mouvements", "gameplay", "#5ce1ff")
    rectangle(movements, 30, "echelle_cuve", "climbable", 16 * TILE, 11 * TILE, TILE, 3 * TILE)
    rectangle(movements, 31, "chaine_palan", "climbable", 40 * TILE, 8 * TILE, TILE, 3 * TILE)
    rectangle(movements, 32, "ressort_secours", "bounce", 30 * TILE, 19 * TILE, TILE, TILE, {"impulse_y": -620.0})

    dangers = object_group(root, 12, "12 — Dangers", "gameplay", "#ff8a5c")
    rectangle(dangers, 40, "canal_toxique_ouest", "hazard", 9 * TILE, 648, 5 * TILE, 120, {"damage": 1, "respawn": True})
    rectangle(dangers, 41, "canal_toxique_est", "hazard", 24 * TILE, 648, 5 * TILE, 120, {"damage": 1, "respawn": True})
    rectangle(dangers, 42, "pics_station_pompage", "hazard", 25 * TILE, 616, 2 * TILE, 24, {"damage": 1, "respawn": True})
    rectangle(dangers, 43, "zone_mort", "death_zone", 0, 768, 1600, 64, {"respawn": True})

    entities = object_group(root, 13, "13 — Entités", "gameplay", "#65d6a6")
    point(entities, 50, "apparition_joueur", "player_spawn", 64, 640, {"facing": "right"})
    point(entities, 51, "checkpoint_pompe", "checkpoint", 29 * TILE, 640, {"checkpoint_id": "cp_pompe", "spawn_offset_y": -24.0})
    for object_id, x, y in ((60, 11, 15), (61, 22, 12), (62, 34, 12), (63, 43, 7)):
        point(entities, object_id, f"capsule_{object_id - 59:02d}", "collectible", x * TILE + 16, y * TILE, {"value": 1})

    interactions = object_group(root, 14, "14 — Interactions", "gameplay", "#c58cff")
    rectangle(interactions, 70, "levier_sortie", "interactable", 45 * TILE, 5 * TILE, TILE, TILE, {"action": "open_exit", "target": "porte_sortie"})
    rectangle(interactions, 71, "porte_sortie", "exit", 46 * TILE, 5 * TILE, TILE, TILE, {"requires": "open_exit", "next_level": "niveau-03-a-definir"})
    rectangle(interactions, 72, "message_echelle", "trigger", 14 * TILE, 13 * TILE, 3 * TILE, 2 * TILE, {"event": "indice_echelle"})

    camera = object_group(root, 15, "15 — Caméra", "camera", "#ffd65c", visible=False)
    rectangle(camera, 80, "limites_camera", "camera_bounds", 0, 0, 1600, 768)
    rectangle(camera, 81, "focus_palan", "camera_focus", 36 * TILE, 6 * TILE, 10 * TILE, 7 * TILE, {"priority": 1, "zoom": 0.95})

    audio = object_group(root, 16, "16 — Audio", "audio", "#5cc8ff", visible=False)
    rectangle(audio, 90, "ambiance_racines", "audio_zone", 0, 0, 30 * TILE, 768, {"snapshot": "roots_hum", "fade_time": 0.8})
    rectangle(audio, 91, "ambiance_palan", "audio_zone", 30 * TILE, 0, 20 * TILE, 768, {"snapshot": "chain_room", "fade_time": 0.8})

    markers = object_group(root, 17, "17 — Repères et chemins", "object", "#ffffff", visible=False)
    point(markers, 100, "repere_pompe", "marker", 30 * TILE, 18 * TILE, {"tag": "pump_room"})
    polyline(markers, 101, "chemin_patrouille", "path", 31 * TILE, 13 * TILE, [(0, 0), (4 * TILE, 0), (5 * TILE, -2 * TILE)], {"loop": True})

    ET.indent(root, space=" ")
    ET.ElementTree(root).write(MAP_PATH, encoding="utf-8", xml_declaration=True)
    print(MAP_PATH)


if __name__ == "__main__":
    main()
