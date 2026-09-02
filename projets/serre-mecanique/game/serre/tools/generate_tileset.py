#!/usr/bin/env python3
"""Generate the deterministic 32x32 Serre mecanique tileset and Tiled files."""

from __future__ import annotations

import json
import random
from pathlib import Path
from xml.etree import ElementTree as ET

from PIL import Image, ImageDraw


TILE = 32
COLS = 16
ROWS = 5
ROOT = Path(__file__).resolve().parents[3]
TILESET_DIR = ROOT / "assets" / "tilesets"
MAP_DIR = ROOT / "maps" / "examples"
PNG_PATH = TILESET_DIR / "serre-mecanique-32x32.png"
TSX_PATH = TILESET_DIR / "serre-mecanique-32x32.tsx"
MAP_PATH = MAP_DIR / "serre-mecanique-demo.tmj"

P = {
    "ink": "#10191a",
    "deep": "#182423",
    "soil": "#403b2d",
    "soil_hi": "#5c5338",
    "stone": "#59605a",
    "stone_hi": "#7a8178",
    "stone_lo": "#353c39",
    "iron": "#30383a",
    "iron_hi": "#667174",
    "iron_lo": "#20282a",
    "copper": "#a76c3c",
    "brass": "#d19a4a",
    "verdigris": "#2e8078",
    "glass": "#398f91",
    "glass_hi": "#79d0c5",
    "water": "#3eb7b2",
    "water_hi": "#8ce5d3",
    "moss": "#799c32",
    "moss_hi": "#b5c94a",
    "leaf": "#447c31",
    "leaf_hi": "#7fb545",
    "thorn": "#8cab3c",
    "flower": "#b84f66",
}


def box(draw: ImageDraw.ImageDraw, xy, fill, outline=None):
    draw.rectangle(xy, fill=fill, outline=outline)


def line(draw: ImageDraw.ImageDraw, xy, fill, width=1):
    draw.line(xy, fill=fill, width=width)


def stone_fill(draw: ImageDraw.ImageDraw, seed: int, moss_top: bool = False):
    rng = random.Random(seed)
    box(draw, (0, 0, 31, 31), P["soil"])
    for y in range(-3, 32, 8):
        offset = 0 if (y // 8) % 2 == 0 else 5
        for x in range(-offset, 32, 11):
            x2 = min(31, x + 9 + rng.randrange(0, 3))
            y2 = min(31, y + 6 + rng.randrange(0, 2))
            box(draw, (max(0, x), max(0, y), x2, y2), P["stone_lo"], P["ink"])
            if y >= 0:
                line(draw, (max(0, x + 1), y + 1, x2 - 1, y + 1), P["stone"], 1)
    if moss_top:
        box(draw, (0, 0, 31, 3), P["moss"])
        line(draw, (0, 0, 31, 0), P["moss_hi"], 1)
        for x in (3, 9, 18, 25, 29):
            h = 2 + rng.randrange(0, 5)
            box(draw, (x, 3, x + 1, 3 + h), P["leaf"])


def metal_frame(draw: ImageDraw.ImageDraw, glass=True, cracked=False):
    if glass:
        box(draw, (2, 2, 29, 29), P["glass"])
        box(draw, (5, 5, 26, 26), "#1f595c")
        line(draw, (6, 7, 24, 25), P["glass_hi"], 1)
    box(draw, (0, 0, 31, 3), P["iron"], P["ink"])
    box(draw, (0, 28, 31, 31), P["iron"], P["ink"])
    box(draw, (0, 0, 3, 31), P["iron"], P["ink"])
    box(draw, (28, 0, 31, 31), P["iron"], P["ink"])
    for x, y in ((2, 2), (29, 2), (2, 29), (29, 29)):
        draw.point((x, y), fill=P["brass"])
    if cracked:
        line(draw, (18, 3, 16, 11, 20, 15, 14, 22, 16, 28), P["glass_hi"], 1)


def pipe(draw: ImageDraw.ImageDraw, segments):
    for x1, y1, x2, y2 in segments:
        line(draw, (x1, y1, x2, y2), P["ink"], 9)
        line(draw, (x1, y1, x2, y2), P["copper"], 7)
        line(draw, (x1, y1, x2, y2), P["verdigris"], 3)
    for x, y in ((16, 16),):
        box(draw, (x - 5, y - 5, x + 5, y + 5), P["copper"], P["ink"])


def draw_tile(tile_id: int, draw: ImageDraw.ImageDraw):
    row, col = divmod(tile_id, COLS)

    if row == 0:
        stone_fill(draw, tile_id, moss_top=col in {1, 5, 6, 9, 10, 11, 12, 13, 14})
        if col == 2:
            box(draw, (0, 0, 2, 31), P["ink"])
            line(draw, (3, 0, 3, 31), P["stone_hi"])
        elif col == 3:
            box(draw, (29, 0, 31, 31), P["ink"])
            line(draw, (28, 0, 28, 31), P["stone_hi"])
        elif col == 4:
            box(draw, (0, 29, 31, 31), P["ink"])
            line(draw, (0, 28, 31, 28), P["stone_hi"])
        elif col == 5:
            box(draw, (0, 0, 2, 31), P["ink"])
            line(draw, (3, 3, 3, 31), P["stone_hi"])
        elif col == 6:
            box(draw, (29, 0, 31, 31), P["ink"])
            line(draw, (28, 3, 28, 31), P["stone_hi"])
        elif col == 7:
            box(draw, (0, 0, 2, 31), P["ink"])
            box(draw, (0, 29, 31, 31), P["ink"])
        elif col == 8:
            box(draw, (29, 0, 31, 31), P["ink"])
            box(draw, (0, 29, 31, 31), P["ink"])
        elif col in {9, 10, 11}:
            draw.rectangle((0, 7, 31, 31), fill=(0, 0, 0, 0))
            left, right = 0, 31
            box(draw, (left, 2, right, 7), P["stone_lo"], P["ink"])
            box(draw, (left, 0, right, 2), P["moss"])
            line(draw, (left, 0, right, 0), P["moss_hi"])
            if col == 9:
                box(draw, (0, 0, 2, 7), P["ink"])
            elif col == 11:
                box(draw, (29, 0, 31, 7), P["ink"])
        elif col in {12, 13, 14}:
            draw.rectangle((0, 8, 31, 31), fill=(0, 0, 0, 0))
            left, right = 0, 31
            box(draw, (left, 2, right, 7), P["iron"], P["ink"])
            line(draw, (left, 2, right, 2), P["brass"], 1)
            for x in range(3, right, 8):
                draw.point((x, 5), fill=P["iron_hi"])
            if col == 12:
                box(draw, (0, 0, 2, 7), P["ink"])
            elif col == 14:
                box(draw, (29, 0, 31, 7), P["ink"])
        elif col == 15:
            box(draw, (0, 0, 31, 31), P["soil"], P["ink"])
            for x, y in ((5, 7), (18, 5), (11, 20), (24, 17), (27, 27)):
                box(draw, (x, y, x + 2, y + 1), P["soil_hi"])

    elif row == 1:
        if col <= 5:
            box(draw, (0, 0, 31, 31), P["stone"], P["ink"])
            for y in range(0, 32, 8):
                offset = 5 if (y // 8 + col) % 2 else 0
                line(draw, (0, y, 31, y), P["ink"])
                for x in range(offset, 32, 11):
                    line(draw, (x, y, x, min(31, y + 7)), P["stone_lo"])
            if col in {1, 3, 5}:
                box(draw, (0, 0, 31, 3), P["moss"])
        elif col <= 11:
            box(draw, (0, 0, 31, 31), P["iron"], P["ink"])
            box(draw, (3, 3, 28, 28), P["iron_lo"], P["iron_hi"])
            if col == 7:
                line(draw, (4, 4, 27, 27), P["iron_hi"], 3)
                line(draw, (27, 4, 4, 27), P["iron_hi"], 3)
            elif col == 8:
                for x in range(6, 29, 6):
                    box(draw, (x, 3, x + 2, 28), P["iron_hi"])
            elif col == 9:
                line(draw, (3, 27, 28, 3), P["iron_hi"], 4)
            elif col == 10:
                box(draw, (0, 0, 6, 31), P["iron_hi"], P["ink"])
            elif col == 11:
                box(draw, (25, 0, 31, 31), P["iron_hi"], P["ink"])
            for x, y in ((4, 4), (27, 4), (4, 27), (27, 27)):
                draw.point((x, y), fill=P["brass"])
        elif col == 12:
            box(draw, (13, 0, 19, 31), P["iron_hi"], P["ink"])
        elif col == 13:
            box(draw, (0, 13, 31, 19), P["iron_hi"], P["ink"])
        elif col == 14:
            line(draw, (1, 30, 30, 1), P["ink"], 7)
            line(draw, (1, 30, 30, 1), P["iron_hi"], 3)
        else:
            line(draw, (1, 1, 30, 30), P["ink"], 7)
            line(draw, (1, 1, 30, 30), P["iron_hi"], 3)

    elif row == 2:
        if col == 0:
            metal_frame(draw)
        elif col == 1:
            metal_frame(draw, cracked=True)
        elif col == 2:
            metal_frame(draw)
            line(draw, (16, 3, 16, 28), P["iron_hi"], 2)
        elif col == 3:
            metal_frame(draw)
            line(draw, (3, 16, 28, 16), P["iron_hi"], 2)
        elif col == 4:
            metal_frame(draw)
            line(draw, (16, 3, 16, 28), P["iron_hi"], 2)
            line(draw, (3, 16, 28, 16), P["iron_hi"], 2)
        elif col == 5:
            box(draw, (0, 0, 31, 31), P["iron_lo"])
            box(draw, (4, 8, 27, 31), P["glass"], P["iron"])
            draw.arc((4, 0, 27, 23), 180, 360, fill=P["glass_hi"], width=3)
        elif col == 6:
            pipe(draw, [(0, 16, 31, 16)])
        elif col == 7:
            pipe(draw, [(16, 0, 16, 31)])
        elif col == 8:
            pipe(draw, [(16, 16, 31, 16), (16, 16, 16, 31)])
        elif col == 9:
            pipe(draw, [(0, 16, 16, 16), (16, 16, 16, 31)])
        elif col == 10:
            pipe(draw, [(0, 16, 31, 16), (16, 16, 16, 31)])
        elif col == 11:
            pipe(draw, [(0, 16, 31, 16), (16, 0, 16, 31)])
        elif col == 12:
            pipe(draw, [(0, 16, 31, 16)])
            draw.ellipse((8, 8, 23, 23), fill=P["copper"], outline=P["ink"], width=2)
            line(draw, (16, 9, 16, 22), P["brass"], 2)
            line(draw, (9, 16, 22, 16), P["brass"], 2)
        elif col == 13:
            pipe(draw, [(0, 16, 31, 16)])
            draw.ellipse((10, 10, 21, 21), fill=P["glass"], outline=P["brass"], width=2)
        elif col == 14:
            pipe(draw, [(0, 16, 31, 16)])
            for x in (5, 13, 21, 29):
                box(draw, (x, 11, x + 1, 21), P["brass"])
        else:
            box(draw, (12, 0, 20, 31), P["copper"], P["ink"])
            box(draw, (9, 4, 23, 8), P["brass"], P["ink"])
            box(draw, (9, 23, 23, 27), P["brass"], P["ink"])

    elif row == 3:
        if col == 0:
            for x in range(0, 32, 8):
                draw.polygon([(x, 31), (x + 4, 7), (x + 8, 31)], fill=P["iron_hi"], outline=P["ink"])
        elif col == 1:
            for x in range(0, 32, 8):
                draw.polygon([(x, 31), (x + 4, 9), (x + 8, 31)], fill=P["thorn"], outline=P["ink"])
        elif col in {2, 3}:
            box(draw, (0, 9, 31, 31), P["water"] if col == 2 else P["verdigris"])
            line(draw, (0, 9, 5, 7, 11, 10, 17, 7, 24, 10, 31, 8), P["water_hi"], 2)
            for x in (5, 18, 27):
                draw.point((x, 17 + (x % 5)), fill=P["water_hi"])
        elif col == 4:
            box(draw, (5, 25, 26, 31), P["stone_lo"], P["ink"])
            for x in range(7, 27, 4):
                line(draw, (x, 25, x + 2, 14), P["leaf_hi"], 2)
            draw.ellipse((10, 8, 22, 20), fill=P["flower"], outline=P["ink"])
        elif col in {5, 6}:
            box(draw, (5, 21, 27, 31), P["iron"], P["ink"])
            box(draw, (14, 7, 18, 22), P["brass"])
            line(draw, (16, 7, 24 if col == 6 else 9, 3), P["brass"], 3)
        elif col in {7, 8}:
            box(draw, (4, 0, 27, 31), P["iron"], P["ink"])
            box(draw, (8, 4, 23, 28), P["deep"], P["iron_hi"])
            if col == 7:
                box(draw, (18, 14, 21, 17), P["brass"])
        elif col == 9:
            box(draw, (11, 0, 14, 31), P["copper"], P["ink"])
            box(draw, (22, 0, 25, 31), P["copper"], P["ink"])
            for y in range(3, 32, 7):
                box(draw, (11, y, 25, y + 2), P["brass"], P["ink"])
        elif col == 10:
            line(draw, (16, 0, 16, 31), P["iron_hi"], 2)
            for y in range(4, 32, 7):
                draw.ellipse((14, y, 18, y + 4), outline=P["brass"])
        elif col == 11:
            box(draw, (13, 0, 18, 18), P["copper"], P["ink"])
            draw.ellipse((7, 15, 24, 31), fill=P["glass"], outline=P["brass"], width=2)
            box(draw, (11, 20, 20, 26), P["water_hi"])
        elif col == 12:
            box(draw, (3, 20, 28, 31), P["iron"], P["ink"])
            draw.ellipse((8, 3, 23, 19), fill=P["verdigris"], outline=P["brass"], width=2)
            draw.ellipse((14, 9, 17, 12), fill=P["water_hi"])
        elif col == 13:
            draw.ellipse((3, 3, 28, 28), fill=P["iron"], outline=P["ink"], width=2)
            draw.ellipse((11, 11, 20, 20), fill=P["copper"], outline=P["ink"])
            for a, b, c, d in ((14, 0, 18, 7), (14, 25, 18, 31), (0, 14, 7, 18), (25, 14, 31, 18)):
                box(draw, (a, b, c, d), P["iron_hi"], P["ink"])
        elif col == 14:
            box(draw, (1, 23, 30, 31), P["stone_lo"], P["ink"])
            for x in (7, 16, 25):
                line(draw, (x, 23, x - 2, 7), P["leaf"], 2)
                draw.ellipse((x - 7, 7, x, 13), fill=P["leaf_hi"], outline=P["ink"])
        else:
            box(draw, (3, 6, 28, 31), P["iron"], P["ink"])
            box(draw, (8, 11, 23, 26), P["glass"], P["brass"])
            line(draw, (9, 24, 14, 16, 18, 21, 23, 12), P["water_hi"], 1)

    else:
        if col <= 3:
            for x in range(4 + col, 30, 7):
                line(draw, (x, 0, x - 2, 29), P["leaf"], 2)
                for y in range(4 + (x % 3), 27, 7):
                    draw.ellipse((x - 6, y, x + 2, y + 5), fill=P["leaf_hi"], outline=P["ink"])
        elif col <= 6:
            line(draw, (16, 31, 15, 17, 7, 9, 10, 1), P["copper"], 3)
            line(draw, (15, 18, 25, 10, 23, 3), P["soil_hi"], 3)
        elif col <= 10:
            box(draw, (2, 27, 29, 31), P["soil"], P["ink"])
            for x in range(5, 29, 6):
                line(draw, (x, 28, x + (col % 3) - 1, 12 - (x % 4)), P["leaf"], 3)
                draw.ellipse((x - 4, 9 + (x % 5), x + 4, 16 + (x % 5)), fill=P["leaf_hi"], outline=P["ink"])
        elif col == 11:
            box(draw, (10, 12, 22, 31), P["copper"], P["ink"])
            draw.ellipse((5, 3, 27, 18), fill=P["flower"], outline=P["ink"], width=2)
            draw.ellipse((11, 7, 21, 15), fill=P["deep"])
        elif col == 12:
            box(draw, (3, 17, 28, 31), P["iron"], P["ink"])
            draw.ellipse((6, 5, 25, 24), outline=P["brass"], width=4)
        elif col == 13:
            box(draw, (2, 10, 29, 31), P["iron"], P["ink"])
            draw.ellipse((7, 14, 16, 23), fill=P["verdigris"], outline=P["brass"])
            box(draw, (18, 13, 25, 29), P["copper"], P["ink"])
        elif col == 14:
            box(draw, (2, 2, 29, 31), P["iron"], P["ink"])
            box(draw, (6, 6, 25, 27), P["verdigris"], P["brass"])
            for y in (10, 16, 22):
                line(draw, (7, y, 24, y), P["glass_hi"])
        else:
            box(draw, (7, 2, 24, 31), P["copper"], P["ink"])
            box(draw, (10, 6, 21, 27), P["glass"], P["brass"])
            box(draw, (12, 18, 19, 26), P["water_hi"])


def make_png():
    sheet = Image.new("RGBA", (COLS * TILE, ROWS * TILE), (0, 0, 0, 0))
    for tile_id in range(COLS * ROWS):
        tile = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
        draw_tile(tile_id, ImageDraw.Draw(tile))
        x = (tile_id % COLS) * TILE
        y = (tile_id // COLS) * TILE
        sheet.alpha_composite(tile, (x, y))
    sheet.save(PNG_PATH)


def collision(parent, x=0, y=0, width=32, height=32, obj_type="solid"):
    group = ET.SubElement(parent, "objectgroup", draworder="index")
    ET.SubElement(
        group,
        "object",
        id="1",
        type=obj_type,
        x=str(x),
        y=str(y),
        width=str(width),
        height=str(height),
    )


def make_tsx():
    root = ET.Element(
        "tileset",
        version="1.10",
        tiledversion="1.11.2",
        name="serre-mecanique-32x32",
        tilewidth="32",
        tileheight="32",
        tilecount=str(COLS * ROWS),
        columns=str(COLS),
    )
    ET.SubElement(root, "image", source="serre-mecanique-32x32.png", width=str(COLS * TILE), height=str(ROWS * TILE))

    full_solid = list(range(0, 9)) + [15] + list(range(16, 28))
    for tile_id in full_solid:
        tile = ET.SubElement(root, "tile", id=str(tile_id), type="solid")
        collision(tile)
    for tile_id in range(9, 15):
        tile = ET.SubElement(root, "tile", id=str(tile_id), type="one_way")
        collision(tile, y=0, height=8, obj_type="one_way")

    hazards = {48: "spikes", 49: "thorns", 51: "toxic_water"}
    for tile_id, kind in hazards.items():
        tile = ET.SubElement(root, "tile", id=str(tile_id), type="hazard")
        props = ET.SubElement(tile, "properties")
        ET.SubElement(props, "property", name="hazard", value=kind)
        collision(tile, y=10, height=22, obj_type="hazard")

    typed = {
        50: ("water", "swimmable"),
        52: ("spring", "bounce"),
        53: ("lever_off", "interactable"),
        54: ("lever_on", "interactable"),
        55: ("door_closed", "solid"),
        56: ("door_open", "decor"),
        57: ("ladder", "climbable"),
        58: ("chain", "climbable"),
    }
    for tile_id, (name, kind) in typed.items():
        tile = ET.SubElement(root, "tile", id=str(tile_id), type=kind)
        props = ET.SubElement(tile, "properties")
        ET.SubElement(props, "property", name="role", value=name)
        if tile_id == 55:
            collision(tile)

    ET.indent(root, space="  ")
    ET.ElementTree(root).write(TSX_PATH, encoding="utf-8", xml_declaration=True)


def make_demo_map():
    width, height = 40, 18
    terrain = [0] * (width * height)
    decor = [0] * (width * height)

    def put(layer, x, y, tile_id):
        layer[y * width + x] = tile_id + 1

    for y in range(15, height):
        for x in range(width):
            put(terrain, x, y, 1 if y == 15 else 0)
    for x in range(3, 10):
        put(terrain, x, 11, 9 if x == 3 else (11 if x == 9 else 10))
    for x in range(14, 21):
        put(terrain, x, 9, 12 if x == 14 else (14 if x == 20 else 13))
    for x in range(27, 35):
        put(terrain, x, 12, 9 if x == 27 else (11 if x == 34 else 10))

    for x in range(22, 26):
        put(decor, x, 14, 48)
    for x in range(10, 14):
        put(decor, x, 15, 50)
    put(decor, 7, 10, 52)
    put(decor, 18, 8, 53)
    put(decor, 36, 14, 55)
    put(decor, 5, 7, 57)
    put(decor, 6, 7, 64)
    put(decor, 7, 7, 65)
    put(decor, 28, 11, 75)
    put(decor, 31, 11, 76)
    for x in range(1, 39):
        put(decor, x, 2, 32 if x % 3 else 33)
    for x in range(0, 40):
        put(decor, x, 3, 22 if x % 2 else 23)
    for x in range(1, 18):
        put(decor, x, 5, 38)
    put(decor, 18, 5, 40)
    for y in range(6, 13):
        put(decor, 18, y, 39)

    data = {
        "compressionlevel": -1,
        "height": height,
        "infinite": False,
        "layers": [
            {"data": terrain, "height": height, "id": 1, "name": "Terrain", "opacity": 1, "type": "tilelayer", "visible": True, "width": width, "x": 0, "y": 0},
            {"data": decor, "height": height, "id": 2, "name": "Décor et gameplay", "opacity": 1, "type": "tilelayer", "visible": True, "width": width, "x": 0, "y": 0},
            {"draworder": "topdown", "id": 3, "name": "Objets", "objects": [], "opacity": 1, "type": "objectgroup", "visible": True, "x": 0, "y": 0},
        ],
        "nextlayerid": 4,
        "nextobjectid": 1,
        "orientation": "orthogonal",
        "renderorder": "right-down",
        "tiledversion": "1.11.2",
        "tileheight": TILE,
        "tilesets": [{"firstgid": 1, "source": "../../assets/tilesets/serre-mecanique-32x32.tsx"}],
        "tilewidth": TILE,
        "type": "map",
        "version": "1.10",
        "width": width,
    }
    MAP_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def validate_pixel_edges():
    sheet = Image.open(PNG_PATH).convert("RGBA")
    alpha = sheet.getchannel("A")
    full_solid = list(range(0, 9)) + [15] + list(range(16, 28))
    for tile_id in full_solid:
        x = (tile_id % COLS) * TILE
        y = (tile_id // COLS) * TILE
        tile_alpha = alpha.crop((x, y, x + TILE, y + TILE))
        assert tile_alpha.getextrema() == (255, 255), f"solid tile {tile_id} has transparent pixels"
    for tile_id in range(9, 15):
        x = (tile_id % COLS) * TILE
        y = (tile_id // COLS) * TILE
        surface = alpha.crop((x, y, x + TILE, y + 8))
        assert surface.getextrema() == (255, 255), f"platform tile {tile_id} does not reach both edges"


def main():
    TILESET_DIR.mkdir(parents=True, exist_ok=True)
    MAP_DIR.mkdir(parents=True, exist_ok=True)
    make_png()
    make_tsx()
    make_demo_map()
    validate_pixel_edges()
    print(PNG_PATH)
    print(TSX_PATH)
    print(MAP_PATH)


if __name__ == "__main__":
    main()
