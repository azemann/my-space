# Contrat d'affichage multi-support

## Base canonique

| Réglage | Valeur |
| --- | --- |
| Résolution logique | `640 × 360` |
| Mode de démarrage | plein écran adaptatif |
| Fenêtre de repli | `1280 × 720` |
| Ratio de conception | `16:9` paysage |
| Stretch mode | `viewport` |
| Stretch aspect | `expand` |
| Stretch scale mode | `integer` |
| Filtrage des textures | `nearest` |
| Grille du monde | `32 × 32 px` |

La résolution logique est un espace de conception, pas une résolution imposée
au moniteur. Le monde peut révéler davantage de largeur ou de hauteur selon le
ratio physique de l'écran. Aucun sprite n'est étiré de façon non uniforme.

La caméra utilise un zoom mondial `×1` : à la base 640 × 360, environ 20 tuiles
de 32 px sont visibles en largeur. Les zones panoramiques peuvent descendre sous
`×1` ; le pont emploie actuellement `×0,85` pour mieux révéler ses accès.

Le jeu démarre en plein écran. `F11` ou `Alt+Entrée` bascule entre le plein
écran et une fenêtre `1280 × 720`. Ce raccourci est géré par le noyau persistant
du jeu : il reste donc disponible dans toutes les cartes, menus et scènes.

## Supports visés

- Windows, Linux et macOS en fenêtre ou plein écran ;
- Steam Deck et autres consoles portables en paysage ;
- écrans 720p, 1080p, 1440p et 4K ;
- Web dans une fenêtre redimensionnable ;
- Android et iOS en paysage ;
- tablettes 4:3 et téléphones larges avec zone sûre.

Le mode portrait n'est pas un format de gameplay garanti. Il demanderait une
composition de caméra et d'interface distincte.

## Monde et interface

- la caméra de jeu utilise la taille visible réelle du viewport ;
- les limites de caméra empêchent d'afficher l'extérieur de la carte ;
- l'interface emploie des ancres et des `Container` ;
- les informations indispensables restent dans un cadre sûr 16:9 centré ;
- les contrôles tactiles respectent `DisplayServer.get_display_safe_area()` ;
- les décorations d'interface peuvent occuper l'espace supplémentaire ;
- aucune logique gameplay ne dépend d'une taille de fenêtre précise.

## Matrice minimale de contrôle

| Profil | Taille |
| --- | --- |
| Base | `640 × 360` |
| 720p | `1280 × 720` |
| 1080p | `1920 × 1080` |
| 1440p | `2560 × 1440` |
| 4K | `3840 × 2160` |
| Steam Deck | `1280 × 800` |
| Portable | `1366 × 768` |
| Mobile large | `2340 × 1080` |
| Tablette 4:3 | `2048 × 1536` |

## Entrées

Le gameplay utilise uniquement les actions Input Map `move_left`, `move_right`,
`move_up`, `move_down`, `interact`, `run`, `pause`, `psychokinesis_grab`,
`psychokinesis_throw`, `psychokinesis_raise`, `psychokinesis_lower`,
`psychokinesis_cancel` et les quatre actions `psychokinesis_move_*`. Clavier,
souris, manette et futur tactile sont des liaisons de ces actions, jamais des
chemins de code séparés. Toutes sont modifiables dans l'onglet **Contrôles** des
paramètres du projet Godot.

À la souris, survoler une cible accessible l'indique. Le clic gauche la saisit
ou la dépose ; sa position suit ensuite le pointeur dans le rayon du pouvoir.
La molette règle sa hauteur. Maintenir le clic droit verrouille l'objet et
charge la projection : la souris vise alors librement, puis le relâchement
projette dans cette direction. La force combine durée de charge et distance de
visée. `Échap` annule la prise. `F` et `R` restent des alternatives clavier.

Sur manette, la gâchette gauche saisit ou dépose la cible la plus proche, le
stick droit déplace l'objet et vise, et la gâchette droite charge puis projette
au relâchement. Les boutons supérieurs règlent sa hauteur et le bouton
d'annulation le dépose. Ces correspondances suivent les constantes standard de
Godot et restent donc remappables pour les manettes Xbox, PlayStation et
compatibles.
