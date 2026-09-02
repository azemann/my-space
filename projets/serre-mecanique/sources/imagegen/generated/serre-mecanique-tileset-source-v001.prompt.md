# Serre mécanique — tileset source v001

Mode : outil ImageGen intégré.

Références :

1. `serre-mecanique-tileset-grid-16x5.png` — structure obligatoire ;
2. `assets/tilesets/serre-mecanique-concept-v1.png` — style uniquement.

## Prompt

```text
Use case: stylized-concept
Asset type: complete 80-slot source atlas for a 32x32 2D platformer tileset

Image 1 is the mandatory structural layout reference. Preserve its exact
landscape canvas, centered 16-column by 5-row grid, square cell boundaries, and
empty top and bottom safety bands. The gold grid lines are hard dividers:
nothing may cover them, touch them, cross them, merge through them, or enter the
safety bands.

Image 2 is a visual style reference only: an abandoned mechanical greenhouse,
hand-painted pixel-art-ready sprites, dark iron, oxidized copper, verdigris,
turquoise glass, moss and restrained brass highlights. Do not copy Image 2's
loose arrangement.

Fill the 80 grid cells with exactly one requested 2D side-view tile or object
per cell, in strict left-to-right, top-to-bottom order.

Row 1, T00-T15: dense stone fill; moss-topped stone fill; stone left edge; stone
right edge; stone bottom edge; moss stone left edge; moss stone right edge;
stone bottom-left corner; stone bottom-right corner; moss one-way platform left
cap; moss one-way platform middle; moss one-way platform right cap; metal
one-way platform left cap; metal one-way platform middle; metal one-way platform
right cap; compacted soil fill.

Row 2, T16-T31: stone brick wall A; mossy stone brick wall A; stone brick wall B;
mossy stone brick wall B; stone brick wall C; mossy stone brick wall C; plain
riveted iron panel; X-braced iron panel; barred iron panel; diagonal-braced iron
panel; left-capped vertical iron structure; right-capped vertical iron structure;
narrow vertical iron beam; narrow horizontal iron beam; rising diagonal iron
beam; falling diagonal iron beam.

Row 3, T32-T47: intact glass window frame; cracked glass window frame; glass
window with vertical mullion; glass window with horizontal mullion; glass window
with cross mullions; arched greenhouse window; horizontal copper pipe; vertical
copper pipe; right-and-down pipe elbow; left-and-down pipe elbow; T-junction
pipe; four-way pipe junction; pipe with valve wheel; pipe with round pressure
gauge; finned radiator pipe; vertical copper column with brass collars.

Row 4, T48-T63: iron floor spikes; thorn floor spikes; clear turquoise water
surface; toxic verdigris water surface; mechanical spring pad; lever in OFF
state; same lever in ON state; closed iron door; open iron doorway; climbable
brass ladder segment; climbable hanging chain segment; hanging glass liquid
bulb; collectible seed capsule on a small base; industrial gear; small
greenhouse sprout; glass control terminal.

Row 5, T64-T79: hanging vine variation A; hanging vine variation B; hanging vine
variation C; hanging vine variation D; exposed root variation A; exposed root
variation B; exposed root variation C; curved root variation D; low leafy plant
A; low leafy plant B; low leafy plant C; low leafy plant D; carnivorous
greenhouse flower; compact wheel-driven machine; oxidized pump/compressor; tall
glass liquid canister.

Detailed hand-painted pixel-art-ready 2D game art, orthographic side view,
strong silhouettes and simplified internal details readable after reduction to
32x32 pixels. One and only one asset per cell. Terrain fills may reach the inner
cell edges but must stop before the gold divider. Isolated props are centered
with generous internal padding. Modular variants share matching connection
heights. Preserve all 80 cells, every divider and both empty safety bands. No
text, numbers, labels, logos, watermark, perspective scene, characters, overlap
or cast shadows across cell boundaries.
```
