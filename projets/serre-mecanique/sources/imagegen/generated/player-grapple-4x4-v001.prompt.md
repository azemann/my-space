# Player grapple 4x4 — v001

## Statut

Aperçu à valider avant intégration dans Godot.

## Découpage temporel demandé

- frames 1–3 : `fire_attach` — anticipation, départ, accroche reconnue ;
- frames 4–6 : `tension_build` — mise en tension et perte du sol ;
- frames 7–9 : `taut_swing` — balancement aérien sous forte tension ;
- frames 10–12 : `swing_through` — passage rapide dans l’arc ;
- frames 13–14 : `reel_in` — corps regroupé et tiré vers l’ancrage ;
- frames 15–16 : `release_recover` — libération et retour au vol libre.

## Prompt

Create exactly 16 distinct state-driven grappling poses in a strict 4 columns by
4 rows sheet. The conceptual anchor is above and to the image-right. Preserve the
approved helmetless mechanic identity, proportions, palette and pixel rendering.
The weapon and rope are separate Godot layers: draw no weapon, gun, rope, hook or
anchor. Use the body, trailing legs, hair and scarf to express tension, momentum,
reeling and release. One complete character per cell on a perfectly uniform
`#ff00ff` background, without text, grid, shadows or decoration.

## Références employées

- `player-mechanic-idle-v002-source.png` — identité
- `player-idle-4x4-v001-preview.png` — proportions et rendu
- `player-jump-4x4-v001-preview.png` — corps aérien
- `character-animation-grid-4x4-clean.png` — grille
