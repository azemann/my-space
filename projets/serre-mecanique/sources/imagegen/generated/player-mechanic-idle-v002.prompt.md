# Personnage joueur sans casque — source v002

Mode : édition avec l’outil `imagegen` intégré.

## Prompt final

```text
Use case: precise-object-edit
Asset type: revised production source for a Godot 2D platform-game character sprite
Input image: edit target — the previously generated pixel-art greenhouse mechanic-gardener on a flat magenta background.
Primary request: remove the entire brass helmet and nothing else. Reveal the character's existing orange/copper hair as a simple practical short tousled haircut with a clean readable silhouette. Keep the same face, eye, expression, head direction, body proportions, pose, clothing, gloves, boots, green neck accent, utility belt and all colors below the neck.
Style/medium: preserve the exact crisp 16-bit pixel-art rendering, pixel scale, limited palette and side-view orientation of the input.
Composition/framing: keep exactly one full-body character centered at the same scale and in the same pose, facing right.
Scene/backdrop: preserve a perfectly flat uniform #ff00ff chroma-key background with no shadows, gradients, texture, floor, or reflections. Do not use #ff00ff in the character.
Constraints: change only the helmet/head covering; preserve every other visual feature as closely as possible. No hat, no helmet, no goggles, no headgear, no weapon, no extra object, no text, no border, no shadow, no watermark.
```

La source a été détourée, recadrée puis réduite au filtre nearest-neighbor. La
silhouette mesure 48 px de haut dans un canevas transparent de 64 × 64 px.
