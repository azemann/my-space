# KidiPlay Identity Atlas — v002

## Correction recherchée

La `v001` exprimait correctement le style mais utilisait des rectangles de
tailles variables. Cette version part d’un gabarit déterministe de quatre
colonnes par quatre lignes.

Le gabarit
[`kidiplay-grid-template-4x4.png`](kidiplay-grid-template-4x4.png) est fourni au
modèle comme structure obligatoire.

## Répartition des cellules

| Ligne | Colonne 1 | Colonne 2 | Colonne 3 | Colonne 4 |
|---|---|---|---|---|
| 1 | Mascotte | Jouer | Memory | Coloriage |
| 2 | Puzzle | Musique | Autocollants | Lapin |
| 3 | Renard | Éléphant | Lionceau | Bouton jouer |
| 4 | Bouton favori | Bouton étoile | Buisson fleuri | Nuage étoilé |

## Prompt de génération

```text
Use case: stylized-concept
Asset type: KidiPlay visual identity atlas and directly sliceable uniform
sprite sheet

Input image: the supplied image is the mandatory layout scaffold and edit
target.

Primary request: Fill the supplied 4-by-4 grid with exactly sixteen KidiPlay
assets while preserving the canvas dimensions, every vertical and horizontal
grid line, and all sixteen cell rectangles exactly as supplied. Do not move,
bend, erase, round, resize, reinterpret or add grid divisions.

Fixed cell map, left to right:
Row 1: cheerful gender-neutral bear cub mascot with coral neckerchief; play
triangle icon; pair of Memory cards icon; coloring palette and brush icon.
Row 2: four-piece puzzle icon; musical notes icon; peeled star sticker icon;
friendly rabbit.
Row 3: friendly fox; friendly elephant; friendly lion cub; coral rounded
illustrated button with play pictogram.
Row 4: mint rounded illustrated button with heart pictogram; sky-blue rounded
illustrated button with star pictogram; small rounded flowering bush; small
soft cloud with three tiny stars.

Art direction: gentle contemporary children’s illustration, rounded friendly
shapes, subtle colored-pencil and cut-paper texture, thick clean dark-warm
outlines, joyful readable expressions, polished but handmade, warm pastel
palette limited to coral #f88c6a, apricot #f8af5e, butter yellow #fedf82, mint
#b1dcbf, sky blue #a1cfee, lavender #c5aae2, warm cream #fcedd0 and soft brown
#cf9864.

Composition: exactly one complete isolated asset centered in each cell. Use
consistent padding of roughly 12 percent on every side. Nothing may cross or
touch a grid line. Maintain consistent scale within the icons, animals, buttons
and decor families. The mascot may be slightly larger inside its own cell but
must remain fully contained. Preserve the flat warm-cream cell backgrounds and
straight grid lines.

Constraints: no text, no labels, no logo, no watermark, no extra assets, no
shadows crossing boundaries, no floor plane, no overlaps, no cropped shapes.
The resulting image must remain a precise 4-column by 4-row sprite sheet that
can be sliced mechanically into sixteen equal cells.
```

## Dimensions

- sortie brute du modèle : `1254 × 1254` ;
- version normalisée : `1536 × 1536` ;
- grille : `4 × 4` ;
- cellule normalisée : `384 × 384`.
