# Mouvement KidiPlay

## Intention

La mascotte KidiPlay n’a pas besoin, par défaut, d’un cycle de marche de jeu de
plateforme. Son rôle principal est d’accueillir, guider, féliciter et encourager
l’enfant.

La première identité du mouvement doit donc privilégier les réactions
d’interface et la lisibilité émotionnelle.

## Motion Atlas de la mascotte

La première planche de mouvement utilise une grille uniforme `4 × 4`.

| Ligne | Cellule 1 | Cellule 2 | Cellule 3 | Cellule 4 |
|---|---|---|---|---|
| 1 | face | trois-quarts | profil | dos |
| 2 | joie | curiosité | fierté | encouragement |
| 3 | salut : anticipation | salut : pose clé | succès : anticipation | succès : pose clé |
| 4 | erreur douce | montre un élément | petite surprise | retour au repos |

Cette planche ne constitue pas encore une animation. Elle verrouille :

- les volumes du personnage sous plusieurs angles ;
- la longueur des membres et la forme du visage ;
- la position du foulard ;
- l’amplitude des expressions ;
- le pivot au centre des pieds ;
- la ligne de sol ;
- le degré d’élasticité autorisé.

## Premières animations

### `idle`

- usage : présence de la mascotte à l’écran ;
- boucle : oui ;
- cible : 6 à 8 frames ;
- cadence : 6 à 8 FPS ;
- mouvement : respiration légère, clignement discret, petit mouvement du foulard ;
- contrainte : aucune translation du pivot.

### `greet`

- usage : arrivée sur l’accueil ou début d’activité ;
- boucle : non ;
- cible : 8 frames ;
- cadence : 10 FPS ;
- mouvement : anticipation, salut de la patte, maintien bref, retour au repos.

### `celebrate`

- usage : bonne réponse, Memory terminé ou activité réussie ;
- boucle : non ;
- cible : 10 à 12 frames ;
- cadence : 12 FPS ;
- mouvement : petite impulsion vers le haut, bras ouverts, expression fière,
  retour amorti ;
- événement : déclencher le son ou les confettis sur la pose maximale.

### `encourage`

- usage : erreur ou nouvelle tentative ;
- boucle : non ;
- cible : 8 frames ;
- cadence : 10 FPS ;
- mouvement : légère inclinaison, sourire rassurant, geste doux vers l’activité ;
- contrainte : ne jamais exprimer frustration, tristesse forte ou jugement.

### `point`

- usage : attirer l’attention vers un bouton ou une zone ;
- boucle : maintien possible sur la pose finale ;
- cible : 6 frames ;
- cadence : 10 FPS ;
- variantes futures : gauche, droite, haut et bas.

## Animations secondaires

Après validation de la mascotte :

- retournement d’une carte Memory ;
- petite réaction des animaux lors d’une paire trouvée ;
- autocollant qui se décolle puis se pose ;
- bouton qui s’enfonce et reprend sa forme ;
- étoile ou confettis de réussite ;
- tracé de crayon pour le coloriage.

Ces animations utilisent la même palette et le même langage de mouvement, mais
possèdent leurs propres tailles de cellule, pivots et cadences.

## Convention de fichiers

```text
assets/kidiplay/motion/
├── mascot-bear-motion-board-v001.png
├── mascot-bear-motion-v001.json
└── mascot-bear/
    ├── idle/
    │   ├── 0001.png
    │   └── ...
    ├── greet/
    ├── celebrate/
    ├── encourage/
    └── point/
```

Le manifeste suit la structure de
[`examples/animation-set.example.json`](../../../examples/animation-set.example.json).
L’export runtime convertit ensuite ces séquences vers `frames`, `animations` et
`duration` dans le JSON Hash de l’atlas.
