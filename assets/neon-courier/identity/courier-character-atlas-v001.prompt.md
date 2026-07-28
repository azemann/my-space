# Neon Courier — Character Atlas v001

## Brief utilisateur

> Livreuse à vélo cyberpunk, combat avec une chaîne antivol, profil 2D,
> style arcade dessiné années 1990, énergique et coloré.

Le nom `Neon Courier` est provisoire.

## Prompt principal

```text
Use case: stylized-concept
Asset type: character identity atlas and motion-key sprite sheet for a
side-view 2D beat’em all

Input image: the supplied image is the mandatory 4-by-4 layout scaffold and
edit target.

Primary request: Fill the supplied grid with exactly sixteen full-body poses of
the same cyberpunk bicycle courier heroine. Preserve the square canvas, all
four columns, all four rows, every straight grid line, and every equal cell
exactly. Never merge, resize, bend, erase, round, or add grid divisions.

Character identity, identical in every cell: athletic young adult woman bicycle
courier, medium-brown skin, short dark curls visible under a streamlined teal
bicycle helmet, cropped magenta courier jacket with one yellow reflective
stripe, deep-purple shirt, teal cargo trousers with practical knee pads, chunky
high-top sneakers, fingerless gloves, compact orange cross-body delivery bag,
and one heavy bicycle security chain used as her weapon. No logos, no writing.
Practical street-fighter clothing, confident and energetic, never sexualized.
Keep face, body proportions, hairstyle, helmet, jacket, bag, colors and chain
design strictly consistent in all sixteen cells.

Fixed cell map, left to right:
Row 1: neutral combat idle facing right; walk contact pose facing right; fast
run pose facing right; guarded fighting stance with coiled chain.
Row 2: chain swing anticipation; horizontal chain strike at maximum extension;
chain strike follow-through; rising chain uppercut.
Row 3: low chain sweep; crouching dodge; jumping knee attack while holding the
chain; readable hit reaction.
Row 4: knocked-down pose; controlled get-up pose; victorious courier pose
holding the chain overhead; special spinning-chain attack pose.

Style/medium: energetic hand-drawn 1990s arcade beat’em all character art,
production sprite concept, bold dark ink contours, expressive angular linework,
clean cel shading, two or three shade levels, slightly exaggerated anatomy and
action silhouettes, crisp readable forms at game scale. Color palette:
saturated neon magenta, electric cyan/teal, bright yellow, orange accents, deep
purple shadows and asphalt-black outlines. No pixel art, no 3D rendering, no
photorealism.

Composition: one complete isolated full-body pose centered in each cell;
consistent character height and scale across cells; same side-view camera and
ground line; approximately 10 percent empty padding on all sides. The chain and
delivery bag must remain completely inside their cell. Poses may compress
vertically when knocked down or jumping but the body scale must not change. All
characters face right except where the action naturally turns the torso without
changing gameplay direction.

Backdrop: preserve the flat uniform warm-cream cell backgrounds and exact
dark-purple grid. No environment, no floor plane, no cast shadows.

Constraints: exactly sixteen versions of one character, no alternate costumes,
no bicycles, no enemies, no extra people, no text, no labels, no UI, no logos,
no watermark, no cropped limbs, no objects crossing grid lines, no duplicated
pose, no chain crossing a boundary.
```

## Correction ciblée

La première sortie coupait la chaîne et le pied dans la cellule de frappe
horizontale. Une édition a été appliquée uniquement à la cellule ligne 2,
colonne 2 afin de recentrer la pose et de conserver l’arme dans ses limites.

## Dimensions

- sortie brute : `1254 × 1254` ;
- version normalisée : `1536 × 1536` ;
- grille : `4 × 4` ;
- cellule : `384 × 384`.
