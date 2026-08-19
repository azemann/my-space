# Pipeline de génération

Ce dossier est l'atelier du projet. Il transforme les sources artistiques et
les cartes Tiled en ressources finales placées dans `game/`.

```text
sources artistiques ──> builders ──> atlas et TileSet dans game/
cartes TMX + TSX ─────> convertisseur ──> scènes dans game/world/maps/generated/
```

## Assets

- `assets/sources/` : originaux ImageGen, LMMS, références, frames et reçus de provenance ;
- `assets/builders/` : normalisation des terrains et construction des atlas d'objets ;
- `assets/player/` : extraction, validation et assemblage des sprites du joueur.

Les fichiers dans `assets/sources/` ne sont jamais chargés par le jeu. Le
fichier `.gdignore` empêche également Godot de les importer.

## Cartes Tiled

- `tiled/maps/source/` : TMX maîtres ;
- `tiled/maps/templates/` : gabarit contractuel d'une nouvelle carte ;
- `tiled/maps/tilesets/` : adaptateurs TSX vers le TileSet Godot ;
- `tiled/tools/` : création, validation, export et conversion.

Le placement se corrige dans le TMX. Les scènes sous
`game/world/maps/generated/` sont des sorties et ne se modifient pas à la main.

## Commandes principales

Depuis la racine du projet :

```bash
python3 pipeline/assets/builders/normalize_terrain.py
python3 pipeline/assets/builders/normalize_beach_terrain.py
python3 pipeline/assets/builders/build_world_objects.py
python3 pipeline/assets/builders/build_beach_objects.py
python3 pipeline/assets/player/build_player_sheet.py
godot --headless --path . --script res://pipeline/assets/player/build_player_resources.gd
godot --headless --path . --script res://pipeline/assets/builders/build_tileset.gd
godot --headless --path . --script res://pipeline/assets/builders/build_item_catalog.gd
python3 pipeline/tiled/tools/export_tilesets.py
python3 pipeline/tiled/tools/map_contract.py
godot --headless --path . --script res://pipeline/tiled/tools/convert_all.gd
```

Les tests Python se lancent avec :

```bash
python3 -m unittest discover -s pipeline/tests -p 'test_*.py' -v
```
