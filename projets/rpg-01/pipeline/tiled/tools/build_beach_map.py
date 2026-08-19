#!/usr/bin/env python3
"""Build the opening beach as an authored Tiled map."""

from pathlib import Path
import json
import random
import xml.etree.ElementTree as ET

from create_map import ROOT, build, property_node
from map_contract import assert_map_contract


LEVEL_ID = "plage-du-reveil"
OUTPUT = ROOT / "pipeline/tiled/maps/source" / f"{LEVEL_ID}.tmx"
WIDTH, HEIGHT, TILE = 40, 30, 32


def main() -> int:
    build(LEVEL_ID, OUTPUT, WIDTH, HEIGHT)
    tree = ET.parse(OUTPUT)
    root = tree.getroot()
    props = root.find("properties")
    property_node(props, "biome", "mysterious_warm_coast")
    property_node(props, "design_intent", "Azeman awakens, explores wreckage and approaches the first telekinesis discovery")
    property_node(props, "recommended_spawn", "beach-awakening")

    first_gids = {
        Path(node.get("source", "")).stem: int(node.get("firstgid", "0"))
        for node in root.findall("tileset")
    }

    def gid(family: str, variant: int = 0) -> int:
        return first_gids[family] + variant

    layers = {layer.get("name"): layer for layer in root.findall(".//layer")}

    # La carte choisit seulement des profils génériques. Le rendu et ses
    # paramètres restent centralisés côté Godot et réutilisables ailleurs.
    water_profiles = {
        "WaterBase": ("water_calm", {"environment_animation_direction_x": 0.0, "environment_animation_direction_y": -1.0}),
        "WaterBanks": ("shoreline_foam", {"environment_animation_direction_x": 0.0, "environment_animation_direction_y": -1.0}),
        "WaterEffects": ("shoreline_foam", {"environment_animation_direction_x": 0.0, "environment_animation_direction_y": -1.0, "environment_animation_speed_scale": 0.82, "environment_animation_phase": 0.7}),
    }
    for layer_name, (profile_id, overrides) in water_profiles.items():
        layer_properties = layers[layer_name].find("properties")
        profile_property = layer_properties.find("property[@name='environment_animation_profile']")
        profile_property.set("value", profile_id)
        for key, value in overrides.items():
            property_node(layer_properties, key, str(value), "float")
    grids = {name: [0] * (WIDTH * HEIGHT) for name in layers}

    def paint(layer: str, x: int, y: int, value: int) -> None:
        if 0 <= x < WIDTH and 0 <= y < HEIGHT:
            grids[layer][y * WIDTH + x] = value

    rng = random.Random(20260819)
    for y in range(HEIGHT):
        for x in range(WIDTH):
            paint("Ground", x, y, gid("12_beach_dry_sand", rng.randrange(10) if rng.random() < 0.14 else 0))

    # A visible dune lip separates the inaccessible back plane from the beach.
    # The opening at the centre remains the only readable route inland.
    for x in list(range(0, 17)) + list(range(23, WIDTH)):
        paint("GroundVariations", x, 4, gid("18_beach_dunes", 5))
    for index, (x, y) in enumerate([(2, 2), (7, 3), (12, 2), (27, 2), (33, 3), (38, 2)]):
        paint("GroundVariations", x, y, gid("18_beach_dunes", 6 + index % 4))

    # Footprints form two broken visual lines: awakening -> strange stone and
    # awakening -> inland gap. They guide without drawing a literal road.
    for index, (x, y) in enumerate([
        (20, 15), (21, 15), (22, 14), (23, 14),
        (20, 13), (20, 11), (20, 9), (20, 7), (20, 5),
    ]):
        paint("GroundVariations", x, y, gid("12_beach_dry_sand", 2 + index % 2))

    # The wet-sand edge is an authored contour rather than a geometric strip.
    # Values are deliberately grouped into broad, gentle tongues so the coast
    # remains readable without producing a noisy one-tile checkerboard.
    wet_sand_edge = (
        16, 16, 16, 15, 15, 15, 16, 16, 17, 17,
        16, 16, 15, 15, 14, 15, 15, 16, 16, 16,
        17, 17, 16, 16, 15, 15, 15, 16, 16, 17,
        17, 16, 16, 15, 15, 16, 16, 16, 17, 17,
    )
    for x, edge_y in enumerate(wet_sand_edge):
        # Variant 2 contains the soft dry/wet transition already authored in
        # the tileset. Variants 3 and 4 break the remaining horizontal rhythm
        # where the contour rises or falls.
        previous_y = wet_sand_edge[x - 1] if x > 0 else edge_y
        next_y = wet_sand_edge[x + 1] if x < WIDTH - 1 else edge_y
        edge_variant = 3 if next_y < edge_y or previous_y > edge_y else 4 if next_y > edge_y or previous_y < edge_y else 2
        paint("GroundVariations", x, edge_y, gid("13_beach_wet_sand", edge_variant))
        for y in range(edge_y + 1, 19):
            paint("GroundVariations", x, y, gid("13_beach_wet_sand", 0))
    for x in range(WIDTH):
        paint("WaterBanks", x, 19, gid("16_beach_shoreline", 0))
        paint("WaterEffects", x, 20, gid("17_beach_foam", 0))
    for y in range(20, 24):
        for x in range(WIDTH):
            paint("WaterBase", x, y, gid("14_beach_shallow_water", (x + 2 * y) % 4))
    for y in range(24, HEIGHT):
        for x in range(WIDTH):
            paint("WaterBase", x, y, gid("15_beach_deep_water", (x + y) % 4))

    # Two rocky arms turn the coastline into a sheltered cove.
    for y in range(10, 20):
        width = 3 if y < 16 else 2
        for x in range(width):
            paint("CliffFaces", x, y, gid("19_beach_rock_coast", 0 if x == width - 1 else 1))
            paint("CliffFaces", WIDTH - 1 - x, y, gid("19_beach_rock_coast", 1 if x == width - 1 else 0))

    for name, layer in layers.items():
        layer.find("data").text = ",".join(str(value) for value in grids[name])

    groups = {group.get("name"): group for group in root.findall(".//objectgroup")}
    catalog = json.loads((ROOT / "game/world/tileset/beach/objects/beach_objects_catalog.json").read_text(encoding="utf-8"))["sprites"]
    by_id = {sprite["id"]: (index, sprite) for index, sprite in enumerate(catalog)}
    object_first_gid = first_gids["beach_objects"]
    next_object_id = 1

    def add_properties(node: ET.Element, values: dict[str, object]) -> None:
        if not values:
            return
        container = ET.SubElement(node, "properties")
        for key, value in values.items():
            kind = "bool" if isinstance(value, bool) else "int" if isinstance(value, int) else "float" if isinstance(value, float) else "string"
            property_node(container, key, str(value).lower() if isinstance(value, bool) else str(value), kind)

    def add_asset(layer: str, asset_id: str, x: int, y: int, name: str = "") -> None:
        nonlocal next_object_id
        tile_id, sprite = by_id[asset_id]
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name or asset_id.replace(".", "-"),
            "class": sprite["default_role"], "gid": str(object_first_gid + tile_id),
            "x": str(x * TILE + TILE / 2), "y": str(y * TILE + TILE / 2),
            "width": str(sprite["region_size_px"][0]), "height": str(sprite["foot_anchor_px"][1]),
        })
        next_object_id += 1

    def add_rect(layer: str, name: str, class_name: str, x: float, y: float, width: float, height: float, values: dict[str, object]) -> None:
        nonlocal next_object_id
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name, "class": class_name,
            "x": str(x), "y": str(y), "width": str(width), "height": str(height),
        })
        add_properties(node, values)
        next_object_id += 1

    def add_polygon(layer: str, name: str, class_name: str, points: list[tuple[float, float]], values: dict[str, object]) -> None:
        nonlocal next_object_id
        origin_x = min(point[0] for point in points)
        origin_y = min(point[1] for point in points)
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name, "class": class_name,
            "x": str(origin_x), "y": str(origin_y),
        })
        add_properties(node, values)
        ET.SubElement(node, "polygon", {
            "points": " ".join(f"{x-origin_x},{y-origin_y}" for x, y in points),
        })
        next_object_id += 1

    def add_point(layer: str, name: str, class_name: str, x: int, y: int, values: dict[str, object]) -> None:
        nonlocal next_object_id
        node = ET.SubElement(groups[layer], "object", {
            "id": str(next_object_id), "name": name, "class": class_name,
            "x": str(x * TILE + TILE / 2), "y": str(y * TILE + TILE / 2),
        })
        add_properties(node, values)
        ET.SubElement(node, "point")
        next_object_id += 1

    # Wreckage tells the situation without explaining it.
    for layer, asset, x, y, name in [
        ("YSortedObjects", "wreck.broken_mast", 7, 13, "MatBrise"),
        ("YSortedObjects", "wreck.torn_sail", 10, 12, "VoileDechiree"),
        ("GroundObjects", "wreck.hull_planks", 8, 15, "PlanchesEparses"),
        ("YSortedObjects", "wreck.boat_rib", 4, 17, "CoqueBrisee"),
        ("YSortedObjects", "wreck.crate", 12, 15, "CaisseFermee"),
        ("YSortedObjects", "wreck.crate_broken", 14, 17, "CaisseBrisee"),
        ("GroundObjects", "wreck.rope_coil", 10, 16, "Cordage"),
        ("YSortedObjects", "wreck.barrel_buried", 32, 17, "TonneauEnsable"),
        ("YSortedObjects", "wreck.anchor_fragment", 3, 18, "AncreBrisee"),
        ("GroundObjects", "story.corked_bottle", 28, 18, "BouteilleEchouee"),
        ("YSortedObjects", "story.travel_satchel", 17, 13, "SacocheAzeman"),
        ("GroundObjects", "story.metallic_shard", 25, 16, "EclatMetallique"),
        ("YSortedObjects", "beach.rock_movable", 26, 13, "RocherMobile"),
        ("YSortedObjects", "beach.boulder_heavy", 35, 10, "RocherLourd"),
    ]:
        add_asset(layer, asset, x, y, name)
    for x, y, asset in [
        # Wreck cluster: overlapping materials create one readable mass.
        (3, 14, "beach.driftwood_sticks"), (6, 11, "beach.driftwood_log"),
        (5, 18, "beach.shell_cluster"), (7, 17, "beach.pebble_cluster"),
        (12, 18, "beach.foam_debris"),
        # Dune clusters frame the central inland corridor.
        (2, 8, "beach.palm_sapling"), (36, 7, "beach.palm_sapling"),
        (4, 5, "beach.dune_shrub"), (10, 5, "beach.dune_shrub"),
        (28, 5, "beach.dune_shrub"), (35, 5, "beach.dune_shrub"),
        (3, 3, "beach.grass_tuft"), (8, 4, "beach.grass_tuft"),
        (14, 3, "beach.grass_tuft"), (26, 3, "beach.grass_tuft"),
        (32, 2, "beach.grass_tuft"), (38, 4, "beach.grass_tuft"),
        # Shoreline rhythm and right-hand rock cluster.
        (18, 18, "beach.shell_cluster"), (22, 18, "beach.starfish"),
        (29, 18, "beach.seaweed"), (31, 17, "beach.driftwood_sticks"),
        (34, 12, "beach.pebble_cluster"), (36, 12, "beach.grass_tuft"),
        (38, 16, "beach.tide_pool"), (36, 18, "beach.foam_debris"),
    ]:
        add_asset("YSortedObjects" if asset in {"beach.driftwood_log", "beach.palm_sapling", "beach.dune_shrub"} else "GroundObjects", asset, x, y)

    # Large, non-essential silhouettes sit partly outside the play corridor.
    # ForegroundObjects is intentionally above actors and receives a tiny
    # camera-relative offset at runtime.
    for asset, x, y, name in [
        ("beach.palm_sapling", -1, 13, "PremierPlanPalmierOuest"),
        ("beach.dune_shrub", 40, 14, "PremierPlanBuissonEst"),
        ("beach.driftwood_log", 1, 19, "PremierPlanBoisFlotte"),
        ("beach.seaweed", 39, 19, "PremierPlanAlgues"),
        ("beach.driftwood_log", 9, 20, "PremierPlanEpaveProche"),
        ("beach.seaweed", 31, 20, "PremierPlanAlguesProches"),
    ]:
        add_asset("ForegroundObjects", asset, x, y, name)

    # Authoritative gameplay geometry.
    add_rect("CollisionOverrides", "SeaBoundary", "solid", 0, 20*TILE, WIDTH*TILE, 10*TILE, {"surface": "sea", "traversal": "blocked"})
    add_polygon("CollisionOverrides", "DunesWest", "solid", [
        (0, 0), (17*TILE, 0), (17*TILE, 3*TILE), (16.25*TILE, 4*TILE), (16.25*TILE, 5*TILE), (0, 5*TILE),
    ], {"surface": "dune", "traversal": "blocked", "precision": "authored_polygon"})
    add_polygon("CollisionOverrides", "DunesEast", "solid", [
        (23*TILE, 0), (WIDTH*TILE, 0), (WIDTH*TILE, 5*TILE), (23.75*TILE, 5*TILE), (23.75*TILE, 4*TILE), (23*TILE, 3*TILE),
    ], {"surface": "dune", "traversal": "blocked", "precision": "authored_polygon"})
    add_rect("CollisionOverrides", "WorldBoundaryNorth", "solid", 0, -TILE, WIDTH*TILE, TILE, {"boundary": True})
    add_rect("CollisionOverrides", "WorldBoundarySouth", "solid", 0, HEIGHT*TILE, WIDTH*TILE, TILE, {"boundary": True})
    add_rect("CollisionOverrides", "WorldBoundaryWest", "solid", -TILE, 0, TILE, HEIGHT*TILE, {"boundary": True})
    add_rect("CollisionOverrides", "WorldBoundaryEast", "solid", WIDTH*TILE, 0, TILE, HEIGHT*TILE, {"boundary": True})
    add_rect("HeightZones", "BeachLevel", "height_zone", 0, 0, WIDTH*TILE, HEIGHT*TILE, {"height_level": 0})

    add_point("SpawnPoints", "AzemanAwakening", "player_spawn", 20, 15, {"spawn_id": "beach-awakening", "facing": "south"})
    add_point("Entities", "PierreEtrangeSpawn", "psychokinetic_object", 23, 14, {"entity_id": "practice-stone", "scene_path": "res://game/entities/psychokinetic/practice_stone.tscn"})
    add_rect("Exits", "InlandPathExit", "exit", 17*TILE, 0, 6*TILE, 2*TILE, {"target_map": "future-inland-path", "target_spawn": "beach-return"})
    add_rect("Interactions", "SatchelClue", "inspect", 17*TILE, 12*TILE, 2*TILE, 2*TILE, {"interaction_id": "azeman-satchel", "prompt": "Examiner la sacoche"})
    add_rect("Interactions", "MetallicShardClue", "inspect", 24*TILE, 15*TILE, 2*TILE, 2*TILE, {"interaction_id": "metallic-shard", "prompt": "Examiner l'éclat"})
    add_rect("Interactions", "TelekinesisDiscovery", "power_discovery", 22*TILE, 13*TILE, 3*TILE, 3*TILE, {"interaction_id": "first-telekinesis", "power_id": "telekinesis", "prompt": "Tendre la main"})
    add_rect("CameraZones", "WorldCameraBounds", "camera_zone", 0, 0, WIDTH*TILE, HEIGHT*TILE, {"limit_left": 0, "limit_top": 0, "limit_right": WIDTH*TILE, "limit_bottom": HEIGHT*TILE, "zoom": 1.0, "priority": 0, "offset_x": 0.0, "offset_y": 0.0})
    add_rect("CameraZones", "AwakeningCameraZone", "camera_zone", 14*TILE, 10*TILE, 13*TILE, 9*TILE, {"limit_left": 0, "limit_top": 0, "limit_right": WIDTH*TILE, "limit_bottom": HEIGHT*TILE, "zoom": 1.0, "priority": 10, "offset_x": 0.0, "offset_y": 24.0})

    root.set("nextobjectid", str(next_object_id))
    ET.indent(root, space=" ")
    tree.write(OUTPUT, encoding="utf-8", xml_declaration=True)
    assert_map_contract(OUTPUT)
    print(f"Plage Tiled créée : {OUTPUT.relative_to(ROOT)} — {next_object_id - 1} objets et zones")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
