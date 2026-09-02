# Player climb 4x4 — v001 (brouillon)

## Statut

Brouillon à valider. L’alternance des bras est mieux marquée que dans la première tentative, mais l’alternance des jambes reste insuffisante pour une animation finale.

## Prompt de correction employé

Revise the referenced 4x4 pixel-art climbing animation sheet while preserving the exact character identity, costume, palette, pixel rendering, scale, spacing, magenta background, and strict 4x4 layout.

The prior climbing attempt has one critical defect: nearly every cell repeats the same raised arm and the same raised knee, so it looks like posing in place. Fix this by making the opposing limb cycle unmistakable.

Create exactly 16 sequential climbing frames, read left-to-right and top-to-bottom:

- Frames 1–4: the hand on the IMAGE LEFT is visibly higher above the head, while the knee on the IMAGE RIGHT is lifted. Move gradually through reach, grip, and pull.
- Frames 5–8: pass through a centered transfer pose: hands briefly approach similar height, the raised IMAGE-RIGHT boot moves downward, and the other boot begins to lift.
- Frames 9–12: the hand on the IMAGE RIGHT is now visibly higher above the head, while the knee on the IMAGE LEFT is lifted. This must be the clear opposite/mirrored climbing phase.
- Frames 13–16: pass through the opposite centered transfer and return smoothly toward frame 1.

At minimum, frames 2 and 10 must be obvious opposing key poses: raised hand and raised knee switch sides. Hands must open or curl as if gripping invisible ladder rungs rather than looking like celebratory fists. The torso rises and falls slightly through each pull. Keep the climbing support invisible so this character animation can overlay ladders, chains, or vines in Godot.

Character invariants: same helmetless copper/orange-haired young mechanic, cyan eyes, green scarf, charcoal shirt, dark teal overalls, copper belt and pouch, gloves, brass boots. No weapon, no gun, no rope, no grappling hook. No extra limbs. No walking, running, jumping, fighting, dancing, or waving.

Exactly one complete character centered in each cell, consistent apparent scale and torso anchor, generous padding, no cropping. Perfectly flat uniform `#ff00ff` background. No floor, ladder, chain, vine, shadows, labels, numbers, text, grid lines, borders, or objects. Crisp hard-edged limited-palette pixel art, no antialiasing blur, no gradients, no painterly rendering.
