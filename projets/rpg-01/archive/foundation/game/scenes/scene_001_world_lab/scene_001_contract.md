# Scene 001 — World Lab

Cette scène est le seul niveau créé pendant la fondation. Elle n'est pas une
portion définitive de la carte de référence.

## Statut visuel

Le laboratoire est **techniquement testable mais non validé comme carte de
jeu**. Les berges droites, la falaise provisoire, les raccords de chemins et la
densité du décor ne satisfont pas encore la référence. Ils servent à exposer les
manques du TileSet ; ils ne doivent pas être repris tels quels dans une scène
définitive.

## Elle doit prouver

- sol et chemin raccordables ;
- rivière bloquante ;
- pont traversable avec côtés bloquants ;
- falaise impossible à franchir directement ;
- escalier comme seul passage entre `height_level=0` et `height_level=1` ;
- arbre bloquant uniquement autour du tronc ;
- Y-sort correct devant et derrière un objet haut ;
- porte extérieure chargeant un intérieur séparé ;
- retour vers un point d'apparition extérieur nommé.

## Ordre de construction

1. peindre les sols ;
2. ajouter la rivière ;
3. ajouter la falaise et son escalier ;
4. poser le pont ;
5. ajouter un arbre et vérifier le tri ;
6. poser la maison ;
7. ajouter seulement ensuite collisions et transitions ;
8. tester avec le joueur-probe avant tout embellissement.

## Critère de sortie

On ne commence aucune grande carte tant que le joueur peut contourner une
falaise, marcher sur l'eau, traverser un bord de pont ou manquer la porte.
