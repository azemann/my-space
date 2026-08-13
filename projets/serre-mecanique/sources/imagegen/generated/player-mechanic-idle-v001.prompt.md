# Personnage joueur — source v001

Mode : outil `imagegen` intégré, génération neuve.

## Prompt final

```text
Use case: stylized-concept
Asset type: production source for a Godot 2D platform-game character sprite
Primary request: create exactly one full-body player character, a compact greenhouse mechanic-gardener adventurer, facing right in a neutral ready stance. The character should feel clever, agile, friendly and suitable for grappling traversal and later Worms-like weapons.
Subject: one small human character only; rounded antique brass protective helmet with a small amber glass visor, dark teal work overalls, copper utility belt, sturdy boots, one tiny leaf-green accent such as a scarf tab. Hands empty and clearly separated from the body so a weapon can later be layered independently.
Style/medium: crisp authentic 16-bit pixel art matching a dark industrial mechanical-greenhouse tileset; deliberate clusters of square pixels, strong silhouette, limited palette, no smoothing, no painterly texture.
Composition/framing: orthographic side view, facing right, entire character visible, centered with generous padding; proportions designed for a 32x32 logical sprite cell, final occupied silhouette about 18 pixels wide by 28 pixels tall.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for background removal. The background must be one uniform color with no shadows, gradients, texture, floor, reflections, or lighting variation.
Color palette: charcoal, dark teal, oxidized green, antique brass, warm copper, tiny pale cyan highlight; do not use #ff00ff anywhere in the character.
Constraints: exactly one character and one pose; no weapon, no separate objects, no platform, no environment, no text, no border, no cast shadow, no contact shadow, no glow beyond the silhouette, no watermark. Crisp hard edge fully separated from the background.
```

La source a ensuite été détourée par chroma key, recadrée et réduite au filtre
nearest-neighbor dans une cellule transparente de 32 × 32 px.
