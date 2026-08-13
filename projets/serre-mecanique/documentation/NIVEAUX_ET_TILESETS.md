# Niveaux et tilesets

## Règle de séparation

Chaque niveau possède sa propre scène générée et sa propre ressource `TileSet`.
Le fichier TMX choisit son image par l'intermédiaire de son fichier TSX externe.
Le convertisseur ne suppose donc plus que tous les niveaux utilisent le même
tileset.

## Niveau 1 — figé

- source historique : `maps/niveau-01-serre.tmx` ;
- scène jouée : `scenes/levels/niveau-01-serre.tscn` ;
- image : `assets/tilesets/serre-mecanique-32x32.png` ;
- ressource Godot : `resources/tilesets/serre-mecanique.tres`.

`niveau-01-serre` appartient à `FROZEN_LEVELS` dans le convertisseur. La commande
**Régénérer les niveaux Tiled** l'ignore entièrement : sa scène et ses ressources
restent donc inchangées.

## Niveau 2 — La chambre des racines

- source éditable : `maps/niveau-02-racines.tmx` ;
- scène générée : `scenes/levels/niveau-02-racines.tscn` ;
- scène de test direct : `scenes/launchers/niveau-02.tscn` ;
- image dédiée : `assets/tilesets/niveau-02-serre-mecanique-32x32-v002.png` ;
- TSX dédié : `assets/tilesets/niveau-02-serre-mecanique-32x32-v002.tsx` ;
- ressource Godot : `resources/tilesets/niveau-02-racines.tres`.

Le parcours franchit deux canaux toxiques, monte par des paliers espacés de 64 px,
puis utilise une échelle et une chaîne pour les deux élévations de 96 px. Modifier
ce tileset ou régénérer cette scène ne peut pas modifier le niveau 1 figé.

## Niveau 3 — La nef des automates

- source éditable : `maps/niveau-03-automates.tmx` ;
- scène générée : `scenes/levels/niveau-03-automates.tscn` ;
- scène de test direct : `scenes/launchers/niveau-03.tscn` ;
- image de production : `assets/tilesets/niveau-03-serre-mecanique-32x32-v002.png` ;
- TSX dédié : `assets/tilesets/niveau-03-serre-mecanique-32x32-v002.tsx` ;
- ressource Godot : `resources/tilesets/niveau-03-automates.tres`.

La planche ImageGen d'origine reste la référence artistique. La version de
production conserve exactement ses 26 objets isolés, mais ses 54 cases
modulaires reprennent les masques raccordables validés du niveau 1. Elle est
reproductible avec `sources/imagegen/build_level_03_production_tileset_v002.py`.

## Niveau 4 — L'arène des semences

- source éditable : `maps/niveau-04-arene-parcours.tmx` ;
- scène générée : `scenes/levels/niveau-04-arene-parcours.tscn` ;
- scène de test solo : `scenes/launchers/niveau-04.tscn` ;
- image de production : `assets/tilesets/niveau-04-arene-combat-32x32-v001.png` ;
- TSX dédié : `assets/tilesets/niveau-04-arene-combat-32x32-v001.tsx` ;
- ressource Godot : `resources/tilesets/niveau-04-arene-parcours.tres`.

Le TMX prépare quatre apparitions et cinq emplacements d'armes. Godot importe
déjà ces repères, mais le lanceur reste volontairement solo tant que le système
multijoueur et les armes d'arène ne sont pas implémentés.
Le niveau possède huit calques visuels et huit calques d'objets, comme le niveau 2.

## Convention

```text
niveau NN
  -> maps/niveau-NN-<nom>.tmx
  -> assets/tilesets/niveau-NN-<nom>-32x32-vNNN.{png,tsx}
  -> resources/tilesets/niveau-NN-<nom>.tres
  -> scenes/levels/niveau-NN-<nom>.tscn
```
