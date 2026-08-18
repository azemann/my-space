# Réglages globaux Godot

Ce document recense les autorités peu visibles qui peuvent modifier tout le
jeu. Elles doivent être contrôlées lors de l'ajout d'un système, même si la
fonctionnalité paraît locale à une carte.

| Domaine | Autorité | Contrôle de cohérence |
| --- | --- | --- |
| scène de démarrage | `project.godot` | pointe vers `game/core/main.tscn` |
| résolution et pixel art | `project.godot` | viewport 640×360, échelle entière, filtre global nearest |
| entrées | `project.godot` et `PlayerConfig` | actions déclarées et noms identiques au profil joueur |
| collisions | noms des calques dans `project.godot` | Monde solide, Acteurs, Interactions, Déclencheurs |
| mixage | `default_bus_layout.tres` | `SFX`, `Psychokinesis` et `Ambience` envoient vers une autorité existante |
| surfaces | données personnalisées du `world_tileset.tres` | `terrain_kind` reste la clé commune aux effets de sol |
| imports | fichiers `.import` et réglages d'import Godot | boucle audio explicite, textures pixel art sans mipmaps |
| joueur persistant | groupe Godot `player_actor` | une seule autorité résolue par les systèmes de carte |
| budget d'exécution | `game/config/runtime_budget.tres` | fluidité, nœuds, cibles psychokinétiques actives et effets temporaires |
| caméra pixel-perfect | `game/systems/camera/camera_config.tres` | position finale entière et niveaux de zoom autorisés |

Les valeurs artistiques et de gameplay doivent vivre en priorité dans une
scène `.tscn`, une ressource `.tres`, un `TileSet`, un bus ou une propriété de
l'Inspecteur. Un script orchestre ces autorités mais ne doit pas dupliquer
leurs valeurs en constantes cachées.

## Principe d'activité à la demande

Une capacité ne justifie pas un traitement permanent. Les objets de la plage
restent psychokinétiques, détectables et persistants, mais suspendent leurs
callbacks GDScript lorsqu'ils dorment. Le contrôleur interroge l'index spatial
du moteur sur le calque `Interactions` et ne considère que les corps dans son
rayon. Les limites acceptables sont éditables dans `runtime_budget.tres` et
vérifiées par `verify_runtime_budget.gd`.

## Contrat de caméra pixel-perfect

La caméra peut lisser sa cible et conserver son anticipation, mais sa position
finale est arrondie dans le viewport logique. Les zones demandent uniquement
un niveau présent dans `pixel_perfect_zoom_levels`; la plage et la vallée
emploient actuellement `1.0`. En mode pixel-perfect, les transitions continues
de zoom sont désactivées afin d'éviter les tailles de pixels intermédiaires.
