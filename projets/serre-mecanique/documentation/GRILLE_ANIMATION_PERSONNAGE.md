# Grille d’animation du personnage

Le contrat du personnage utilise une grille fixe de **4 colonnes × 4 lignes**,
soit 16 frames.

## Deux formats, une même grille

| Usage | Planche | Case |
|---|---:|---:|
| guide de génération ImageGen | 1024 × 1024 px | 256 × 256 px |
| spritesheet Godot | 256 × 256 px | 64 × 64 px |

Le guide haute définition est réduit exactement à 25 % avec un filtre
nearest-neighbor. Les cadres restent donc carrés et correspondent directement
aux régions d’un `SpriteFrames` Godot.

## Alignement immuable

- pivot horizontal : `x = 32` dans chaque frame runtime ;
- ligne des pieds : `y = 60` ;
- hauteur maximale de la silhouette : 56 px ;
- boîte de sécurité : de `(8, 4)` à `(56, 60)` ;
- fond du guide propre : magenta `#ff00ff` pour détourage ;
- spritesheet finale : transparence alpha et filtre nearest.

Le fichier `guide` contient les repères visibles. Le fichier `clean` ne contient
que les 16 cases magenta et sert d’entrée à ImageGen. Les traits du guide ne
doivent jamais être incorporés au spritesheet final.

## Une planche par mouvement

La grille ne mélange plus plusieurs mouvements. Chaque animation dispose de ses
16 frames, de son rythme, de ses poses clés et de ses contraintes propres :

| Planche | Nature | Critère dominant |
|---|---|---|
| `idle` | boucle | respiration discrète, pieds immobiles |
| `walk` | boucle | contacts au sol réguliers, poids lisible |
| `jump` | séquence pilotée | anticipation, montée, apex, chute, réception |
| `climb` | boucle | alternance exacte des mains et des pieds |
| `grapple` | poses pilotées | tension de la corde et direction de traction |

Les armes restent sur un calque séparé du corps. Les animations corporelles ne
doivent donc jamais dessiner le pistolet-grappin ou une autre arme.

La planche `jump` pourra être lue par plages plutôt que comme une boucle complète :
le code choisira une frame selon la vitesse verticale et l’état au sol.

## Contrat temporel

Une grille décrit l’espace, pas à elle seule le temps. Chaque planche validée est
donc accompagnée par `character-animation-timing.json`. Pour chaque frame, ce
manifeste conserve :

- `phase` : progression normalisée de `0.0` à `1.0` ;
- `time_ms` : horodatage nominal utile pour les aperçus ;
- `pose` : nom stable de la phase corporelle ;
- `contacts` : mains ou pieds actuellement en appui ;
- `event` : événement ponctuel transmis au gameplay, s’il existe ;
- `interruptible` : possibilité de quitter cette pose sans rupture visible.

La phase normalisée est la référence principale. Le temps nominal ne commande
pas directement le gameplay : Godot peut accélérer une marche ou une escalade
sans refaire les images. Une animation pilotée comme `jump` sélectionne d’abord
sa plage selon l’état physique (`velocity.y`, sol, réception), puis choisit la
frame à l’intérieur de cette plage.

### Vocabulaire retenu

- **grille spatiale** : position et encombrement des 16 images ;
- **phase temporelle** : avancement dans le mouvement ;
- **contact** : membre qui porte ou accroche le personnage ;
- **événement** : instant utile au son, aux effets ou au gameplay ;
- **boucle** : mouvement cyclique dont la fin rejoint le début ;
- **piloté par l’état** : animation choisie par la physique plutôt que jouée à
  vitesse constante.

Pour l’escalade, `screen_left` et `screen_right` désignent toujours les côtés
visibles de l’image. Cette convention évite d’inverser les membres selon
l’orientation anatomique du personnage.

## Passage d’ImageGen à Godot

Une planche ImageGen ne doit jamais être découpée directement en quatre parts
égales. L’outil peut respecter visuellement la grille tout en laissant une botte
ou une mèche dépasser la frontière mathématique d’une case.

Le pipeline validé est donc :

1. validation humaine de la planche conceptuelle ;
2. suppression du fond chroma dans `sources/imagegen/processed/` ;
3. détection des 16 composantes alpha indépendantes ;
4. tri par ligne puis par colonne ;
5. réduction avec une échelle commune à toute la planche ;
6. recentrage de chaque silhouette sur le pivot `(32, 60)` ;
7. assemblage du PNG runtime 256 × 256 ;
8. génération de `player-mechanic-animations.tres` pour Godot ;
9. contrôle automatique de chaque boîte 64 × 64.

Le processeur est `sources/imagegen/process_character_animation_sheets.py` et
son rapport est `sources/imagegen/processed/player-animation-runtime-qa.json`.
Une frame est refusée si elle dépasse 60 px de large, 56 px de haut ou si son
point bas ne correspond pas à `y = 60`.

Le Player emploie désormais un `AnimatedSprite2D`. Les boucles `idle`, `walk` et
`climb` avancent selon le mouvement, tandis que `jump` et `grapple` sont pilotées
par la physique. Les frames d’anticipation du saut restent disponibles pour une
future animation préparatoire, mais elles ne retardent actuellement jamais la
réponse de la commande de saut.
