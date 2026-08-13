# Player climb 4x4 — v002

## Statut

Direction visuelle approuvée, alternance corrigée avec un guide de poses dédié. La planche reste à valider avant intégration dans Godot.

## Prompt final

Rebuild the approved visual direction of the referenced mechanic climbing sheet as exactly 16 sequential frames in a strict 4 columns by 4 rows layout.

Image 1 is the immutable character identity and costume reference. Image 2 is the approved visual direction, scale, palette, spacing, front-facing climbing presentation, and pixel-art rendering reference. Image 3 is a mandatory motion skeleton guide. Red and cyan are only explanatory limb colors and must not appear in the final character. Follow its opposing arm-and-leg geometry cell by cell.

Row 1 uses the image-left hand high with the image-right knee high. Row 2 passes through centered transfer poses with both boots changing support. Row 3 visibly reverses the silhouette: image-right hand high with image-left knee high. Row 4 transfers back toward row 1. Frames in rows 1 and 3 must be unmistakable opposing poses, not repetitions.

Preserve the helmetless copper/orange-haired young mechanic, cyan eyes, green scarf, charcoal shirt, dark teal overalls, copper belt and pouch, gloves and brass boots. No weapon, support, extra limbs or extra characters. Exactly one complete character per cell on a uniform `#ff00ff` background, with crisp hard-edged limited-palette pixel art.

## Références employées

- `player-mechanic-idle-v002-source.png` — identité
- `player-climb-4x4-v001-preview.png` — direction approuvée
- `character-climb-pose-guide-4x4.png` — squelette spatial obligatoire
