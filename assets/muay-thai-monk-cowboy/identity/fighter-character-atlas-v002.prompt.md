# Muay Thai Monk-Cowboy — Character Atlas v002

## Dérivation

Cette version reprend intégralement le brief et le prompt principal de
[`fighter-character-atlas-v001.prompt.md`](fighter-character-atlas-v001.prompt.md).

## Correction ciblée

La première sortie coupait la jambe basse de la frappe au coude horizontal
contre la bordure de sa cellule. Une édition a donc été appliquée uniquement à
la cellule ligne 3, colonne 4.

```text
Use case: precise-object-edit
Asset type: correction of one cell in a uniform 4-by-4 character identity
atlas.

Input image: edit target. Preserve the complete 1536-by-1536 square canvas and
exact 4-by-4 grid.

Primary request: Change only row 3, column 4, the horizontal-elbow-strike cell.
Slightly scale down and recenter that fighter pose so the complete body, both
legs, both feet, both fists, robe, hat and every accessory are fully visible
inside that one cell with generous cream-colored padding on all four sides.
Keep the pose as a powerful horizontal elbow strike facing right. The lower leg
must no longer touch or cross the bottom grid line, and the forward fist must
not touch the right grid line.

Invariants: keep the other fifteen cells pixel-for-pixel visually unchanged.
Preserve every straight dark-purple grid line and every equal cell exactly.
Preserve the fighter's face, enormous muscular proportions, shaved head,
saffron robe, indigo shorts, turquoise accent, oxblood wraps, leather guards,
hat on his back, palette, ink style and cel shading. Keep the corrected figure
at a scale consistent with the other action poses.

Constraints: change only row 3 column 4; no text, no labels, no extra figure, no
cropped limb, no object crossing a grid line, no new object, no watermark.
```

## Dimensions

- sortie brute : `1254 × 1254` ;
- version normalisée : `1536 × 1536` ;
- grille : `4 × 4` ;
- cellule : `384 × 384`.
