# QA — personnage joueur v003

- Runtime : `assets/characters/player-mechanic-idle-v003.png`
- Source validée : personnage sans casque v002
- Canevas : 64 × 64 px transparent
- Silhouette opaque : environ 30 × 56 px
- Traitement : agrandissement nearest-neighbor, sans nouvelle génération
- Décalage visuel : 8 px vers le haut pour aligner les pieds
- Collision conservée : capsule 20 × 40 px
- Position de l’équipement conservée : `(5, -2)`

La silhouette gagne 16,7 % en hauteur. La collision ne change pas afin de ne pas
modifier les passages étroits, les échelles et la maniabilité déjà validés.
