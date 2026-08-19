# RPG 01

Projet Godot construit carte après carte. Godot reste l'éditeur principal ;
Tiled sert d'éditeur spatial spécialisé lorsque la carte devient complexe.

## Point d'entrée du jeu

La scène lancée est `game/core/main.tscn`. Elle reste vivante pendant toute la
partie et possède le joueur, la caméra et l'interface. La Plage du réveil est la
carte initialement chargée dans son `WorldContainer` ; elle pourra être remplacée
par une maison, une grotte, un village ou toute autre zone sans recréer les
systèmes persistants.

La première carte du récit est
`game/world/maps/plage-du-reveil/plage-du-reveil.tscn`. Azeman s'y réveille au
bord de la mer, parmi les débris d'une épave. Son TileSet est :

`game/world/tileset/world_tileset.tres`

Ce TileSet contient 201 terrains classés en 19 familles et 101 objets nommés,
dont 80 tuiles et 30 objets propres au littoral.

Le premier joueur se trouve dans `game/actors/player/player.tscn` : 24 frames,
8 animations directionnelles et un root fixe entre les pieds.

Voir [le contrat de la plage du réveil](docs/maps/PLAGE_DU_REVEIL.md).
Voir aussi [le guide du runtime Godot](docs/architecture/GODOT_RUNTIME.md).
Le vocabulaire du code, de Godot et de Tiled est fixé par le
[glossaire du projet](docs/GLOSSAIRE.md).
La réaction de chaque asset au premier pouvoir suit le
[contrat psychokinétique](docs/contracts/PSYCHOKINESIS_CONTRACT.md).
Le sac à emplacements, ses identités stables et ses futures extensions suivent
le [contrat d'inventaire](docs/contracts/INVENTORY_CONTRACT.md).
La création de nouvelles définitions, icônes et instances ramassables suit le
[workflow des objets](docs/ITEM_AUTHORING.md).
Les idées, décisions ouvertes et futures recettes sont suivies séparément dans
le [journal de conception des objets et combinaisons](docs/design/JOURNAL_OBJETS_ET_COMBINAISONS.md).
Les surfaces animées suivent le
[pipeline d'animations environnementales](docs/architecture/ENVIRONMENT_ANIMATION_PIPELINE.md).
L'état réel du prototype, les risques globaux et leur ordre de correction sont
tenus dans [l'audit de cohérence du prototype](docs/audits/PROTOTYPE_GAMEPLAY_AUDIT_2026-08-18.md).

## Arborescence active

```text
game/                              jeu exécutable et ressources Godot finales
├── core/                          orchestration persistante de la partie
├── actors/                        acteurs et configurations
├── systems/                       systèmes réutilisables
└── world/                         cartes générées et TileSet final

pipeline/                          fabrication des ressources du jeu
├── assets/
│   ├── builders/                  construction des atlas et du TileSet
│   ├── player/                    construction des sprites du joueur
│   └── sources/                   sources ImageGen, LMMS et références
├── tiled/
│   ├── tools/                     création, validation et conversion Tiled
│   └── maps/                      TMX maîtres, modèles et adaptateurs TSX
└── tests/                         contrôles automatiques du jeu et du pipeline

docs/                              contrats et guides actifs
archive/                           prototypes conservés mais inactifs
```

Le dossier [`game/`](game/) peut être lu comme le produit final. Le dossier
[`pipeline/`](pipeline/) explique comment ce produit est fabriqué. Une ressource
générée va toujours de `pipeline/` vers `game/`, jamais dans le sens inverse.

## Règle de travail

1. créer une carte depuis le modèle Tiled ;
2. construire un petit secteur et ses calques gameplay ;
3. convertir le TMX en scène Godot ;
4. vérifier collisions, hauteurs et interactions dans Godot ;
5. corriger les placements dans Tiled et les propriétés techniques dans Godot.

Les commandes se règlent dans **Projet > Paramètres du projet > Contrôleur
d'entrées**. La vitesse et les autres valeurs du héros se règlent en sélectionnant
`player_config.tres` dans l'inspecteur ; la caméra se règle de la même façon dans
`camera_config.tres`.

Le TMX est l'autorité des placements. Le TileSet Godot est l'autorité des
images, ancres, collisions de tuiles et métadonnées. La scène générée n'est
jamais modifiée à la main. Voir [le workflow Tiled](docs/TILED_WORKFLOW.md).
