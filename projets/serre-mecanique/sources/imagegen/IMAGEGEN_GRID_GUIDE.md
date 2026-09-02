# Grille ImageGen — Serre mécanique

## Rôle

Deux références complémentaires sont disponibles :

- `serre-mecanique-grid-template-4x4.png` impose une planche de 16 cases sur un
  canevas de 1536 × 1024 px. Chaque case mesure 384 × 256 px. Elle sert aux
  recherches ciblées et aux variantes lisibles ;
- `serre-mecanique-tileset-grid-16x5.png` impose les 80 emplacements du tileset
  complet sur un canevas de 2048 × 1024 px. Sa grille centrale commence à
  `y=192`, mesure 2048 × 640 px et contient des cases carrées de 128 × 128 px.

Cette planche est une source de conception, pas un asset chargé par Godot. Le
fichier `.gdignore` empêche son import dans le jeu.

## Règles de composition

- conserver exactement quatre colonnes et quatre lignes ;
- produire un seul élément ou une seule variation par case ;
- ne jamais faire déborder un élément dans une autre case ;
- conserver un point de vue, une échelle et une lumière cohérents sur la planche ;
- ne placer aucun texte, numéro, logo ou filigrane dans l'image générée ;
- utiliser le fond sombre uniforme de la grille ;
- garder au moins 24 px de respiration à l'intérieur de chaque case pour les
  objets isolés ;
- pour les tuiles de terrain, remplir la case jusqu'aux bords utiles et conserver
  des raccords compatibles entre les variantes demandées.

La grille sert à la composition. Elle ne garantit pas à elle seule des tuiles
finales de 32 × 32 px : les cases retenues devront être extraites, nettoyées,
recadrées et réduites séparément.

## Contrat de production obligatoire

Une planche ImageGen est une **étude artistique**, jamais un atlas jouable par
défaut. Le passage en production suit toujours ces quatre étapes :

1. attribuer à chaque case un rôle stable dans le manifeste ;
2. classer la case comme `modular` ou `isolated_prop` ;
3. pour `modular`, conserver un masque de géométrie validé et ne modifier que
   la matière, la couleur et les détails intérieurs ;
4. valider automatiquement dimensions, ordre des cases, masques alpha,
   couleurs RGB des bords opposés et absence de contour peint avant de
   référencer le PNG depuis un TSX.

Une case opaque n'est pas forcément raccordable : un contour sombre peint à
l'intérieur de la case produit encore une couture visible. Le contrôle de
production doit donc comparer le bord droit au bord gauche voisin et vérifier
que ces bords se fondent aussi avec les colonnes intérieures adjacentes.

`isolated_prop` peut garder une marge transparente : une plante, un engrenage ou
un collectible ne se raccorde pas à ses voisins. `modular` ne doit jamais être
agrandi ou rogné à l'œil : sol, mur, plateforme, tuyau, eau, échelle et chaîne
obéissent à une géométrie de raccord explicite.

Un atlas qui ne passe pas ce contrôle reste dans `sources/imagegen/generated/`.
Seul l'atlas validé est copié dans `assets/tilesets/` et chargé par Tiled/Godot.

La grille 16 × 5 suit directement l'adressage du tileset final : `T00` à `T15`
sur la première ligne, puis `T16` à `T31`, jusqu'à `T79`. Les deux bandes sombres
de 192 px situées au-dessus et au-dessous de la grille sont des marges de sécurité
et doivent rester vides.

## Prompt de base — objets isolés

```text
Use case: stylized-concept
Asset type: 4x4 game asset atlas source for a 2D platformer
Input images: Image 1 is a structural grid reference only; preserve its exact
4-column by 4-row organization, but do not copy it as an artistic style.
Primary request: fill the sixteen cells with the sixteen requested Serre
mécanique objects, exactly one isolated object per cell, in the supplied order.
Style/medium: detailed hand-painted pixel-art-ready game sprites, orthographic
side view, designed to remain readable after reduction to 32x32 pixels.
Composition/framing: one centered object per cell; consistent scale and camera;
at least 24 px of internal padding; no object may cross a grid divider.
Lighting/mood: coherent subdued industrial-greenhouse lighting.
Color palette: near-black iron, oxidized copper, verdigris, turquoise glass,
moss green and restrained brass highlights.
Constraints: preserve exactly 16 separate cells; no merged cells; no text; no
numbers; no logos; no watermark; no cast shadows outside each object.
```

Ajouter ensuite la liste ordonnée des 16 objets sous la forme :

```text
A1: ...; A2: ...; A3: ...; A4: ...
B1: ...; B2: ...; B3: ...; B4: ...
C1: ...; C2: ...; C3: ...; C4: ...
D1: ...; D2: ...; D3: ...; D4: ...
```

## Prompt de base — terrain modulaire

Reprendre le prompt précédent en remplaçant les lignes `Primary request` et
`Composition/framing` par :

```text
Primary request: fill the sixteen cells with the requested modular terrain
variants, exactly one tile design per cell, in the supplied order.
Composition/framing: orthographic side-view tile source; each terrain tile fills
its cell; matching edge height, material scale and lighting across all cells;
transitions requested as left, middle, right, inner corner and outer corner must
connect visually; no detail may cross a grid divider.
```

## Prompt de base — grande planche 16 × 5

```text
Use case: stylized-concept
Asset type: complete 80-slot source atlas for a 32x32 2D platformer tileset
Input images: Image 1 is the mandatory structural reference. Preserve exactly
its centered 16-column by 5-row grid and keep the top and bottom safety bands
empty. Use Image 2 only as the visual style reference if supplied.
Primary request: fill slots T00 through T79 according to the supplied manifest,
exactly one requested tile or object per slot.
Style/medium: detailed hand-painted pixel-art-ready game assets, orthographic
side view, strong silhouettes, readable after reduction to 32x32 pixels.
Composition/framing: exactly 80 independent square slots; consistent camera,
material scale and lighting; no element may cross a divider or enter the safety
bands.
Color palette: near-black iron, oxidized copper, verdigris, turquoise glass,
moss green and restrained brass highlights.
Constraints: preserve the 16x5 organization; no missing or additional slots; no
text; no visible slot identifiers; no logos; no watermark.
```

La grande planche est utile pour la cohérence générale. Pour un élément important
ou difficile, produire d'abord ses variantes sur la grille 4 × 4 reste plus fiable,
puis intégrer la variante retenue dans le manifeste 16 × 5.

## Reproduction

```sh
python3 sources/imagegen/generate_grid_template.py
```

Le manifeste JSON contient les coordonnées de découpe déterministes des cases
`A1` à `D4`.
