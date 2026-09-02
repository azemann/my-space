# Conception de la map routière responsive de Horde Brawler

## Statut

- Date : 2026-08-25
- Projet : `projets/horde-brawler`
- Décision : conception validée en conversation, à relire avant le plan d'implémentation
- Portée : première map jouable, district industriel junkpunk

## Objectif

Remplacer la route essentiellement procédurale et réglée en pixels par une vraie scène de map Godot, responsive, riche en décors et directement composable dans l'éditeur. Le système doit préserver la perspective pseudo-3D existante, rester lisible avec une horde nombreuse et rendre chaque réglage artistique ou de gameplay visible dans une `Resource` clairement identifiée.

Cette étape ne modifie pas encore la marche du joueur. Son repositionnement précis au sol sera traité après intégration et validation visuelle de la map.

## Contraintes retenues

- Godot reste l'autorité d'assemblage et de réglage du contenu.
- Les classes, fichiers et propriétés techniques utilisent l'anglais.
- Les descriptions, catégories et infobulles de l'Inspecteur sont en français.
- La géométrie s'adapte au viewport visible et non à une largeur fixe de 1280 pixels.
- La route jouable est plafonnée sur écran ultrawide ; l'espace supplémentaire appartient au décor.
- La map doit accepter beaucoup d'assets sans réduire la lisibilité du joueur, des ennemis et des attaques.
- Une propriété réglable possède une seule autorité. Il ne doit pas exister de copie silencieuse dans une scène ou un script.
- L'aperçu éditeur et l'exécution utilisent les mêmes fonctions de projection.

## Direction artistique

La première map est un district industriel junkpunk : route sombre, métal récupéré, rouille, jaune chantier, accents turquoise, signalétique improvisée, tours, passerelles et machines. La direction reste expressive et colorée plutôt que réaliste.

La hiérarchie visuelle est la suivante :

1. Le joueur conserve la silhouette permanente la plus forte.
2. Les ennemis restent reconnaissables au milieu de la horde.
3. Les attaques et impacts reçoivent le contraste temporaire maximal.
4. Le centre de la chaussée reste plus calme, moins détaillé et moins saturé.
5. Les côtés concentrent les grands décors et la richesse d'assets.
6. Les éléments éloignés sont moins contrastés et légèrement désaturés.

Chaque segment privilégie un élément majeur, quelques groupes secondaires et des espaces de respiration. Les motifs récurrents sont la tôle, les boulons, les matériaux attachés, la peinture bleue, la rouille et la signalétique de chantier. Les néons cyberpunk arbitraires et les textures photoréalistes sont hors direction.

Le concept visuel n'est pas utilisé comme une image de fond aplatie. Il est décomposé en ciel, silhouettes industrielles, plans lointains, bordures de route, accessoires proches et avant-plan.

## Structure de scène

La map existe comme une scène principale nommée `Map01Industrial.tscn` :

```text
Map01Industrial
├── Backdrop
├── FarDecor
├── RoadSurface
├── LeftRoadside
│   └── RoadSegment2D...
├── RightRoadside
│   └── RoadSegment2D...
├── NearForeground
├── GameplaySockets
└── RoadMapController
```

`Backdrop` et `FarDecor` peuvent employer `Parallax2D`, car ils ne participent ni aux collisions ni à la géométrie jouable. Les éléments proches de la route utilisent la projection de `RoadLayoutData` afin de rester alignés avec le trapèze.

`RoadSurface` dessine la chaussée, les accotements et les marquages. Les deux groupes `Roadside` contiennent de vraies scènes composées manuellement. `NearForeground` reçoit les éléments pouvant passer devant la caméra. `GameplaySockets` rend visibles les points destinés aux ennemis, obstacles ou objets ramassables.

## Responsabilités et correspondances Godot

### Scripts et scènes publiques

| Classe | Fichier | Responsabilité |
|---|---|---|
| `RoadMapController` | `maps/road_map_controller.gd` | progression unique, résolution du viewport, recyclage et orchestration |
| `RoadSegment2D` | `maps/road_segment_2d.gd` | segment composé dans l'éditeur et placé dans la progression |
| `RoadsideProp2D` | `maps/roadside_prop_2d.gd` | ancrage d'un décor à une position logique de la route |
| `GameplaySocket2D` | `maps/gameplay_socket_2d.gd` | point visible de contenu jouable futur |

Chaque script public déclare un `class_name`. Chaque racine de scène reçoit un `editor_description` en français et un nom PascalCase explicite.

### Resources principales

| Resource | Fichier | Autorité |
|---|---|---|
| `RoadMapData` | `maps/road_map_data.gd` | identité, références, vitesse globale, influence sur le flux ennemi, profil de densité et graine |
| `RoadLayoutData` | `maps/road_layout_data.gd` | géométrie responsive, perspective, projection et zone du joueur |
| `RoadThemeData` | `maps/road_theme_data.gd` | palette, matériaux, marquages, profondeur visuelle et profils de densité |
| `RoadSegmentData` | `maps/road_segment_data.gd` | scène, longueur logique, poids de sélection, transitions et métadonnées d'un segment |

La Resource principale `industrial_district_map.tres` référence une `RoadLayoutData`, une `RoadThemeData` et un tableau de `RoadSegmentData`. Elle expose également `scroll_speed`, `enemy_flow_ratio`, `density_profile` et la graine de sélection.

Il n'existe pas de `RoadsidePropData` dans la première version. Un prop décoratif simple est une `PackedScene` dont la racine porte `RoadsideProp2D`. Une Resource supplémentaire ne sera créée que si plusieurs props ont réellement besoin de partager un ensemble durable de statistiques. Les réglages de `GameplaySocket2D` vivent également sur le nœud au départ.

## Autorité unique et absence de réglages invisibles

Les règles suivantes sont obligatoires :

1. Toute valeur partagée qui règle le rendu, le gameplay ou les performances de la map est exportée dans l'une des quatre Resources. Les nœuds de composition ne portent que leurs données propres à l'instance, par exemple position logique, scène associée, socket ou niveau minimal de densité.
2. Une valeur dérivée, telle qu'une largeur résolue en pixels logiques, est calculée à la demande et n'est jamais enregistrée comme deuxième autorité.
3. Les constantes de code sont réservées aux invariants mathématiques. Une épaisseur, une marge, une couleur ou une fréquence artistique n'est pas un invariant.
4. Les consommateurs référencent la Resource propriétaire au lieu de copier sa valeur.
5. Chaque propriété exportée indique en français son effet, son unité et ses conséquences principales.
6. Les surcharges locales silencieuses sont interdites. Une future surcharge devra être explicite, désactivée par défaut et signalée dans l'Inspecteur.
7. Un inventaire de réglages associera chaque résultat visible à sa Resource et à sa propriété responsable.

L'ordre d'autorité est : configuration générale du projet, puis `RoadMapData` et ses Resources référencées. Aucun nœud enfant ne redéfinit discrètement ces valeurs.

## Géométrie responsive

Le viewport de référence reste 1280 x 720 avec `canvas_items` et `expand`, mais aucun calcul de map ne dépend d'un centre horizontal fixe. Le centre est toujours `viewport_size.x / 2`.

Les valeurs initiales de conception sont :

- horizon à environ 14 % de la hauteur visible ;
- bas géométrique à environ 108 %, légèrement sous l'écran ;
- bande du joueur entre 55 % et 92 % de la hauteur ;
- largeur à l'horizon égale à environ 20 à 22 % de la largeur basse ;
- courbe de perspective initiale proche de 1,5 ;
- largeur basse égale au minimum entre 92 % de la largeur visible et environ 1,55 fois la hauteur visible.

Cette formule donne environ 1080 à 1120 pixels logiques sur un viewport 16:9 de référence. Sur un écran étroit, la route peut occuper jusqu'à 92 % de la largeur. Sur ultrawide, sa largeur jouable est plafonnée par la hauteur ; les marges supplémentaires enrichissent le décor sans agrandir indéfiniment l'aire de combat.

Tous ces ratios sont éditables dans `RoadLayoutData` avec des limites cohérentes. Les fonctions `project`, `unproject`, `width_at`, `scale_at` et les limites du joueur reçoivent explicitement la taille du viewport. Elles sont pures : la Resource ne mémorise aucun état dérivé, ce qui évite les conflits lorsqu'elle est partagée.

## Composition et projection des segments

Un `RoadSegment2D` est une vraie scène composée manuellement. Il peut contenir :

- décor lointain ;
- décor latéral ;
- un élément majeur distinctif ;
- accessoires secondaires ;
- sockets jouables ;
- informations de transition vers les segments voisins.

Les props proches stockent une position routière logique plutôt qu'une position écran définitive. La coordonnée latérale va de -1 à +1 autour de la chaussée et la profondeur est résolue depuis la progression du segment. La projection détermine position écran, échelle et ordre d'affichage. Un objet proche de l'horizon est donc plus petit et paraît progresser plus lentement.

Les props purement décoratifs ne possèdent ni collision ni traitement physique. Les obstacles, objets ramassables et autres éléments jouables utilisent des scènes séparées, instanciées depuis des `GameplaySocket2D`.

## Progression et recyclage

`RoadMapController` maintient une seule distance logique parcourue. La chaussée, les marquages, les segments, les props projetés et les futurs systèmes d'apparition lisent cette même progression. Aucun enfant ne possède sa propre vitesse globale.

Les segments quittant l'écran sont remis dans un pool et réemployés. Les décors ne sont pas détruits puis recréés à chaque passage. La sélection des segments peut être reproduite grâce à la graine exposée dans `RoadMapData`, ce qui permet de rejouer exactement une route pendant les tests.

Les ennemis, collisions et objets ramassables ont leurs pools séparés. Ils ne sont pas gérés comme du décor.

## Densité visuelle et performance

`RoadThemeData` définit le comportement visuel de quatre profils explicites, et `RoadMapData.density_profile` sélectionne celui employé par la map :

- `LOW` : machines faibles ou mobiles ;
- `MEDIUM` : profil de référence ;
- `HIGH` : beaucoup d'assets ;
- `ULTRA` : décor maximal, captures ou machines puissantes.

Chaque prop ou variante de segment indique son niveau minimal de densité. Le profil choisi active des variantes préparées dans l'éditeur ; il ne retire pas silencieusement des objets pendant une partie. Il n'existe pas d'adaptation automatique dans la première version. Une adaptation future devra être activable, documentée et portée par une Resource de profil de performance.

Le budget de décor est indépendant du plafond de horde. Un simple sprite décoratif n'obtient pas un script actif si une image statique suffit.

## Aperçu dans l'éditeur

Les scripts `@tool` sont limités au calcul d'aperçu, au redessin et à la validation. Ils ne suppriment, ne déplacent, ne réparent ni ne génèrent automatiquement des enfants persistants de la scène.

Un mode d'aperçu permet de choisir :

- viewport actuel ;
- 4:3 ;
- 16:10 ;
- 16:9 ;
- mobile 19.5:9 ;
- ultrawide 21:9.

Les guides désactivables montrent l'horizon, les limites de route, le couloir de combat, la bande du joueur, les marges décoratives et le centre optique. Ils appellent les mêmes fonctions de projection que l'exécution.

Une scène dédiée `road_map_test.tscn` permet de modifier rapidement le format, la courbe, la largeur et la densité sans dépendre de la partie complète.

## Validation et erreurs

`_get_configuration_warnings()` signale au minimum :

- une Resource obligatoire absente ;
- un ratio hors limites ;
- une route trop étroite pour le joueur ;
- un horizon placé sous le couloir de combat ;
- un segment sans scène ou de longueur invalide ;
- un prop jouable placé dans une couche purement décorative ;
- un décor majeur empiétant sur le couloir central ;
- une ancienne `RoadData` encore référencée après la migration.

Une valeur numérique invalide utilise un repli documenté et produit un avertissement. Une référence indispensable absente empêche le démarrage de cette map et affiche un message explicite comprenant le nom de la propriété concernée. Il n'y a ni échec silencieux ni réparation persistante automatique.

## Migration de l'ancien système

L'actuelle `RoadData` mélange géométrie, gameplay, marquages et couleurs. `RoadController` contient aussi des nombres artistiques en dur, notamment le rectangle extérieur, l'épaisseur des bords, la phase des marquages et la lueur d'horizon.

La migration suit cet ordre :

1. Créer et tester les nouvelles Resources et fonctions de projection.
2. Transférer les valeurs de `road_01.tres` vers les propriétaires appropriés.
3. Adapter `RoadAgent2D`, le joueur et les consommateurs existants à `RoadLayoutData` et `RoadMapData`.
4. Remplacer `road_01.tscn` dans la partie par `Map01Industrial.tscn`.
5. Vérifier qu'aucune scène ni Resource ne référence l'ancienne classe.
6. Supprimer `RoadData`, `RoadController` et `road_01.tres` seulement après cette vérification.

Les anciens et nouveaux systèmes ne restent jamais simultanément des autorités actives.

## Tests et critères d'acceptation

Les tests automatisés vérifient :

1. la réversibilité raisonnable de `project` et `unproject` ;
2. la projection cohérente du haut et du bas de la route ;
3. la symétrie autour du centre réel du viewport ;
4. le plafonnement de la route en ultrawide ;
5. la bande du joueur et ses limites latérales ;
6. les profils 4:3, 16:10, 16:9, 19.5:9 et 21:9 ;
7. le chargement de chaque Resource et scène de segment ;
8. les avertissements attendus sur des configurations volontairement invalides ;
9. la reproduction de la sélection de segments avec une graine identique ;
10. l'absence des nombres de réglage retirés de `RoadMapController`.

La fonctionnalité est acceptée lorsque :

- la map est une vraie scène visible et réglable dans Godot ;
- les cinq familles de formats conservent une route jouable et une perspective agréable ;
- l'ultrawide ajoute du décor sans élargir excessivement le gameplay ;
- l'aperçu éditeur correspond au résultat exécuté ;
- aucun ancien réglage en pixels ne demeure une autorité ;
- le profil `HIGH` affiche une map riche sans ajouter de physique au décor passif ;
- le test headless du projet et les tests de projection réussissent ;
- le joueur peut ensuite être repositionné au sol sans modifier l'architecture de la map.

## Références de conception

- Godot, gestion des résolutions multiples : <https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html>
- Godot, Resources : <https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html>
- Godot, organisation des scènes : <https://docs.godotengine.org/en/latest/tutorials/best_practices/scene_organization.html>
- Godot, scripts `@tool` : <https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html>
- Godot, `Parallax2D` : <https://docs.godotengine.org/en/4.7/classes/class_parallax2d.html>
- Insomniac Games, direction post-apocalyptique expressive de *Sunset Overdrive* : <https://insomniac.games/game/sunset-overdrive/>
