# Animation personnage 4×4 — proposition v001

Mode : génération avec l’outil `imagegen` intégré.

## Images de référence

1. `player-mechanic-idle-v002-source.png` : identité stricte du personnage.
2. `character-animation-grid-4x4-clean.png` : disposition stricte des 16 cases.

## Prompt final

```text
Use case: stylized-concept
Asset type: 4×4 animation concept sheet for a Godot 2D platform-game character
Input images: Image 1 is the strict character identity reference; Image 2 is the strict 4×4 placement template, a 1024×1024 canvas divided into sixteen equal 256×256 cells.
Primary request: fill all sixteen cells with exactly one full-body pose of the same greenhouse mechanic-gardener from Image 1, preserving identity across every cell: same copper-orange tousled hair, face and cyan eye, green scarf, charcoal shirt, dark teal overalls, copper belt and pouch, gloves and brass boots. No helmet and no weapon.
Grid and sequence, left to right:
Row A: four-frame subtle breathing idle cycle — neutral, inhale, slight settle, return.
Row B: four-frame right-facing walk cycle — contact, down, passing, up — with genuinely distinct readable leg and arm positions.
Row C: takeoff crouch, airborne rising pose, airborne falling pose, landing/recovery pose.
Row D: four-frame ladder-climbing cycle viewed mostly from the back/right — alternating hands and feet, suitable for looping.
Style/medium: crisp authentic 16-bit pixel art, deliberate square pixel clusters, hard edges, limited palette, no antialiasing, matching Image 1 exactly.
Composition/framing: every cell contains exactly one complete character and nothing else; character faces right except ladder frames; same apparent character scale in every cell; each pose centered on the same vertical axis; feet of all grounded frames aligned to the same baseline near the bottom of each cell; generous separation from all cell edges; never cross a cell boundary.
Scene/backdrop: perfectly uniform flat solid #ff00ff chroma-key background across the entire sheet, with no visible grid lines, labels, shadows, gradients, texture or floor. Do not use #ff00ff in the character.
Constraints: exactly 16 poses in a strict 4 columns by 4 rows arrangement; preserve costume, colors, facial identity and body proportions; poses must differ only as needed by their animation; no extra character, no duplicate inside a cell, no weapon, no rope, no ladder object, no platform, no scenery, no text, no numbering, no borders, no watermark.
```

La sortie native de l’outil mesure 1254 × 1254 px. La prévisualisation a été
normalisée en 1024 × 1024 au filtre nearest-neighbor pour retrouver exactement
les 16 cases de 256 × 256 définies par notre contrat. Elle n’est pas intégrée à
Godot tant que son apparence n’a pas été validée.
