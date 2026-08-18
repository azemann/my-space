# Tri de la sauvegarde précédente

## Réutilisé et migré

- sources ImageGen RGBA d'architecture et de nature ;
- principe d'empaquetage par cellules de 32 px sans redimensionnement ;
- ancres bas-centre et boîtes de contenu ;
- atlas de terrain v004 conservé comme candidat technique ;
- principes de tests : dimensions, transparence, chevauchements et grille ;
- convertisseur Tiled et dock Godot, déjà conservés lors de la remise à zéro.

## Réécrit pour la nouvelle architecture

- catalogue de 71 objets avec noms fonctionnels ;
- groupes, calques conseillés et rôles explicites ;
- générateur du TileSet Godot ;
- contrat de couches et règles de franchissement ;
- tests centrés sur les assets plutôt que sur une ancienne scène.

## Conservé seulement comme référence

- `candidates/world-terrain-v004.png` : raccords déterministes mais atlas trop
  mélangé pour devenir canonique sans migration ;
- `candidates/world-objects-v004.*` : preuve et comparaison avec le nouvel
  empaquetage nommé.

## Non réactivé

- ancienne carte `world-01.tmx` ;
- anciens TSX ;
- anciennes scènes principales et générées ;
- ancien joueur provisoire ;
- ancien `world.tres` ;
- caches `.godot` et fichiers `.import` copiés.

Ces éléments restent disponibles dans la sauvegarde temporaire, mais ne doivent
pas redevenir des dépendances du projet.
