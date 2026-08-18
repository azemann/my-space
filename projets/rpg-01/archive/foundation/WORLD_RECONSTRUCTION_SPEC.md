# Reconstruction du monde — contrat RPG

Cette spécification reconstruit un kit de construction visuellement compatible
avec `concepts/world-map-target-v001.png`. L'image cible est uniquement une
référence de style et un exemple de vocabulaire spatial : elle ne définit ni le
gameplay, ni les collisions, ni les règles du RPG. Elle n'est jamais découpée
directement pour produire les tuiles.

Les comportements décrits ci-dessous proviennent de décisions explicites du
projet. Leur présence visuelle dans la carte de référence ne constitue jamais
une règle implicite.

## Autorité des données

| Information | Autorité | Dérivé ou miroir |
| --- | --- | --- |
| Images sources et grille 32 px | PNG + manifeste | atlas Godot, TSX Tiled |
| Sémantique d'une tuile | TileSet Godot | aperçu/propriétés Tiled |
| Composition jouable d'une scène | scène Godot | aucun |
| Placement d'une grande carte | TMX Tiled | sous-scène Godot générée |
| Interactions et état persistant | Godot | objets Tiled déclaratifs |

La conversion ne remplace que `MapImported`. La scène enveloppe écrite dans
Godot conserve le joueur, les scripts, les interactions complexes et l'état.

## Échelle

- grille logique : `32 × 32 px` ;
- origine des acteurs : centre des pieds ;
- aucune remise à l'échelle par tuile ou par occurrence ;
- les sources ImageGen peuvent recevoir une normalisation unique et documentée
  lors de la construction de l'atlas afin de respecter l'échelle du monde ;
- objets hauts : rectangles multiples de 32 px, ancrés au sol ;
- caméra et collisions testées à l'échelle 1:1 avec filtre `nearest`.

### Étalon visuel

- joueur-probe : environ 32 px de haut ;
- passage de porte : 32 px de large au minimum ;
- clôture : environ 32 à 48 px de haut ;
- petit accessoire : 1 à 2 cellules ;
- puits : environ 2 à 3 cellules ;
- arbre adulte : environ 3 cellules de large et 4 à 5 cellules de haut ;
- maison extérieure : environ 7 à 8 cellules de large ;
- aucune occurrence ne possède un `scale` correctif dans une scène.

## Arbre canonique d'une scène extérieure

```text
WorldScene
├── MapImported                       # remplaçable par le pipeline
│   ├── Terrain
│   │   ├── Ground
│   │   ├── GroundVariations
│   │   ├── Paths
│   │   ├── CultivatedSoil
│   │   └── StoneFloors
│   ├── Water
│   │   ├── WaterBase
│   │   ├── WaterBanks
│   │   ├── Waterfalls
│   │   └── WaterEffects
│   ├── Relief
│   │   ├── CliffBack
│   │   ├── CliffFaces
│   │   ├── CliffFront
│   │   └── Stairs
│   ├── Architecture
│   │   ├── Floors
│   │   ├── Bridges
│   │   ├── WallsBack
│   │   ├── Buildings
│   │   ├── Fences
│   │   └── WallsFront
│   └── Decoration
│       ├── Shadows
│       ├── GroundDecor
│       ├── PropsBack
│       ├── Vegetation
│       ├── YSortedProps
│       ├── Canopy
│       └── Foreground
├── Gameplay
│   ├── HeightZones
│   ├── ElevationTransitions
│   ├── CollisionOverrides
│   ├── Navigation
│   ├── Entrances
│   ├── Exits
│   ├── Interactions
│   ├── Entities
│   ├── SpawnPoints
│   ├── EncounterZones
│   ├── CameraZones
│   └── AudioZones
├── SceneActors
├── SceneEffects
└── SceneLogic
```

Les couches absentes restent omises. Un nom de couche présent garde toujours la
même signification dans toutes les scènes.

## Règles de hauteur et de franchissement

Le monde utilise des niveaux entiers `height_level` : `0` pour le sol de base,
`1` pour le premier plateau, etc.

1. Une face de falaise et son rebord sont bloquants par défaut.
2. Deux zones de hauteurs différentes ne communiquent jamais directement.
3. Un objet `ElevationTransition` relie explicitement `from_level` à
   `to_level`.
4. Un escalier est une transition lente bidirectionnelle.
5. Une chute éventuelle sera une transition dédiée ; elle n'est pas implicite.
6. La navigation est calculée par niveau, puis reliée seulement aux transitions.
7. Les arbres bloquent avec une petite collision autour du tronc, jamais avec
   toute leur canopée.
8. Les rochers, clôtures et murs bloquent selon leur empreinte au sol.

## Eau et ponts

- l'eau profonde porte `traversal=blocked` par défaut ;
- une berge n'est pas franchissable sans entrée dédiée ;
- un pont possède un tablier marchable et des côtés bloquants ;
- sous le pont, l'eau et ses effets restent visuels ;
- les extrémités du pont relient deux surfaces de même hauteur ;
- nage, courant, barque et pêche seront des interactions ajoutées explicitement.

## Maisons et intérieurs

Une maison extérieure est une scène réutilisable avec une `Entrance` nommée.
L'entrée référence :

- `destination_scene` : scène intérieure à charger ;
- `destination_spawn` : point d'arrivée dans l'intérieur ;
- `door_id` : identifiant stable pour sauvegarder son état ;
- `locked` et `required_key` : règles optionnelles ;
- `transition_style` : fondu, coupe ou animation.

La porte intérieure fournit la transition inverse. L'intérieur est une scène
séparée : il ne dépend pas des dimensions visuelles du toit extérieur.

## Catalogue de tuiles à reconstruire

### Lot A — sols

- herbe neutre et variantes légères ;
- chemin : centre, 4 bords, 4 angles convexes, 4 angles concaves, extrémités,
  lignes étroites, T et croisement ;
- terre cultivée : centre, bords, angles et rangées ;
- pavés : centre, bordures, angles, fissures et mousse.

### Lot B — eau

- eau animable ;
- berges droites, angles convexes/concaves et îlots ;
- écume, remous, nénuphars, roseaux et pierres ;
- cascade haute, départ, chute, impact et raccord de rivière.

### Lot C — relief

- sommet herbeux ;
- faces de falaise de 32 et 64 px ;
- rebords, angles internes/externes, piliers et terminaisons ;
- escaliers orientés nord/sud et raccords aux plateaux.

### Lot D — architecture

- maison modulaire : soubassement, murs, porte, fenêtres, toit et cheminée ;
- pont modulaire : culées, tablier, rambardes et ombres ;
- clôtures : segments, angles, extrémités, portail et poteaux ;
- puits, panneaux et petits ouvrages.

### Lot E — nature et accessoires

- conifères en plusieurs silhouettes, tronc séparé de la canopée si nécessaire ;
- buissons, hautes herbes, fleurs et cultures ;
- rochers, galets et souches ;
- tonneaux, caisses, foin, corde à linge et mobilier extérieur.

## Données personnalisées du TileSet Godot

| Nom | Type | Exemple |
| --- | --- | --- |
| `terrain_kind` | String | `grass`, `dirt`, `water`, `stone` |
| `height_level` | int | `0`, `1` |
| `traversal` | String | `walk`, `blocked`, `transition` |
| `movement_cost` | float | `1.0`, `1.25` |
| `footstep_kind` | String | `grass`, `earth`, `wood`, `stone` |
| `interaction_kind` | String | `none`, `door`, `harvest`, `water` |
| `blocks_vision` | bool | `true` pour un mur haut |
| `y_sort_origin` | int | ancrage vertical du sprite |

## Première preuve jouable

`scene_001_world_lab` doit permettre de vérifier :

- un chemin raccordé dans plusieurs directions ;
- deux niveaux de falaise ;
- un escalier comme seul passage entre eux ;
- une rivière infranchissable ;
- un pont traversable ;
- un arbre dont le tronc bloque et dont la canopée passe devant le joueur ;
- une maison avec une porte menant à une petite scène intérieure ;
- le retour à l'extérieur au bon point d'apparition.

Cette scène est validée avant d'étendre la carte complète.
