# Plage du réveil

Première carte canonique du récit. Azeman se réveille sur le sable sans savoir
qui il est. La carte expose une situation — mer, dunes, épave et effets
personnels — sans encore expliquer le monde ni l'origine de ses pouvoirs.

## Autorités

- `pipeline/tiled/maps/source/plage-du-reveil.tmx` : placement maître Tiled ;
- `game/world/maps/generated/plage-du-reveil.tscn` : résultat automatique ;
- `game/world/maps/plage-du-reveil/plage-du-reveil.tscn` : composition runtime ;
- `game/world/tileset/beach/` : terrains et objets littoraux normalisés ;
- `pipeline/assets/sources/imagegen/beach/` : sources visuelles non destructives.

## Lecture spatiale

- nord : dunes bloquantes et sortie future vers l'intérieur des terres ;
- centre : zone de réveil et principaux débris de l'épave ;
- sud : sable humide, rivage, écume, hauts-fonds puis mer profonde ;
- côtés : bras rocheux fermant visuellement la crique.

Le joueur apparaît au point `beach-awakening`. L'eau, le rivage et les falaises
sont bloqués par les volumes de `CollisionOverrides`, indépendamment de leurs
tuiles visuelles. Les dunes utilisent deux polygones autoritaires épousant
l'entonnoir du passage nord. Les quatre limites du monde restent fermées ; la
sortie nord est un déclencheur nommé.

## Profondeur et collisions

La scène est composée en cinq plans : sol sec, bande humide, objets plaqués au
sol, objets Y-sortés et silhouettes de premier plan. Azeman possède une ombre
ancrée à ses pieds ; les objets psychokinétiques conservent la leur au sol quand
leur visuel prend de la hauteur.

| Calque Tiled | Collision Godot |
| --- | --- |
| `GroundObjects` | désactivée ; détails traversables |
| `WaterObjects` | désactivée ; accessoire visuel uniquement |
| `YSortedObjects` | empreinte de l'asset, si son rôle est solide |
| `ForegroundObjects` | désactivée ; occultation visuelle uniquement |
| tous les calques peints | désactivée ; ils décrivent seulement l'image |
| `CollisionOverrides` | autorité unique de l'eau, du relief et des limites |

Les empreintes des rochers, troncs et petits obstacles sont des octogones
centrés sur leur base visible, jamais des boîtes couvrant tout le sprite.

## Amorces narratives

- `SatchelClue` : effet personnel à examiner ;
- `MetallicShardClue` : fragment inhabituel sans explication imposée ;
- `TelekinesisDiscovery` : zone entourant la première pierre manipulable ;
- `Entities/PierreEtrangeSpawn` : placement Tiled de son instance physique.

La pierre est instanciée comme `PsychokineticBody2D`. Le prototype permet de la
saisir, la maintenir, la déposer et la projeter. Les autres indices restent de
simples amorces narratives jusqu'à la définition de leur comportement.

## Ambiance sonore spatiale

La scène éditable expose `Runtime/Ambience` avec quatre
`AudioStreamPlayer2D` configurables dans l'Inspecteur Godot : rivage central,
rochers ouest, rochers est et mouettes de la plage haute. Les deux sources
latérales partagent le même asset audio. Le joueur porte l'`AudioListener2D` ;
les volumes varient donc selon sa position et non selon un découpage brutal.

Les trois assets vivent dans `game/audio/ambience/beach/` et utilisent le bus
`Ambience`. Modifier les positions, `Max Distance`, `Attenuation` et
`Volume Db` dans la scène éditable, jamais dans la scène générée depuis Tiled.

## Sable humide et empreintes de pas

La limite supérieure du sable humide est un contour auteur irrégulier dans
`GroundVariations`. Elle emploie les transitions courbes et diagonales de la
famille `13_beach_wet_sand` au lieu d'une bande rectangulaire.

La scène éditable expose `Runtime/Footprints`. Ce composant lit le champ
`terrain_kind` de `GroundVariations` et ne crée une empreinte que sur
`wet_sand`. La scène de l'empreinte, sa disparition et l'espacement des pas
sont configurés par `beach_wet_sand_footprints.tres`. Modifier ce profil, la
scène `footprint_decal.tscn` et son `AnimationPlayer` dans Godot ; le script ne
fait que détecter la marche, alterner les pieds et instancier la scène.

## Reconstruction

Les 30 objets sont détourés depuis la source chroma en isolant les composantes
opaques, puis rangés dans une spritesheet RGBA régulière de 6×5 cellules
(160×96 px). Un objet qui déborde de sa zone source reste ainsi entier sans
récupérer de fragment du voisin.

```bash
python3 pipeline/assets/builders/normalize_beach_terrain.py
python3 pipeline/assets/builders/build_beach_objects.py
godot --headless --path . --script res://pipeline/assets/builders/build_tileset.gd
python3 pipeline/tiled/tools/export_tilesets.py
python3 pipeline/tiled/tools/build_beach_map.py
godot --headless --path . --script res://pipeline/tiled/tools/convert_all.gd
```
