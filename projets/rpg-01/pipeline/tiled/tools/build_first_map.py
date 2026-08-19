#!/usr/bin/env python3
"""Build the first authored RPG map from the canonical Tiled template."""

from pathlib import Path
import json
import random
import xml.etree.ElementTree as ET

from create_map import ROOT, build, property_node
from map_contract import assert_map_contract


LEVEL_ID = "vallee-des-sources"
OUTPUT = ROOT / "pipeline/tiled/maps/source" / f"{LEVEL_ID}.tmx"
WIDTH = HEIGHT = 40
TILE = 32
def gid(family: int, variant: int = 0) -> int:
    return 1 + family * 11 + variant


def cell_center(x: int, y: int) -> tuple[float, float]:
    return x * TILE + TILE / 2, y * TILE + TILE / 2


def main() -> int:
    build(LEVEL_ID, OUTPUT, WIDTH, HEIGHT)
    tree = ET.parse(OUTPUT)
    root = tree.getroot()
    first_gids = {
        Path(tileset.get("source", "")).stem: int(tileset.get("firstgid", "0"))
        for tileset in root.findall("tileset")
    }
    object_first_gid = first_gids["world_objects"]
    map_properties = root.find("properties")
    property_node(map_properties, "biome", "temperate_river_valley")
    property_node(map_properties, "design_intent", "Village hub, river crossing, height-gated exploration and future interiors")
    property_node(map_properties, "reference", "pipeline/assets/sources/reference/world-map-target-v001.png")
    property_node(map_properties, "recommended_spawn", "village-arrival")

    layers = {layer.get("name"): layer for layer in root.findall(".//layer")}
    grids = {name: [0] * (WIDTH * HEIGHT) for name in layers}

    def paint(name: str, x: int, y: int, value: int) -> None:
        if 0 <= x < WIDTH and 0 <= y < HEIGHT:
            grids[name][y * WIDTH + x] = value

    # Ground: a quiet textured field, with deterministic sparse variation.
    rng = random.Random(20260818)
    for y in range(HEIGHT):
        for x in range(WIDTH):
            variant = 0
            roll = rng.random()
            if roll < 0.025:
                variant = 1 + rng.randrange(4)
            paint("Ground", x, y, gid(0, variant))

    # River: a broad north-south curve with a pond on the eastern bank.
    river_cells: set[tuple[int, int]] = set()
    for y in range(HEIGHT):
        center = 29 if y < 7 else 28 if y < 14 else 27 if y < 23 else 26 if y < 31 else 24
        width = 4 if 8 <= y <= 31 else 3
        for x in range(center - width // 2, center + (width + 1) // 2):
            river_cells.add((x, y))
    for y in range(9, 15):
        for x in range(32, 38):
            if ((x - 34.5) / 3.5) ** 2 + ((y - 11.5) / 3.0) ** 2 <= 1.0:
                river_cells.add((x, y))
    for x, y in river_cells:
        paint("WaterBase", x, y, gid(3, (x + y) % 3))
        exposed = []
        if (x, y - 1) not in river_cells:
            exposed.append(0)
        if (x, y + 1) not in river_cells:
            exposed.append(1)
        if (x - 1, y) not in river_cells:
            exposed.append(2)
        if (x + 1, y) not in river_cells:
            exposed.append(3)
        if exposed:
            paint("WaterBanks", x, y, gid(4, exposed[0]))

    # Road hierarchy. Primary routes use two complementary edge tiles, producing
    # a continuous 64 px dirt band instead of repeated crossroad stamps.
    def paint_horizontal_wide(x0: int, x1: int, top_y: int) -> None:
        for x in range(x0, x1 + 1):
            if (x, top_y) not in river_cells:
                paint("Paths", x, top_y, gid(1, 7))
            if (x, top_y + 1) not in river_cells:
                paint("Paths", x, top_y + 1, gid(1, 8))

    def paint_vertical_wide(left_x: int, y0: int, y1: int) -> None:
        for y in range(y0, y1 + 1):
            if (left_x, y) not in river_cells:
                paint("Paths", left_x, y, gid(1, 9))
            if (left_x + 1, y) not in river_cells:
                paint("Paths", left_x + 1, y, gid(1, 10))

    def paint_wide_junction(left_x: int, top_y: int) -> None:
        for y in (top_y, top_y + 1):
            for x in (left_x, left_x + 1):
                if (x, y) not in river_cells:
                    paint("Paths", x, y, gid(1, 6))

    paint_vertical_wide(11, 0, HEIGHT - 1)    # grand axe nord-sud
    paint_vertical_wide(21, 20, 30)           # place → boucle basse est
    paint_horizontal_wide(0, 32, 20)          # village, place et pont
    paint_horizontal_wide(1, 12, 9)           # accès du potager
    paint_horizontal_wide(11, 27, 29)         # boucle basse, hors du plateau
    paint_horizontal_wide(3, 9, 29)           # chemin réellement en hauteur
    paint_vertical_wide(6, 29, 34)            # chemin haut vers l'escalier
    paint_horizontal_wide(6, 12, 36)          # approche basse de l'escalier
    for junction in [(11, 9), (11, 20), (11, 29), (21, 20), (21, 29), (6, 29), (11, 36)]:
        paint_wide_junction(*junction)

    # Stone village square.
    for y in range(13, 20):
        for x in range(14, 22):
            paint("StoneFloors", x, y, gid(2, (x + 2 * y) % 3))

    # Two raised plateaus. Their visual perimeter mirrors the physical perimeter:
    # a back ledge, two side walls and a two-row front face broken only by stairs.
    plateau_cells = set()
    for y in range(3, 11):
        for x in range(14, 24):
            plateau_cells.add((x, y))
    for y in range(25, 35):
        for x in range(2, 11):
            plateau_cells.add((x, y))
    for x, y in plateau_cells:
        if (x * 7 + y * 11) % 23 == 0:
            paint("Ground", x, y, gid(0, 4 + (x + y) % 2))

    def paint_horizontal_cliff_segment(x0: int, x1: int, top_y: int) -> None:
        for x in range(x0, x1 + 1):
            top_variant = 2 if x == x0 else 3 if x == x1 else 10
            face_variant = 10 if x == x0 else 9 if x == x1 else 3
            paint("CliffFront", x, top_y, gid(5, top_variant))
            if top_y + 1 < HEIGHT:
                paint("CliffFaces", x, top_y + 1, gid(6, face_variant))

    def paint_plateau_perimeter(x0: int, x1: int, y0: int, y1: int, stair_x0: int, stair_x1: int) -> None:
        for x in range(x0, x1 + 1):
            back_variant = 6 if x == x0 else 4 if x == x1 else 1
            paint("CliffBack", x, y0, gid(5, back_variant))
        for y in range(y0 + 1, y1):
            paint("CliffFaces", x0, y, gid(6, 1))
            paint("CliffFaces", x1, y, gid(6, 2))
        if x0 <= stair_x0 - 1:
            paint_horizontal_cliff_segment(x0, stair_x0 - 1, y1)
        if stair_x1 + 1 <= x1:
            paint_horizontal_cliff_segment(stair_x1 + 1, x1, y1)

    paint_plateau_perimeter(14, 23, 3, 10, 17, 19)
    paint_plateau_perimeter(2, 10, 25, 34, 6, 8)

    # Decorative water details and a short waterfall at the north entrance.
    for y in (1, 2, 3):
        paint("WaterEffects", 29, y, gid(9 if y < 3 else 10, 2))
    for x, y in [(34, 11), (36, 12), (25, 34), (27, 25)]:
        if (x, y) in river_cells:
            paint("WaterEffects", x, y, gid(3, 7))

    for name, layer in layers.items():
        layer.find("data").text = ",".join(str(value) for value in grids[name])

    groups = {group.get("name"): group for group in root.findall(".//objectgroup")}
    catalog = json.loads((ROOT / "game/world/tileset/objects/objects_catalog.json").read_text(encoding="utf-8"))["sprites"]
    by_id = {sprite["id"]: (index, sprite) for index, sprite in enumerate(catalog)}
    next_object_id = 1

    def add_properties(node: ET.Element, values: dict[str, object]) -> None:
        if not values:
            return
        properties = ET.SubElement(node, "properties")
        for key, value in values.items():
            kind = "bool" if isinstance(value, bool) else "int" if isinstance(value, int) else "float" if isinstance(value, float) else "string"
            property_node(properties, key, str(value).lower() if isinstance(value, bool) else str(value), kind)

    def add_asset(layer: str, asset_id: str, cell_x: int, cell_y: int, name: str = "", rotation: float = 0.0, properties: dict[str, object] | None = None) -> None:
        nonlocal next_object_id
        tile_id, sprite = by_id[asset_id]
        x, y = cell_center(cell_x, cell_y)
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name or asset_id.replace(".", "-"),
            "class": sprite["default_role"], "gid": str(object_first_gid + tile_id),
            "x": str(x), "y": str(y), "width": str(sprite["region_size_px"][0]),
            "height": str(sprite["foot_anchor_px"][1]), "rotation": str(rotation),
        })
        add_properties(node, properties or {})
        next_object_id += 1

    def add_rect(layer: str, name: str, class_name: str, x: float, y: float, width: float, height: float, properties: dict[str, object]) -> None:
        nonlocal next_object_id
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name, "class": class_name,
            "x": str(x), "y": str(y), "width": str(width), "height": str(height),
        })
        add_properties(node, properties)
        next_object_id += 1

    def add_polygon(layer: str, name: str, class_name: str, points: list[tuple[int, int]], properties: dict[str, object]) -> None:
        nonlocal next_object_id
        origin_x, origin_y = points[0]
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name, "class": class_name,
            "x": str(origin_x), "y": str(origin_y),
        })
        add_properties(node, properties)
        ET.SubElement(node, "polygon", {"points": " ".join(f"{x-origin_x},{y-origin_y}" for x, y in points)})
        next_object_id += 1

    def add_point(layer: str, name: str, class_name: str, cell_x: int, cell_y: int, properties: dict[str, object]) -> None:
        nonlocal next_object_id
        x, y = cell_center(cell_x, cell_y)
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name, "class": class_name, "x": str(x), "y": str(y),
        })
        add_properties(node, properties)
        ET.SubElement(node, "point")
        next_object_id += 1

    # Village and traversal landmarks.
    add_asset("ArchitectureObjects", "building.cottage_exterior", 7, 19, "MaisonDuGardien")
    add_asset("ArchitectureObjects", "traversal.bridge_wood_stone_long", 27, 21, "PontDeLaSource")
    add_asset("ArchitectureObjects", "traversal.stairs_stone_north", 18, 12, "EscalierNord")
    add_asset("ArchitectureObjects", "traversal.stairs_stone_north", 7, 36, "EscalierSud")
    add_asset("YSortedObjects", "prop.well_stone_round", 18, 17, "PuitsDuVillage")
    add_asset("YSortedObjects", "prop.signpost_wood", 12, 21, "PanneauCarrefour")
    add_asset("YSortedObjects", "prop.barrel_water", 10, 19)
    add_asset("YSortedObjects", "prop.crate_wood_large", 4, 20)
    add_asset("YSortedObjects", "prop.haystack_round", 36, 29)
    add_asset("YSortedObjects", "prop.planter_flowers", 15, 15)
    add_asset("YSortedObjects", "prop.planter_flowers", 21, 15)

    # Farm and fences.
    for x in (3, 8):
        for y in (5, 8):
            add_asset("GroundObjects", "farm.soil_plot_empty", x, y)
    for x, y, crop in [(3, 5, "farm.crop_cabbages"), (5, 5, "farm.crop_carrots_a"), (7, 5, "farm.crop_sprouts_a"), (3, 8, "farm.crop_carrots_b"), (6, 8, "farm.crop_sprouts_b")]:
        add_asset("YSortedObjects", crop, x, y)
    add_asset("BoundaryObjects", "boundary.fence_wood_long", 5, 3)
    add_asset("BoundaryObjects", "boundary.fence_wood_long", 5, 10)
    add_asset("BoundaryObjects", "boundary.fence_wood_long", 1, 7, rotation=90)
    add_asset("BoundaryObjects", "boundary.gate_wood_closed", 10, 7, "PortailDuPotager", rotation=90)
    add_asset("BoundaryObjects", "boundary.fence_wood_short", 3, 22)
    add_asset("BoundaryObjects", "boundary.fence_wood_long", 7, 22)
    add_asset("BoundaryObjects", "boundary.fence_wood_short", 11, 18, rotation=90)

    # Forest framing, leaving readable routes and landmarks.
    trees = [
        (1, 2, 63), (10, 2, 57), (1, 14, 58), (3, 24, 57), (11, 26, 59),
        (1, 37, 63), (12, 37, 57), (20, 2, 58), (24, 6, 59), (36, 2, 63),
        (38, 7, 57), (37, 18, 58), (34, 23, 59), (38, 36, 63), (31, 37, 57),
        (17, 36, 58), (21, 28, 59), (15, 25, 61), (33, 33, 62), (5, 27, 61),
        (4, 1, 58), (8, 1, 61), (15, 1, 57), (25, 1, 61), (32, 1, 58),
        (39, 12, 59), (38, 15, 61), (38, 25, 57), (39, 30, 62),
        (28, 38, 58), (24, 37, 61), (19, 39, 57), (14, 39, 62),
        (2, 32, 58), (1, 28, 61), (6, 38, 59), (10, 34, 62),
    ]
    tree_ids = {57: "vegetation.tree_pine_large", 58: "vegetation.tree_pine_medium_a", 59: "vegetation.tree_pine_medium_b", 61: "vegetation.tree_pine_small_a", 62: "vegetation.tree_pine_small_b", 63: "vegetation.tree_pine_xl"}
    for x, y, object_index in trees:
        add_asset("YSortedObjects", tree_ids[object_index], x, y)
    for x, y, asset in [
        (6, 13, "vegetation.bush_round_a"), (10, 12, "vegetation.bush_round_b"),
        (23, 4, "vegetation.bush_round_c"), (25, 9, "vegetation.bush_round_d"),
        (30, 7, "vegetation.bush_round_a"), (37, 6, "vegetation.bush_round_b"),
        (34, 17, "vegetation.bush_round_c"), (37, 24, "vegetation.bush_round_d"),
        (31, 31, "vegetation.bush_round_a"), (27, 35, "vegetation.bush_round_b"),
        (13, 33, "vegetation.bush_round_c"), (4, 31, "vegetation.bush_round_d"),
        (3, 16, "vegetation.bush_round_a"), (18, 24, "vegetation.bush_round_b"),
    ]:
        add_asset("YSortedObjects", asset, x, y)
    for x, y, asset in [(23, 8, "obstacle.boulder_cluster_large"), (33, 18, "obstacle.boulder_cluster_medium"), (16, 32, "prop.fallen_logs"), (36, 35, "obstacle.rock_small"), (2, 22, "prop.tree_stump"), (30, 15, "relief.cliff_pillar_small"), (23, 34, "relief.cliff_pillar_tiny")]:
        add_asset("YSortedObjects", asset, x, y)

    # Flowers, grasses and water plants make the composition feel inhabited.
    ground_decor = [
        (11, 5, "decor.flower_cluster_white_a"), (9, 13, "decor.flower_cluster_blue_a"),
        (22, 12, "decor.flower_cluster_pink_a"), (15, 22, "decor.flower_cluster_yellow_b"),
        (31, 18, "decor.flower_cluster_blue_b"), (34, 27, "decor.flower_cluster_pink_b"),
        (18, 34, "decor.flower_cluster_white_b"), (8, 37, "decor.flower_cluster_yellow_a"),
        (23, 24, "decor.grass_tuft_a"), (14, 7, "decor.grass_tuft_b"),
        (32, 6, "decor.grass_tuft_c"), (5, 23, "decor.pebbles_cluster_large"),
        (20, 31, "decor.pebbles_cluster_medium"), (35, 20, "decor.pebbles_cluster_small"),
    ]
    for x, y, asset in ground_decor:
        add_asset("GroundObjects", asset, x, y)
    for x, y, asset in [(34, 10, "water.cattails_cluster_a"), (36, 13, "water.cattails_cluster_b"), (33, 12, "water.lily_pad_large"), (35, 11, "water.lotus_pink"), (25, 29, "water.lily_pad_medium")]:
        add_asset("WaterObjects", asset, x, y)

    # Gameplay contract: every water cell blocks except the rows physically
    # covered by the bridge. Exact scanline runs remain inspectable in Tiled.
    bridge_rows = {20, 21}
    for y in range(HEIGHT):
        blocked_x = sorted(x for x, water_y in river_cells if water_y == y and y not in bridge_rows)
        if not blocked_x:
            continue
        run_start = blocked_x[0]
        previous = blocked_x[0]
        segment = 1
        for x in blocked_x[1:] + [blocked_x[-1] + 2]:
            if x == previous + 1:
                previous = x
                continue
            add_rect(
                "CollisionOverrides", f"WaterRow{y:02d}Segment{segment:02d}", "solid",
                run_start*TILE, y*TILE, (previous-run_start+1)*TILE, TILE,
                {"collision_layer": 1, "collision_mask": 1, "surface": "water", "traversal": "blocked"},
            )
            segment += 1
            run_start = x
            previous = x

    # The world edge is physical. Exit zones trigger a map change before the
    # actor reaches it; they never permit walking outside authored space.
    add_rect("CollisionOverrides", "WorldBoundaryNorth", "solid", 0, -TILE, WIDTH*TILE, TILE, {"boundary": True})
    add_rect("CollisionOverrides", "WorldBoundarySouth", "solid", 0, HEIGHT*TILE, WIDTH*TILE, TILE, {"boundary": True})
    add_rect("CollisionOverrides", "WorldBoundaryWest", "solid", -TILE, 0, TILE, HEIGHT*TILE, {"boundary": True})
    add_rect("CollisionOverrides", "WorldBoundaryEast", "solid", WIDTH*TILE, 0, TILE, HEIGHT*TILE, {"boundary": True})

    # Raised areas have a closed perimeter and one explicit stair gap.
    add_rect("CollisionOverrides", "NorthCliffFaceWest", "solid", 14*TILE, 10*TILE, 3*TILE, 2*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "NorthCliffFaceEast", "solid", 20*TILE, 10*TILE, 4*TILE, 2*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "NorthCliffBack", "solid", 14*TILE, 2*TILE, 10*TILE, TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "NorthCliffSideWest", "solid", 14*TILE, 3*TILE, TILE, 7*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "NorthCliffSideEast", "solid", 23*TILE, 3*TILE, TILE, 7*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "SouthCliffFaceWest", "solid", 2*TILE, 34*TILE, 4*TILE, 2*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "SouthCliffFaceEast", "solid", 9*TILE, 34*TILE, 2*TILE, 2*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "SouthCliffBack", "solid", 2*TILE, 24*TILE, 9*TILE, TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "SouthCliffSideWest", "solid", 2*TILE, 25*TILE, TILE, 9*TILE, {"height_level": 1})
    add_rect("CollisionOverrides", "SouthCliffSideEast", "solid", 10*TILE, 25*TILE, TILE, 9*TILE, {"height_level": 1})
    add_rect("ElevationTransitions", "NorthStairsTransition", "stairs", 17*TILE, 10*TILE, 3*TILE, 3*TILE, {"from_height": 0, "to_height": 1, "direction": "north"})
    add_rect("ElevationTransitions", "SouthStairsTransition", "stairs", 6*TILE, 34*TILE, 3*TILE, 3*TILE, {"from_height": 0, "to_height": 1, "direction": "north"})
    add_polygon("HeightZones", "NorthPlateau", "height_zone", [(14*TILE, 3*TILE), (24*TILE, 3*TILE), (24*TILE, 11*TILE), (14*TILE, 11*TILE)], {"height_level": 1})
    add_polygon("HeightZones", "SouthPlateau", "height_zone", [(2*TILE, 25*TILE), (11*TILE, 25*TILE), (11*TILE, 35*TILE), (2*TILE, 35*TILE)], {"height_level": 1})

    house_x, house_y = cell_center(7, 19)
    well_x, well_y = cell_center(18, 17)
    sign_x, sign_y = cell_center(12, 21)
    add_rect("Entrances", "MaisonDuGardienDoor", "entrance", house_x-18, house_y-36, 36, 28, {"target_scene": "house-guardian", "target_spawn": "front-door", "locked": False})
    add_rect("Interactions", "PuitsInteraction", "inspect", well_x-24, well_y-24, 48, 48, {"interaction_id": "village-well", "prompt": "Examiner le puits"})
    add_rect("Interactions", "PanneauInteraction", "inspect", sign_x-16, sign_y-24, 32, 48, {"interaction_id": "crossroads-sign", "prompt": "Lire le panneau"})
    add_rect("Interactions", "PotagerInteraction", "harvest_zone", 2*TILE, 4*TILE, 8*TILE, 6*TILE, {"interaction_id": "community-garden", "requires_tool": "none"})
    add_point("SpawnPoints", "VillageArrival", "player_spawn", 11, 22, {"spawn_id": "village-arrival", "facing": "north"})
    add_point("SpawnPoints", "AfterBridge", "player_spawn", 30, 21, {"spawn_id": "after-bridge", "facing": "east"})
    add_rect("Exits", "SouthRoadExit", "exit", 11*TILE, 39*TILE, 3*TILE, TILE, {"target_map": "future-south-road", "target_spawn": "north-entry"})
    add_rect("Exits", "NorthRoadExit", "exit", 11*TILE, 0, 3*TILE, TILE, {"target_map": "future-north-road", "target_spawn": "south-entry"})
    add_rect("CameraZones", "WorldCameraBounds", "camera_zone", 0, 0, WIDTH*TILE, HEIGHT*TILE, {"limit_left": 0, "limit_top": 0, "limit_right": WIDTH*TILE, "limit_bottom": HEIGHT*TILE, "zoom": 1.0, "priority": 0, "offset_x": 0.0, "offset_y": 0.0})
    add_rect("CameraZones", "BridgeCameraZone", "camera_zone", 23*TILE, 17*TILE, 10*TILE, 8*TILE, {"limit_left": 0, "limit_top": 0, "limit_right": WIDTH*TILE, "limit_bottom": HEIGHT*TILE, "zoom": 1.0, "priority": 10, "offset_x": 0.0, "offset_y": -16.0})

    root.set("nextobjectid", str(next_object_id))
    ET.indent(root, space=" ")
    tree.write(OUTPUT, encoding="utf-8", xml_declaration=True)
    assert_map_contract(OUTPUT)
    print(f"Carte auteur créée : {OUTPUT.relative_to(ROOT)} — {next_object_id - 1} objets et zones")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
