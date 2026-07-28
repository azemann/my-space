# Neon Courier — prompts de séquences v001

## Références communes

Chaque génération utilise :

1. `../identity/courier-character-atlas-v001.png` comme référence d’identité ;
2. `sequence-grid-template-3x3.png` comme gabarit obligatoire.

Les invariants communs sont :

- même héroïne, visage, proportions, tenue, casque, sac et chaîne ;
- profil droit et caméra fixe ;
- grille `3 × 3` inchangée ;
- échelle, ligne de sol et pivot constants ;
- lecture gauche vers droite, puis haut vers bas ;
- aucun élément ne traverse une cellule.

## `idle`

```text
Nine successive frames of one seamless idle loop:
1 neutral combat idle;
2 beginning inhale;
3 full inhale;
4 beginning exhale;
5 blink during exhale;
6 lowest breathing point;
7 tiny rear-foot weight shift;
8 return to center;
9 near-neutral transition back to frame 1.
```

La chaîne reste rassemblée dans une main. Le mouvement doit se limiter à la
respiration, au clignement et aux réactions secondaires du foulard et du sac.

## `walk`

```text
Nine successive frames of one complete in-place side-view walk cycle:
contact, down, passing, high point, opposite contact, opposite down, opposite
passing, opposite high point, transition back to first contact.
```

La première génération conserve bien l’identité, mais ne différencie pas assez
la seconde moitié du cycle. Elle reste marquée `needs-revision`.

## `chain-strike`

```text
Nine successive frames of one complete basic horizontal bicycle-chain attack:
guard, weight shift, maximum anticipation, acceleration, impact, overshoot,
follow-through, chain recovery, return to guard.
```

Deux corrections ont été demandées pour contenir entièrement la chaîne dans les
frames d’impact. La dernière correction a résolu le débordement, mais a réduit
excessivement l’échelle de la frame d’impact. Elle reste marquée
`needs-revision`.

## Principe de production retenu

Une planche générée n’est pas automatiquement une animation livrable. Chaque
séquence passe ensuite par :

1. revue de l’ordre et des poses clés ;
2. correction ou régénération des frames faibles ;
3. détourage ;
4. normalisation de l’échelle, du pivot et de la ligne de sol ;
5. aperçu animé ;
6. export de l’atlas et des durées.
