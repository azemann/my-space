# Tiled → Godot

Tiled est un éditeur spatial optionnel. Le TileSet Godot reste l'autorité des
images, ancres, collisions et métadonnées.

## Correspondance des objets de gameplay

Tiled compose la carte, mais ne définit pas le comportement. Un objet marqué
`psychokinesis_response=movable` devient une instance liée de
`res://game/world/objects/psychokinetic_prop.tscn`.

Dans Tiled, modifier uniquement le placement et les propriétés prévues par le
contrat : rôle, masse, matière, niveau requis, identifiant persistant et ordre
de rendu. Dans Godot, modifier la scène canonique pour changer la structure ou
le comportement commun de tous ces objets.

Une scène générée peut être inspectée et testée, mais pas corrigée directement :
une nouvelle conversion remplacerait ces corrections. Les descriptions de
l'éditeur rappellent l'autorité de chaque nœud et de chaque calque important.

La propriété booléenne `psychic_concealed=true` peut documenter un objet
volontairement caché. Elle est conservée à la conversion, mais le socle actuel
ne lui associe aucune détection spéciale : cette future mécanique devra être
implémentée séparément du survol ordinaire.

## Créer une carte

```bash
python3 editor/tiled/create_map.py village-01
```

La carte apparaît dans `maps/source/village-01.tmx`. Elle contient déjà les
groupes Terrain, Water, Relief, Architecture, Decoration, PlacedObjects et
Gameplay, ainsi que les versions de contrat attendues. Une carte créée depuis
ce modèle n'est toutefois jouable qu'après ajout des quatre limites physiques,
d'au moins un spawn et d'une zone caméra.

## Valider le gameplay spatial

```bash
python3 editor/tiled/map_contract.py maps/source/village-01.tmx
```

La conversion Godot applique également ce contrôle et refuse toute carte sans
bords physiques, spawn unique, zone caméra complète ou transition de hauteur
mal définie.

## Convertir toutes les cartes

```bash
godot --headless --path . --script res://editor/tiled/convert_all.gd
```

Les scènes dérivées sont écrites dans `game/world/maps/generated/`. Elles ne
doivent jamais être modifiées manuellement : toute correction spatiale retourne
dans le TMX.

Le convertisseur travaille en deux passes : il analyse et valide d'abord toutes
les cartes, puis seulement il écrit les scènes. Une carte invalide ne laisse
donc pas un monde à moitié régénéré.

## Correspondance des TileSets

Les fichiers `maps/tilesets/*.tsx` portent un `godot_source_id`. Le
convertisseur traduit les GID Tiled vers la source correspondante de
`game/world/tileset/world_tileset.tres`. Il ne fabrique donc aucun TileSet
secondaire et ne perd pas les données configurées dans Godot.

Les transformations de tuiles Tiled (retournement horizontal, vertical et
diagonal) sont traduites en alternatives Godot. Les objets rectangulaires,
points, polygones, polylignes et ellipses conservent leur géométrie pour les
collisions et zones gameplay.

## Animer un calque d'environnement

Ajouter la propriété `environment_animation_profile` au calque concerné. Les
profils communs sont `water_calm`, `water_flow`, `shoreline_foam`, `lava_flow`,
`poison_swamp` et `magic_surface`. Le gabarit configure déjà les trois calques
d'eau ; chaque carte peut surcharger direction, vitesse, intensité, cadence et
phase sans modifier le shader.

Le profil anime seulement le rendu du `TileMapLayer`. Les collisions,
interactions, dégâts et règles de traversée restent dans leurs contrats dédiés.
Voir [le pipeline d'animations environnementales](architecture/ENVIRONMENT_ANIMATION_PIPELINE.md).

## Règle de traversabilité

Le décor peint ne décide jamais implicitement si le joueur passe. Le
convertisseur désactive les collisions de tous les `TileMapLayer` visuels. Deux
autorités explicites se complètent :

- les collisions du `world_tileset.tres` suivent les pieds des objets
  réutilisables : arbres, rochers, clôtures, bâtiments et garde-corps de pont ;
- `Gameplay/CollisionOverrides` contient les frontières propres à la carte :
  eau, périmètres de falaises, bords du monde et obstacles uniques.

Ainsi, retirer un segment dans `CollisionOverrides` ouvre réellement un pont ou
un escalier : aucune collision cachée du terrain peint ne subsiste dessous.

Chaque obstacle visible doit avoir une frontière continue. Chaque trou dans une
frontière doit correspondre à un passage nommé : pont, escalier, porte, portail
ou sortie. Un chemin peint sur l'eau ou une marche dessinée ne neutralise jamais
magiquement une collision voisine.

Les `Area2D` importées depuis Tiled sont placées sur la couche `Interactions` et
détectent la couche `Acteurs`. Cela concerne les portes, hauteurs, sorties,
interactions et zones caméra.

## Caméra par carte

Chaque map possède une zone `WorldCameraBounds` couvrant son espace autorisé.
Des zones plus petites peuvent la surcharger avec les propriétés :

- `priority` : la valeur la plus haute gagne en cas de chevauchement ;
- `zoom` : zoom cible avec interpolation douce ;
- `offset_x`, `offset_y` : décalage de composition ;
- `limit_left`, `limit_top`, `limit_right`, `limit_bottom` : limites locales.

La caméra reste dans `GameRoot`. Les maps décrivent seulement leur cadrage ;
elles ne créent jamais leur propre `Camera2D`.

## Poser les grands objets

`world_objects.tsx` expose les 71 maisons, ponts, clôtures, arbres, rochers,
accessoires, cultures et plantes d'eau comme collection d'images. Dans Tiled,
utiliser l'outil d'insertion de tuile et placer l'objet par son point de pied
dans l'un de ces calques :

- `ArchitectureObjects` pour maisons et ponts ;
- `BoundaryObjects` pour murs, portails et clôtures ;
- `GroundObjects` pour le décor plaqué au sol ;
- `YSortedObjects` pour arbres, rochers et accessoires ;
- `WaterObjects` pour les plantes aquatiques ;
- `ForegroundObjects` pour les éléments devant le joueur.

Chaque objet porte `object_id`, `recommended_layer`, `default_role` et ses
coordonnées dans l'atlas Godot. Le convertisseur recrée une tuile Godot
multi-cellule au même point de pied : son apparence, son ancrage et sa collision
restent donc ceux de `world_tileset.tres`. Redimensionner un objet dans Tiled est
interdit et provoque volontairement l'échec de la conversion.

Une instance dont l'état doit survivre au rechargement de la carte porte aussi
un `persistent_id`. Le convertisseur lui ajoute un enfant Godot `Persistence`
de type `PersistentWorldInstance`, identique au composant configurable dans
l'Inspecteur pour les scènes éditées directement dans Godot. À défaut de valeur
explicite, la correspondance `tiled.<id>` est employée.

`beach_objects.tsx` ajoute 30 objets littoraux et débris d'épave avec les mêmes
règles d'ancrage, de nommage et d'interdiction de mise à l'échelle par instance.
Contrairement à la bibliothèque générale, ces objets utilisent directement une
unique spritesheet 6×5 ; Tiled ne dépend donc plus de 30 images exportées une à
une.

Pour resynchroniser les TSX après une modification des familles de terrain :

```bash
python3 editor/tiled/export_tilesets.py
```

## Contrat d'autorité

- modifier le placement, les calques et les zones dans le `.tmx` ;
- modifier les images, collisions de tuiles, ancres et métadonnées dans
  `world_tileset.tres` ;
- ne jamais corriger directement une scène dans `maps/generated/` ;
- composer le gameplay spécifique dans une scène Godot distincte qui instancie
  la scène générée.
- vérifier physiquement au moins un obstacle et chaque passage exceptionnel
  avant de déclarer une map jouable.
