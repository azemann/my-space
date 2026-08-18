# Architecture runtime Godot

## Autorité des objets de carte

Les objets qui portent un comportement ne sont pas reconstruits comme des
sous-arbres anonymes à chaque import. Le convertisseur instancie une scène
Godot enregistrée dans
`game/world/objects/world_object_scene_registry.gd`.

Pour les accessoires manipulables, la scène canonique est
`game/world/objects/psychokinetic_prop.tscn`. Elle définit une fois pour toutes
le corps physique et cinq composants nommés : persistance, machine à états,
zone d'interaction, présentation et rendu. La surbrillance, l'ombre et les sons
ne sont plus pilotés par le `RigidBody2D`.

Tiled fournit le placement, le visuel d'atlas et les propriétés d'instance.
Godot fournit la structure, le comportement, la physique et les ressources.
Les enfants sont éditables dans l'instance générée : leurs surcharges restent
visibles dans l'inspecteur sans rompre le lien avec la scène canonique.

Chaque nœud important possède une `editor_description`. Les propriétés
exportées utilisent les commentaires `##`, affichés comme aide contextuelle
dans l'inspecteur Godot.

## Principe

`game/core/main.tscn` représente la partie en cours, pas une carte. Sa structure
est volontairement courte et visible dans l'arbre de scène :

```text
Game
├── WorldState             états d'instance conservés pendant la partie
├── WorldContainer
│   └── CurrentMap          carte remplaçable
├── PersistentActors
│   └── Player              accueil avant rattachement à la carte
├── Psychokinesis
│   ├── TargetDetector       choix d'une cible à portée
│   ├── ManipulationAnchor   destination physique visible dans l'éditeur
│   └── AimIndicator         faisceau et direction de projection
├── Camera                  caméra persistante
└── Interface
    └── HUD                 interface persistante
```

Au chargement, `GameRoot` rattache `Player` au calque Y-sort déclaré par la
carte, recherche son `spawn_id`, configure les limites de caméra puis donne le
joueur comme cible à la caméra. Lors d'un changement de carte, le même joueur
est conservé avec son futur inventaire, ses statistiques et son état de quête.

Avant de libérer une carte, `WorldStateStore` effectue une capture d'état de
chaque composant `PersistentWorldInstance`. Après l'instanciation suivante de
cette carte, il effectue la restauration d'état. Le composant se configure dans
l'Inspecteur Godot et peut être ajouté à tout `Node2D`, sans script spécifique à
l'objet. Voir le [glossaire](../GLOSSAIRE.md) pour les termes contractuels.

## Où modifier quoi dans Godot

| Besoin | Emplacement dans l'éditeur |
| --- | --- |
| Touches clavier/manette | Projet > Paramètres du projet > Contrôleur d'entrées |
| Vitesse, accélération, course | `game/actors/player/player_config.tres` |
| Collision et points d'ancrage du héros | `game/actors/player/player.tscn` |
| Animations produites par le pipeline | `game/actors/player/generated/` (lecture seule) |
| Zoom, anticipation et douceur du suivi | `game/systems/camera/camera_config.tres` |
| Cadrage propre à une zone | objets `CameraZones` de la carte Tiled |
| Carte active au démarrage | instance `CurrentMap` dans `game/core/main.tscn` |
| Persistance de session | nœud `WorldState` dans `game/core/main.tscn` |
| Portée et force psychokinétique | nœud `Psychokinesis` dans `game/core/main.tscn` |
| Détection, ancre et visée du pouvoir | enfants nommés du nœud `Psychokinesis` |
| États et présentation d'un objet | enfants `StateMachine` et `Presentation` de la scène objet |
| État persistant d'une instance | enfant `Persistence` portant `PersistentWorldInstance` |
| Décor et placements massifs | TMX dans `maps/source/`, puis conversion |
| Logique propre à une carte | `game/world/maps/<carte>/<carte>.tscn` |
| HUD et menus communs | branche `Interface` de `game/core/main.tscn` |

Les ressources `.tres` sont les panneaux de réglage du jeu : on modifie leurs
valeurs dans l'inspecteur, sans toucher au script. Les noms d'actions exportés
dans `PlayerConfig` permettent également de remplacer le profil de commandes
pour un autre personnage ou un prototype.

## Commandes initiales

| Action | Clavier | Manette |
| --- | --- | --- |
| Se déplacer | ZQSD, WASD ou flèches | stick gauche |
| Interagir | E ou Espace | bouton bas |
| Courir | Maj | bouton gauche |
| Pause | Échap | Start |

Le tactile devra uniquement produire ces mêmes actions via une future interface
mobile. Le contrôleur du joueur ne dépend donc d'aucun type de périphérique.

## Contrat minimal d'une carte

Une scène de carte éditable instancie sa scène générée sous `World` et expose :

- `level_id`, identifiant stable de la zone ;
- `actor_parent_path`, calque Y-sort qui accueille les acteurs ;
- `default_spawn_id`, entrée utilisée sans destination explicite ;
- `camera_bounds`, rectangle visible autorisé ;
- `World/Gameplay/SpawnPoints`, marqueurs nommés par leur métadonnée `spawn_id`.

Une carte ne possède ni joueur, ni caméra, ni HUD, ni gestionnaire de sauvegarde.
Ces éléments appartiennent à la partie complète et non à une scène particulière.

Le contrat auteur détaillé et ses contrôles sont décrits dans
[`MAP_AUTHORING_CONTRACT.md`](MAP_AUTHORING_CONTRACT.md).
