# Contrôle qualité — tileset source v001

## Résultat

- structure 16 × 5 : conforme ;
- 80 cellules présentes : conforme ;
- bordures traversées : aucune observée ;
- bandes de sécurité supérieure et inférieure : libres ;
- ordre des cinq familles : conforme ;
- cohérence visuelle avec la serre mécanique : conforme ;
- dimensions natives demandées : non conformes, ImageGen a produit 1774 × 887 px ;
- normalisation 2048 × 1024 : effectuée sans changer le ratio 2:1 ;
- aperçu 32 × 32 : généré ;
- activation dans le jeu : en attente.

## Remarques fonctionnelles

Les tuiles `T02` à `T08` et `T16` à `T27` sont dessinées comme des éléments
partiels alors que le TSX historique classe plusieurs d'entre elles comme des
solides couvrant toute la case. Elles ne sont pas utilisées dans le niveau 01,
mais leur dessin ou leur définition de collision devra être réconcilié avant un
emploi futur.

Les raccords modulaires — plateformes, tuyaux, poutres, eau, échelle et chaîne —
doivent encore être alignés lors de l'extraction finale. La réduction brute est
un aperçu artistique et non encore un tileset de production.

Une tentative de retouche globale a été rejetée : elle supprimait une case et
modifiait des cases hors périmètre. La source v001 reste donc la référence retenue.
