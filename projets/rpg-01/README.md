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
Les surfaces animées suivent le
[pipeline d'animations environnementales](docs/architecture/ENVIRONMENT_ANIMATION_PIPELINE.md).
L'état réel du prototype, les risques globaux et leur ordre de correction sont
tenus dans [l'audit de cohérence du prototype](docs/audits/PROTOTYPE_GAMEPLAY_AUDIT_2026-08-18.md).

## Arborescence active

```text
game/core/                point d'entrée et orchestration de la partie
game/actors/              acteurs persistants et leurs configurations
game/systems/             systèmes réutilisables indépendants des cartes
game/world/tileset/       TileSet, terrains et objets utilisés par Godot
game/world/maps/          scènes générées et scènes de carte éditables
editor/builders/          reconstruction déterministe des atlas et du TileSet
editor/tiled/             création et conversion déterministe des cartes Tiled
editor/tests/             contrôles automatiques
maps/source/              cartes TMX maîtres
maps/templates/           modèle de carte RPG
maps/tilesets/            correspondances TSX vers les sources Godot
source-art/               références et sources ImageGen, hors import Godot
docs/                     contrats actifs, hors import Godot
archive/                  prototypes conservés mais inactifs
```

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
