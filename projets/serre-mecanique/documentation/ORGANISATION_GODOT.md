# Organisation du projet dans Godot

## Le panneau `Serre`

Le plugin **Gestion Serre + Import Tiled** ajoute un panneau `Serre` dans les
docks de gauche de Godot. Pour chaque niveau, il donne accès à trois boutons :

- **Tester ▶** lance immédiatement la scène complète avec le joueur ;
- **Scène** ouvre le décor du niveau ;
- **Source** sélectionne le fichier TMX responsable dans le dock FileSystem.

Le bouton de régénération affiche toujours une confirmation détaillée avant de
remplacer les fichiers générés.

## Source de vérité

| Élément | Où le modifier | Où ne pas le modifier |
|---|---|---|
| Niveau 1 figé | `scenes/levels/niveau-01-serre.tscn` | son ancien TMX n'est plus régénéré |
| Objets réutilisables N1 | leurs instances dans `niveau-01-serre.tscn` | ne pas détacher la scène héritée |
| Niveau 2 | `maps/niveau-02-racines.tmx` dans Tiled | `scenes/levels/niveau-02-racines.tscn` |
| Niveau 3 | `maps/niveau-03-automates.tmx` dans Tiled | `scenes/levels/niveau-03-automates.tscn` |
| Niveau 4 | `maps/niveau-04-arene-parcours.tmx` dans Tiled | `scenes/levels/niveau-04-arene-parcours.tscn` |
| Parcours et collisions N2 | calques d'objets du TMX | scène Godot générée |
| Visuel N2 | calques de tuiles du TMX | ressource `.tres` générée |
| Joueur | `scenes/player/` et `game/serre/actors/player.gd` | scènes de niveau |
| Réglages du joueur | `resources/characters/` | script du niveau |
| Interactions partagées | `resources/interactions/` | chaque zone générée |
| Armes et équipements | `resources/weapons/` et `assets/weapons/` | script de déplacement du joueur |
| Caméra | `resources/camera/` | chaque niveau séparément |
| Matériaux physiques | `resources/physics/` | formes générées |
| Code générique | `addons/my_space_core/` | `game/serre/` |
| Conversion Tiled générique | `addons/tiled_level_pipeline/` | profil et panneau Serre |
| Code du jeu | `game/serre/` | dossiers génériques |

## Arborescence utile

```text
addons/my_space_core/  briques Godot réutilisables entre plusieurs jeux
addons/tiled_level_pipeline/ convertisseur TMX/TSX sans connaissance de Serre
addons/serre_editor/   panneau de gestion propre à Serre mécanique
game/serre/            gameplay, profil Tiled, outils et migrations du jeu
assets/tilesets/       images PNG et définitions TSX
maps/                  niveaux de production édités dans Tiled
maps/gabarits/         modèles non régénérés automatiquement
scenes/levels/         scènes de décor, générées sauf niveau 1 figé
scenes/launchers/      scènes complètes à lancer avec le joueur
scenes/player/         joueur réutilisable
scenes/objects/        objets de gameplay instanciés depuis les types Tiled
resources/levels/      données générées de chaque niveau
resources/tilesets/    TileSet Godot générés
resources/interactions réglages communs des objets de gameplay
resources/weapons/     définitions des armes et outils équipables
assets/weapons/        sprites des armes et outils
documentation/         règles du projet et vocabulaire
tests/                 contrôles automatiques Godot
```

## Routine recommandée pour le niveau 2

1. Ouvrir `maps/niveau-02-racines.tmx` dans Tiled.
2. Modifier les tuiles, collisions ou objets et enregistrer dans Tiled.
3. Revenir dans Godot et utiliser **Régénérer les niveaux Tiled…** dans le
   panneau `Serre`.
4. Lire la confirmation, puis accepter.
5. Cliquer sur **Tester ▶** : le panneau lance directement
   `scenes/launchers/niveau-02.tscn` avec le joueur.

Un même niveau peut employer plusieurs TSX : Tiled attribue à chacun un
`firstgid` et le convertisseur crée autant d'atlas dans le TileSet Godot. Les
noms des calques de tuiles doivent en revanche rester uniques, car ils deviennent
des nœuds Godot et servent aux contrôles de fidélité.

## Enregistrement

Une modification faite directement dans l'éditeur Godot doit être enregistrée
avec `Ctrl+S`. Dès que Godot l'a écrite sur disque, elle est visible par les
outils du projet. Le niveau 2 fait exception : ses changements de décor doivent
être enregistrés dans Tiled, car sa scène Godot sera remplacée à la prochaine
régénération.

Dans le niveau 1, les objets de gameplay sont maintenant des instances des scènes
de `scenes/objects/`. Leurs positions et leurs CollisionShape2D locales restent
éditables dans le niveau. Pour changer le comportement de toutes les échelles,
portes ou graines, ouvrir plutôt leur scène réutilisable.

## Ajouter un futur niveau

1. Dupliquer le gabarit TMX dans `maps/`.
2. Lui donner un nom `niveau-NN-<nom>.tmx`.
3. Lui attribuer son TSX dédié.
4. L'ajouter à la constante `LEVELS` du plugin pour qu'il apparaisse dans le
   panneau `Serre`.
5. Régénérer, puis créer une scène de lancement sur le modèle de
   `scenes/launchers/niveau-02.tscn`.
