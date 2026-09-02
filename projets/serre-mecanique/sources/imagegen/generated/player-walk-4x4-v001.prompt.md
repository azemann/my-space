# Marche du personnage 4×4 — proposition v001

Mode : génération avec l’outil `imagegen` intégré.

Références : identité d’origine, planche `idle` validée et grille propre 4×4.

## Prompt final

```text
Use case: stylized-concept
Asset type: dedicated 16-frame walk-cycle concept sheet for a Godot 2D platform-game character
Input images: Image 1 is the original strict character identity reference. Image 2 is the approved dedicated idle sheet and is the strict reference for current proportions, pixel-art treatment, costume shapes, palette and apparent scale. Image 3 is the strict 4×4 placement template, read left-to-right and top-to-bottom.
Primary request: create one seamless sixteen-frame right-facing walk loop of exactly the approved greenhouse mechanic-gardener. Preserve copper-orange tousled hair, face and cyan eye, green scarf, charcoal shirt, dark teal overalls, copper belt and pouch, gloves, brass boots, proportions and personality. No helmet and no weapon.
Biomechanical sequence — two complete steps, eight frames per step:
Frames 1 and 9: contact poses, forward heel just touching down, rear toe finishing push-off; opposite leg leads in frame 9.
Frames 2 and 10: recoil/down poses, weight accepted over the front foot, knees flexed, body at its lowest.
Frames 3 and 11: early passing poses, rear foot lifts and begins passing the support leg.
Frames 4 and 12: passing poses, moving foot directly below the hips, support leg nearly straight.
Frames 5 and 13: high/up poses, body at its highest, moving knee travels forward.
Frames 6 and 14: late passing poses, moving lower leg unfolds toward the next contact.
Frames 7 and 15: pre-contact poses, heel reaches forward while rear heel rises.
Frames 8 and 16: transition poses flowing naturally into the opposite contact pose and then seamlessly back to frame 1.
Motion constraints: exactly two symmetrical but hand-drawn steps; opposite arm and leg swing; support foot remains visually planted during its support phase; modest vertical body bob of only a few pixels; pelvis and shoulders counter-rotate subtly; scarf tip, hair tips and belt pouch follow with delayed secondary motion. The walk is agile and grounded, not a run, march, skip or exaggerated cartoon strut.
Style/medium: crisp authentic 16-bit pixel art matching the approved idle sheet exactly, deliberate square pixel clusters, hard edges, limited palette, no antialiasing or painterly smoothing.
Composition/framing: strict 4 columns × 4 rows, exactly one complete character per cell, same apparent scale, same horizontal center, all ground-contact boots meet the same baseline, generous padding, never cross cell boundaries, every pose faces right.
Scene/backdrop: perfectly flat uniform solid #ff00ff chroma-key background across the whole sheet, with no visible grid lines, labels, shadows, gradients, texture, floor or reflections. Do not use #ff00ff in the character.
Constraints: exactly sixteen poses; preserve identity, costume and palette rigorously; no helmet, weapon, rope, ladder, platform, scenery, text, numbering, borders or watermark.
```

La sortie native mesure 1254 × 1254 px. La prévisualisation est normalisée en
1024 × 1024 au filtre nearest-neighbor. Le détourage et le réalignement des
appuis seront effectués uniquement après validation visuelle.
