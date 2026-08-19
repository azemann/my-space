# Architecture des fichiers

## Autorité active

- `game/` est le produit final : scènes, scripts runtime, ressources importées,
  TileSet et cartes converties utilisées par Godot ;
- `pipeline/` est l'atelier : sources artistiques, constructeurs, cartes Tiled,
  convertisseurs et tests ;
- `pipeline/assets/sources/` contient les fichiers lourds ou intermédiaires de création
  et reste exclu de l'import Godot grâce à son `.gdignore` ;
- `docs/` contient les contrats et explications actifs ;
- `archive/` conserve l'historique sans être chargé par Godot.

La frontière est directionnelle : le pipeline lit ses sources et produit des
fichiers dans `game/`. Le runtime ne charge jamais une source de `pipeline/`.

## Monde

```text
game/
├── core/                  session persistante et changement de carte
├── actors/                joueur, PNJ, ennemis et composants d'acteur
├── content/               définitions et représentations runtime du contenu
├── systems/               caméra, sauvegarde, quêtes, audio, transitions
├── ui/                    HUD et menus persistants
└── world/                 cartes et TileSet du monde
```

Une fonctionnalité globale n'est jamais placée dans une carte. Une carte ne
contient que ce qui disparaît réellement lorsqu'on la quitte : décor, collisions,
zones, objets placés, rencontres et logique strictement locale.

```text
game/world/
├── maps/
│   ├── generated/          scènes dérivées des TMX, lecture seule
│   └── <identifiant>/      scènes maîtresses et logique locale éditables
└── tileset/
    ├── world_tileset.tres
    ├── terrain/
    │   ├── terrain_atlas.png
    │   ├── terrain_catalog.json
    │   └── families/
    └── objects/
        ├── objects_atlas.png
        ├── objects_catalog.json
        └── naming_catalog.json
```

```text
pipeline/
├── assets/
│   ├── builders/           génération des atlas de terrain et d'objets
│   ├── player/             génération de la planche et des animations du joueur
│   └── sources/            images, audio de travail, références et provenance
├── tiled/
│   ├── tools/              création, validation, export TSX et conversion Godot
│   └── maps/
│       ├── source/         cartes TMX à éditer dans Tiled
│       ├── templates/      contrat initial des calques RPG
│       └── tilesets/       adaptateurs TSX vers le TileSet Godot
└── tests/                  vérifications Python et Godot
```

Une carte Tiled possède un TMX maître et une scène `.tscn` dérivée. Elle ne
duplique jamais le TileSet du monde. Les comportements propres à la carte
seront composés dans une scène Godot distincte qui instancie la scène générée.

Le joueur n'est pas enregistré dans une carte. `GameRoot` le rattache au
`actor_parent_path` de la carte active et le place sur un `spawn_id`. La caméra
et l'interface restent également enfants du socle persistant.

## Interdictions

- aucune version `v001`, `v005` ou `candidate` dans les chemins actifs ;
- aucune modification manuelle dans `game/world/maps/generated/` ;
- aucune dépendance active vers `archive/` ou `pipeline/assets/sources/` ;
- aucun fichier runtime nouveau directement à la racine de `pipeline/` ;
- aucun atlas mêlant source artistique et ressource prête pour Godot.
