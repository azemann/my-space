# Audit des assets v004 récupérés

Les fichiers de ce lot ont été copiés depuis la sauvegarde de remise à zéro.
Aucune ancienne scène, ressource Godot générée ou carte TMX n'a été réactivée.

## À conserver

`assets/tilesets/candidates/world-objects-v004.png` contient 71 silhouettes
alignées. Le candidat v004 conserve leurs dimensions ImageGen originales ; le
lot actif v005 applique une normalisation unique par famille avant empaquetage.
Les meilleurs éléments sont :

- maison complète et fragments de façade ;
- toit, porte et fenêtres ;
- grand pont et escalier en pierre ;
- arbres de plusieurs tailles ;
- puits, rochers, souches, tonneaux et caisses ;
- murs, clôtures et portail ;
- buissons, fleurs, roseaux, cultures et plantes aquatiques.

Les images RGBA originales sont également restaurées dans
`sources/imagegen/tileset-v004/` afin de permettre un nouveau détourage ou un
nouvel empaquetage sans dégrader les pixels.

## À corriger avant activation

- remplacer les identifiants génériques `architecture_00` par des identifiants
  fonctionnels stables ;
- classifier chaque silhouette : décor, obstacle, interaction ou assemblage ;
- définir une empreinte de collision au sol indépendante de la silhouette ;
- définir l'ancre des pieds et l'origine de Y-sort ;
- séparer si nécessaire tronc et canopée ;
- vérifier les portes et fragments de maison pour construire de vrais accès ;
- générer un TileSet Godot compatible avec le nouveau contrat de couches.

## Terrain v004

`assets/tilesets/candidates/world-terrain-v004.png` reste une bonne référence
technique : grille 32 px, masques de raccord déterministes et coutures annoncées
exactes. Il mélange cependant terrain, objets et architecture dans un même atlas
et utilise l'ancien vocabulaire de couches. Il ne redevient donc pas canonique
sans migration.

## Éléments volontairement non restaurés

- ancienne scène jouable ;
- ancien `world.tres` ;
- anciens TMX et TSX actifs ;
- ressources générées ;
- ancienne organisation de calques.

Le nouveau projet récupère ainsi la qualité graphique sans reprendre la dette
architecturale du prototype précédent.
