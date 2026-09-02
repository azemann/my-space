# Cahier de vocabulaire — Serre mécanique

Ce document fixe les termes utilisés dans Tiled, le convertisseur et Godot.

## Distinguer les éléments visuels

Dans ce projet, **tuile** garde un sens précis : un élément destiné à être placé
sur une grille par un `TileMapLayer`. Une arme n'est donc pas une tuile ; c'est un
objet de gameplay qui possède notamment un sprite et une définition de données.

| Terme précis | Sens dans le projet | Exemple |
|---|---|---|
| asset | terme général pour un fichier utilisé par le jeu | PNG, son, police, modèle |
| texture | image chargée et utilisable par Godot | PNG du pistolet-grappin |
| sprite | représentation 2D affichée à partir d'une texture | dessin du pistolet tenu en main |
| tuile | image modulaire placée sur la grille d'un niveau | morceau de sol de 32 × 32 px |
| TileSet | bibliothèque de tuiles avec terrains et données | jeu de tuiles de la serre |
| atlas | grande texture découpée en plusieurs régions | planche contenant décor et accessoires |
| spritesheet | planche ordonnée contenant plusieurs sprites ou frames | huit poses d'un personnage |
| frame | une image d'une animation | frame de recul du pistolet |
| tuile animée | tuile du TileSet qui fait défiler plusieurs frames | eau ou engrenage répétitif |
| sprite animé | animation d'un objet indépendant du TileMap | arme qui tire ou porte qui s'ouvre |
| icône | représentation prévue pour l'interface | miniature du grappin dans l'inventaire |
| effet visuel (VFX) | animation temporaire sans identité d'objet | étincelle, fumée, impact |
| skin | remplacement visuel conservant le même comportement | version cuivre du grappin |
| variante | version modifiée d'un élément, visuelle ou fonctionnelle | grappin long mais plus lent |

## Distinguer visuel, objet et comportement

| Terme | Rôle |
|---|---|
| scène Godot | structure réutilisable de nœuds qui forme un objet complet |
| objet de gameplay | élément ayant un rôle dans les règles du jeu |
| `Resource` | données réutilisables sans représentation autonome dans le niveau |
| script | comportement et règles exécutées |
| collision | forme physique, distincte du dessin visible |

Exemple précis pour une arme :

```text
texture PNG → Sprite2D → scène de l'arme
                         + WeaponDefinition (données)
                         + script (comportement)
                         + collision éventuelle
```

Si le mot « tuile » est utilisé pour une arme, un personnage ou un objet autonome,
nous le reformulerons avec le terme exact au lieu de conserver l'ambiguïté.

## Calques d'objets

La propriété de calque `godot_role` décide de la conversion principale.

| `godot_role` | Usage | Résultat Godot |
|---|---|---|
| `collision` | géométrie physique | `StaticBody2D` et formes de collision |
| `gameplay` | mouvements, dangers, entités, interactions | zones ou repères actifs |
| `zone` | déclencheurs techniques | `Area2D` générique |
| `camera` | limites et changements de cadrage | zones techniques désactivées par défaut |
| `audio` | ambiances et transitions sonores | zones techniques désactivées par défaut |
| `object` | repères et chemins libres | `Marker2D` ou `Area2D` générique |

Un calque peut aussi définir `z_index`, `y_sort`, visibilité, opacité et décalage.

## Formes d'objets

| Forme Tiled | Usage conseillé | Conversion Godot |
|---|---|---|
| rectangle | sols, plateformes, zones | `RectangleShape2D` |
| ellipse | volumes ronds ou ovales | polygone convexe à 16 sommets |
| polygone | pentes et volumes irréguliers fermés | `CollisionPolygon2D` |
| polyligne | murs irréguliers et chemins | suite de `SegmentShape2D` |
| point | apparitions et repères | `Marker2D` ou petite zone configurable |

## Types de collision et mouvement

| Type | Sens |
|---|---|
| `solid` | collision pleine |
| `wall` | mur, notamment sous forme de polyligne |
| `slope` | pente polygonale |
| `one_way` | plateforme traversable par-dessous |
| `grapple_surface` | surface physique dédiée à l'accroche du grappin |
| `climbable` | échelle, chaîne ou liane escaladable |
| `bounce` | impulsion verticale, propriété `impulse_y` |
| `conveyor` | surface mobile, propriété `speed_x` |
| `wind` | force de zone, propriétés `force_x` et `force_y` |
| `slow_zone` | ralentissement, propriété `speed_factor` |

## Types de gameplay

| Type | Sens |
|---|---|
| `player_spawn` | apparition initiale du joueur |
| `enemy_spawn` | apparition d'un ennemi, propriété `archetype` |
| `npc_spawn` | apparition d'un PNJ, propriété `dialogue_id` |
| `checkpoint` | nouveau point de réapparition |
| `collectible` | objet ramassable, propriété `value` |
| `hazard` | danger, propriétés `damage` et `respawn` |
| `death_zone` | réapparition immédiate |
| `interactable` | action volontaire, propriétés `action` et `target` |
| `trigger` | événement au contact, propriété `event` |
| `exit` | fin de niveau, propriété `next_level` |
| `transition` | passage vers une autre zone, propriété `target` |
| `water` | volume aquatique, propriétés libres pour la nage et la flottabilité |

## Types techniques

| Type | Sens |
|---|---|
| `camera_bounds` | limites de déplacement de la caméra |
| `camera_focus` | zone de cadrage, propriétés `priority` et `zoom` |
| `audio_zone` | ambiance locale, propriétés `snapshot` et `fade_time` |
| `marker` | repère libre sans volume physique |
| `path` | chemin en polyligne, propriété `loop` |

Ces objets techniques sont déjà convertis et leurs propriétés sont conservées. Leur
comportement final (caméra, mixage audio, patrouille ou nage) pourra être branché plus
tard sans refaire les cartes.

## Propriétés communes

| Propriété | Effet |
|---|---|
| `collision_layer` | couche physique Godot |
| `collision_mask` | masque physique Godot |
| `enabled` | active ou désactive la forme |
| `one_way_margin` | tolérance d'une plateforme à sens unique |
| `trigger_width`, `trigger_height` | taille d'une zone créée depuis un point |
| `z_index` | ordre d'affichage |
| `monitoring`, `monitorable` | activation d'une zone technique |
| `grapple_enabled` | autorise le grappin sur une collision d'un autre type |

## Vocabulaire d'édition Godot

| Terme | Sens dans le projet |
|---|---|
| objet réutilisable | scène de `scenes/objects/` qui porte le comportement commun |
| instance | exemplaire placé dans un niveau, avec sa position et sa collision locales |
| géométrie locale | forme propre à un niveau, modifiable sans changer les autres instances |
| niveau figé | scène Godot qui ne sera pas remplacée par le convertisseur Tiled |
| scène générée | résultat du convertisseur ; sa source de vérité reste le fichier TMX |
| rendre unique | dupliquer une ressource partagée avant de la modifier pour une seule occurrence |

## Vocabulaire de production des tilesets

| Terme | Sens dans le projet |
|---|---|
| planche conceptuelle | proposition artistique ImageGen, jamais chargée directement dans le jeu |
| atlas de production | PNG final validé, placé dans `assets/tilesets/` |
| tuile modulaire | case destinée à se raccorder à une voisine : terrain, eau, plateforme, tuyau ou connecteur |
| objet isolé | sprite autonome qui peut conserver une marge transparente |
| raccord alpha | continuité de la transparence et de la silhouette sur les bords |
| raccord RGB | continuité des couleurs entre les pixels des bords voisins |
| contour interne | bordure peinte dans une case ; même opaque, elle produit une couture visible et est interdite sur une tuile modulaire |
| contrat de production | validation des dimensions, rôles, masques, raccords RGB et absence de contour avant utilisation dans Tiled |

Toutes les propriétés non reconnues restent conservées comme métadonnées Godot.
Elles peuvent donc être exploitées ultérieurement sans devoir modifier la carte.

## Commandes configurables

Les scripts de gameplay utilisent exclusivement des actions `InputMap`. Une
touche physique n'est jamais une règle de gameplay : elle est seulement
l'affectation modifiable d'une action stable.

| Action Godot | Sens | Touches par défaut |
|---|---|---|
| `move_left` | déplacement ou balancement vers la gauche | Q, A, ← |
| `move_right` | déplacement ou balancement vers la droite | D, → |
| `jump` | saut et décrochage du grappin | Espace |
| `climb_up` | montée sur un objet `climbable` | Z, W, ↑ |
| `climb_down` | descente sur un objet `climbable` | S, ↓ |
| `weapon_primary` | utilisation de l'arme équipée | clic gauche |
| `rope_reel_in` | raccourcissement de la corde | Z, W, ↑ |
| `rope_reel_out` | allongement de la corde | S, ↓ |
| `weapon_menu` | ouverture ou fermeture de l'arsenal | Tab |
| `weapon_cancel` | fermeture de l'arsenal | Échap |
| `weapon_holster` | ranger ou ressortir le dernier équipement | C |
| `weapon_slot_1` à `weapon_slot_9` | sélection directe d'une arme | 1 à 9 |
| `respawn` | retour au point d'apparition | R |

Les actions sont modifiables dans Godot via **Projet → Paramètres du projet →
Plan des entrées (Input Map)**. Modifier une touche à cet endroit ne nécessite
aucune modification des scripts. Les actions qui partagent une touche par défaut,
comme `climb_up` et `rope_reel_in`, restent indépendantes et pourront être
reconfigurées séparément.

Un futur menu « Commandes » utilisera les mêmes actions avec
`InputMap.action_erase_events()` et `InputMap.action_add_event()`. Le test des
contrôles vérifie déjà qu'une affectation peut être remplacée à l'exécution ; la
sauvegarde des choix du joueur sera ajoutée avec cette interface.

## Utilisation du gabarit

Dupliquer `maps/gabarits/niveau-02-gabarit.tmx`, lui donner le vrai nom du niveau,
puis placer la copie directement dans `maps/` lorsqu'elle doit être régénérée par
Godot. Les objets nommés `exemple_*` sont des modèles : les dupliquer, les adapter,
puis supprimer ceux qui ne servent pas au niveau.

Le dossier `maps/gabarits/` n'est pas parcouru automatiquement par la commande de
régénération. Le niveau 1 figé reste donc intact et le gabarit ne devient pas un
niveau jouable par accident.
