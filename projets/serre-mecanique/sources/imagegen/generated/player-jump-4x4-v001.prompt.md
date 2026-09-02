# Player jump 4x4 — v001

Create a dedicated pixel-art character animation concept sheet for the JUMP movement, exactly 16 distinct frames arranged in a strict 4 columns by 4 rows layout. Read frames left-to-right, then top-to-bottom.

Preserve exactly the same established character identity, palette, apparent size, proportions, rendering, and pixel-art style shown in the references: no helmet, copper/orange hair, visible cyan eye, green scarf, charcoal shirt, dark teal overalls, copper belt and pouch, gloves, brass boots. No weapon, no gun, no rope, no grappling hook.

This is a state-driven jump sequence, NOT a seamless repeating loop:

- Frames 1–3: anticipation: slight crouch, deeper compression, maximum compression; both boots remain on the common ground baseline.
- Frames 4–6: takeoff: push upward, toe departure, then clearly leave the ground; body progressively extends.
- Frames 7–9: rising: unmistakable upward airborne poses, knees trailing then tucking slightly, scarf and hair lag downward; never resemble running.
- Frames 10–11: apex: vertical speed near zero, compact floating pose, clear transition toward descent.
- Frames 12–14: falling: increasingly clear downward poses, legs extend to prepare landing, scarf and hair lift upward.
- Frames 15–16: landing: first boot contact, then strong landing compression/recovery. Frame 16 does not need to loop to frame 1.

Every frame must be meaningfully different and biomechanically readable. Keep the character at a consistent apparent scale and centered inside each cell. Grounded frames share the same foot baseline. Airborne poses may move vertically but must remain safely inside their cells with padding. Preserve the silhouette and avoid cropping any hair, scarf, hand, pouch, or boot.

Technical visual constraints: transparent-looking solid chroma-key background exactly `#ff00ff`, no shadows, no floor, no platform, no decorative elements, no labels, no numbers, no text, no visible grid lines, no borders. Crisp deliberate pixel art only, hard edges, limited palette, no antialiasing blur, no painterly rendering, no gradients. Exactly 4x4 frames and exactly one full character per cell.

## Références employées

- `player-mechanic-idle-v002-source.png`
- `player-idle-4x4-v001-preview.png`
- `player-walk-4x4-v001-preview.png`
- `character-animation-grid-4x4-clean.png`
