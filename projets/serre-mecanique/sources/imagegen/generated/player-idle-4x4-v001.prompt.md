# Repos du personnage 4×4 — proposition v001

Mode : génération avec l’outil `imagegen` intégré.

Références : identité `player-mechanic-idle-v002-source.png` et grille propre
`character-animation-grid-4x4-clean.png`.

## Prompt final

```text
Use case: stylized-concept
Asset type: dedicated 16-frame idle animation concept sheet for a Godot 2D platform-game character
Input images: Image 1 is the strict character identity and costume reference. Image 2 is the strict 4×4 placement template: a square canvas divided conceptually into sixteen equal cells, read left-to-right and top-to-bottom.
Primary request: create one seamless sixteen-frame breathing idle loop of exactly the same greenhouse mechanic-gardener from Image 1. Preserve the same copper-orange tousled hair, face, cyan eye, green scarf, charcoal shirt, dark teal overalls, copper belt and pouch, gloves, brass boots, proportions and right-facing three-quarter side view. No helmet and no weapon.
Animation timing and poses:
Frames 1–4: neutral to gentle inhale; chest and shoulders rise by a tiny amount, scarf tip and front hair lift slightly.
Frames 5–8: inhale apex back toward neutral; include one natural blink across frames 6–7, eyes open again by frame 8.
Frames 9–12: gentle exhale and very small relaxed weight settling through knees and shoulders; no step and no foot shift.
Frames 13–16: return gradually and exactly to the opening neutral pose so frame 16 connects seamlessly to frame 1.
Motion constraints: both boots remain fully planted at exactly the same position and baseline in all sixteen cells; hips and body center stay on the same vertical axis; no walking, stepping, arm gesture, head turn or costume change. Movement is subtle but each consecutive frame must show a coherent incremental change. Secondary motion only in chest, shoulders, scarf tip, hair tips and blink.
Style/medium: crisp authentic 16-bit pixel art matching Image 1, deliberate square pixel clusters, hard edges, limited palette, no antialiasing, no painterly smoothing.
Composition/framing: strict 4 columns × 4 rows, exactly one complete character per cell, identical apparent scale, generous padding, never cross cell boundaries. Every character centered consistently and facing right.
Scene/backdrop: perfectly flat uniform solid #ff00ff chroma-key background across the entire sheet. No visible grid lines, labels, shadows, gradients, texture, floor or reflections. Do not use #ff00ff in the character.
Constraints: exactly sixteen poses and no more; preserve identity rigorously; no helmet, weapon, rope, ladder, platform, scenery, text, numbering, borders or watermark.
```

La sortie native mesure 1254 × 1254 px. La prévisualisation est normalisée en
1024 × 1024 au filtre nearest-neighbor. Aucun détourage, réalignement individuel
ou import Godot n’est effectué avant validation visuelle.
