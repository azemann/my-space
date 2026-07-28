# Contrat de l’Identity Atlas

## Définition

Un Identity Atlas est une image structurée qui établit l’identité visuelle d’un
projet au moyen d’assets représentatifs et extractibles.

Il doit rester lisible comme une planche d’ensemble tout en permettant un
traitement cellule par cellule.

## Contenu possible

La sélection dépend du projet. Une planche destinée à un jeu de type
Worms-like pourrait contenir :

```text
┌────────────────────────────────────────────┐
│ Personnage : vues, poses et expressions    │
├────────────────────────────────────────────┤
│ Armes, projectiles et accessoires          │
├────────────────────────────────────────────┤
│ Terrain, plateformes et décor              │
├────────────────────────────────────────────┤
│ Impacts, fumées et explosions              │
├────────────────────────────────────────────┤
│ Icônes, palette et motifs représentatifs   │
└────────────────────────────────────────────┘
```

Il ne s’agit pas nécessairement de couvrir tout le jeu. La planche doit
présenter le plus petit ensemble capable d’exprimer clairement son vocabulaire
visuel.

## Contraintes de génération

Pour que la planche soit découpable :

- la taille du canevas est connue ;
- la grille est définie avant la génération ;
- chaque asset possède une cellule réservée ;
- les cellules utilisent des dimensions et des marges explicites ;
- un asset ne déborde pas dans une cellule voisine ;
- les éléments ne se superposent pas ;
- le fond destiné à l’extraction est transparent ou facilement supprimable ;
- les ombres et effets restent dans les limites prévues ;
- l’orientation et l’échelle sont cohérentes au sein d’une même famille ;
- les libellés éventuels restent hors des zones d’extraction.

La génération d’images n’est pas supposée respecter parfaitement ces
contraintes. L’étape de contrôle mesure les écarts et détermine si une cellule
peut être corrigée, doit être régénérée ou doit être rejetée.

## Grille et manifeste

Le manifeste est la description technique de la planche. Il permet de découper
l’image sans dépendre de son interprétation visuelle.

Il décrit au minimum :

- le fichier source ;
- les dimensions du canevas ;
- l’origine et les dimensions de la grille ;
- les marges et espacements ;
- la position de chaque cellule ;
- le nom et la famille de chaque asset ;
- son pivot attendu ;
- son état de validation.

Les coordonnées et dimensions sont exprimées en pixels. Les pivots sont
normalisés entre `0` et `1` dans la cellule ou dans le rectangle découpé, selon
la convention déclarée par le manifeste.

## Validation

La validation s’effectue à deux niveaux.

### Validation de la planche

- langage visuel identifiable ;
- palette, formes et matières cohérentes ;
- proportions adaptées au projet ;
- diversité suffisante pour servir de référence ;
- composition lisible dans son ensemble.

### Validation des cellules

- élément complet et isolé ;
- absence d’artefacts majeurs ;
- silhouette exploitable ;
- transparence correcte ;
- cadrage et marges suffisants ;
- pivot pertinent ;
- conformité avec le rôle annoncé dans le manifeste.

Une planche peut être validée comme référence artistique même si certaines
cellules sont rejetées comme assets de production. Le manifeste conserve cette
distinction.

## Sorties dérivées

À partir de la planche et de son manifeste, Codex peut produire :

- les PNG individuels ;
- une spritesheet nettoyée ;
- un atlas compact ;
- les métadonnées JSON ;
- les fichiers d’import du moteur cible ;
- des aperçus de contrôle ;
- des variantes régénérées à partir de l’identité approuvée.

L’Identity Atlas original reste la source visuelle canonique. Les transformations
techniques doivent être reproductibles sans modifier silencieusement cette
source.

## Identité du mouvement

Une identité visuelle de personnage n’est pas complète si elle ne décrit que
son apparence immobile. Le projet doit aussi fixer :

- son centre de gravité et sa ligne de sol ;
- l’amplitude et la souplesse de ses mouvements ;
- ses poses clés et silhouettes caractéristiques ;
- le comportement des éléments secondaires : oreilles, queue, vêtements ;
- la vitesse, l’exagération et le rythme des actions ;
- la manière d’entrer dans une pose et d’en sortir.

Ces règles sont matérialisées dans un **Motion Atlas**. Il peut contenir un
turnaround, des expressions, des poses extrêmes et quelques images clés des
actions principales. Il reste une référence de direction ; les animations
complètes sont produites ensuite dans des planches homogènes séparées.

Une animation donnée utilise :

- une grille uniforme ;
- une seule vue et une seule échelle ;
- un pivot constant ;
- une ligne de sol constante ;
- un ordre de frames explicite ;
- une cadence, un mode de boucle et des transitions déclarés.

Mélanger dans la même grille une animation complète et des assets statiques de
tailles différentes rend le contrôle temporel plus difficile. L’Identity Atlas
et le Motion Atlas partagent donc la même identité, mais n’ont pas à partager la
même image.

## Manifeste artistique et manifeste runtime

Deux documents sont nécessaires.

Le **manifeste artistique** conserve la palette, les familles, les prompts, la
provenance, les décisions et les statuts de validation. Il appartient à ce
workflow.

Le **manifeste runtime** décrit uniquement comment un moteur retrouve les
sprites dans une texture. Il doit utiliser un format standard tel que
TexturePacker JSON Hash :

- `frames` ;
- `frame` avec `x`, `y`, `w`, `h` ;
- `rotated` et `trimmed` ;
- `spriteSourceSize` et `sourceSize` ;
- `anchor` lorsque la cible le supporte ;
- `meta.image`, `meta.format`, `meta.size` et `meta.scale` ;
- `animations` lorsque plusieurs frames forment une séquence.

La grille uniforme est conservée tant qu’elle sert à la génération et au
contrôle. Une copie runtime peut ensuite être rognée et repackée sans perdre
l’alignement, grâce à `spriteSourceSize`, `sourceSize` et au pivot.

## Cycle d’évolution

Une nouvelle version de la planche est créée lorsqu’une évolution change le
langage visuel global ou la structure de la grille. La correction technique
d’un asset isolé peut produire une nouvelle version de cet asset sans invalider
automatiquement toute la planche.

Le versionnement concret est choisi avec le projet ; ce dépôt n’impose pas
d’outil ou de convention supplémentaire à Git.
