# Muay Thai Monk-Cowboy — Character Atlas v003

## Dérivation

Cette version conserve les pixels utiles de la candidate corrigée v002. Elle
n’est pas une nouvelle génération.

## Normalisation technique

Le générateur avait conservé quatre colonnes régulières mais déplacé les trois
séparateurs horizontaux. Une planche visuellement quadrillée ne suffisait donc
pas encore pour servir de spritesheet uniforme.

Le script
[`../scripts/normalize-identity-v002.sh`](../scripts/normalize-identity-v002.sh)
effectue les opérations suivantes :

1. découpe les seize cellules selon les séparateurs réellement générés ;
2. retire le fond crème et les fragments de guides internes ;
3. conserve l’échelle des personnages, en réduisant seulement les poses qui
   dépasseraient la zone sûre ;
4. centre chaque sujet dans une cellule exacte de `384 × 384` ;
5. reconstruit un fond uniforme et une grille aux coordonnées `384`, `768` et
   `1152`.

## Dimensions

- version normalisée : `1536 × 1536` ;
- grille : `4 × 4` strictement uniforme ;
- cellule : `384 × 384` ;
- zone sûre maximale d’un sujet : `366 × 366`.
