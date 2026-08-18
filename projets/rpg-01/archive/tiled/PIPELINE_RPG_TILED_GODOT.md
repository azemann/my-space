# Pipeline RPG — atlas, Tiled et Godot

> **Statut après remise à zéro :** ce document est une méthode conservée, pas la
> description d'un jeu déjà implémenté. Aucun TMX, TSX, tileset ou niveau n'est
> actuellement livré dans `rpg-01`.

## Contrat canonique

Le pipeline du RPG sépare trois responsabilités :

```text
PNG + manifeste de grille
        ├──────────────► TileSet Godot      ← sémantique canonique
        └──────────────► TSX Tiled          ← miroir d'édition

TMX Tiled ─────────────► MapImported.tscn   ← placement généré
                                     │
scène Godot écrite à la main ────────┴──────► scène jouable
```

- Les PNG et leurs manifestes décrivent les pixels, la grille et les identifiants.
- Le TileSet Godot est l'autorité pour les terrains, collisions de tuile et données
  de gameplay partagées.
- Tiled peut décrire le placement d'une grande carte, ses points, zones et
  propriétés d'occurrences.
- Godot décrit la composition jouable, les scènes interactives, la navigation
  finale, le joueur, l'interface et l'exécution.
- Seule la branche `MapImported` générée depuis un TMX est remplaçable. La scène
  enveloppe Godot ne doit jamais être écrasée par l'importeur.
- `documentation/concepts/world-map-target-v001.png` reste la direction artistique.
  Elle est disponible comme calque image de référence, mais ne remplace pas les
  couches jouables.

Le dock **Pipeline RPG** est la surface de contrôle prioritaire. Il expose les
correspondances, leurs descriptions au survol et l'état `à jour`, `à régénérer`
ou `absent` en comparant le TMX à ses dérivés.

## Couches de tuiles

Chaque couche devient un `TileMapLayer` Godot. Le nom est une API stable.

| Groupe | Couches |
| --- | --- |
| `Terrain` | `Ground`, `Elevation`, `WaterEffects`, `TerrainDetails` |
| `Architecture` | `Floors`, `Bridges`, `Walls`, `Roofs` |
| `Decoration` | `Shadows`, `GroundDecor`, `Props`, `Vegetation`, `Canopy` |

Les propriétés Tiled `z_index` et `y_sort` contrôlent leur rendu dans Godot.

## Couches d'objets gameplay

| Couche | Usage |
| --- | --- |
| `Collision` | rectangles et polygones physiques indépendants de l'art |
| `Navigation` | surfaces marchables, exclusions et coûts |
| `Interactions` | portes, eau, récoltes, transitions et déclencheurs |
| `Entities` | PNJ, ennemis et objets persistants |
| `SpawnPoints` | apparition du joueur et points nommés |

Une propriété `class` Tiled est reliée à une scène ou à un adaptateur Godot par
le registre du jeu. Les noms particuliers au RPG ne doivent jamais entrer dans le
convertisseur générique.

## Méthode retenue pour les gros objets

Un futur atlas d'objets devra conserver chaque silhouette à sa taille native dans un rectangle
aligné sur 32 px. Dans Tiled, sélectionner le rectangle complet indiqué par les
propriétés `stamp_width` et `stamp_height` de sa cellule d'origine. Tiled peint les
fragments 32×32 ; leur assemblage restitue l'objet sans redimensionnement ni couture.

## Architecture cible, non créée

```text
assets/tilesets/                 PNG et JSON canoniques Godot
maps/tilesets/                   TSX générés pour Tiled
maps/world-01.tmx                source spatiale
maps/rpg-01.tiled-project        projet Tiled
addons/rpg_tiled_pipeline/       conversion générique
game/rpg/tiled/                  profil et registre propres au RPG
scenes/levels/generated/         scènes dérivées
resources/levels/generated/      données dérivées
```

## Commandes cibles, non disponibles actuellement

Ces commandes documentent l'ancien enchaînement validé. Elles ne doivent être
réintroduites qu'après définition du premier contrat jouable et recréation de
leurs scripts correspondants.

```bash
python3 tools/build_tiled_project.py
flatpak run org.mapeditor.Tiled maps/world-01.tmx
/home/evan/.local/bin/godot --headless --path . --script res://tools/import_tiled_world.gd
python3 -m unittest tests/test_world_assets.py tests/test_tiled_pipeline.py
```
