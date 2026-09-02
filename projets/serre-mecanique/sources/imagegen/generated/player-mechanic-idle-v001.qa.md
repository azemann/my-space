# QA — personnage joueur v001

- Runtime : `assets/characters/player-mechanic-idle-v001.png`
- Dimensions : 32 × 32 px
- Silhouette opaque : environ 15 × 28 px
- Fond : transparent
- Orientation source : droite
- Filtrage Godot : nearest
- Collision : capsule existante de 16 × 28 px, inchangée
- Arme : calque `Equipment` séparé et placé devant le corps

Cette version fixe l'identité et la pose neutre. Elle n'est pas encore un cycle
d'animation ; marche, saut, chute, escalade et grappin devront conserver cette
même silhouette et cette même palette.
