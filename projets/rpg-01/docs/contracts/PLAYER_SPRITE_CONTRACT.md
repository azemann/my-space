# Contrat du sprite joueur

Ce contrat adapte les principes utiles de `fighter-sprites-2d` et des contrats
MySpace au RPG top-down. Les frames individuelles sont l'autorité visuelle ; la
planche et les ressources Godot sont des dérivés reproductibles.

## Invariants

- chaque frame source mesure exactement 64 × 64 px en RGBA ;
- le root logique est toujours `[32,56]`, entre les pieds ;
- la hauteur visuelle cible est de 40 à 48 px ;
- aucune frame n'est redimensionnée ou recentrée depuis sa bounding box ;
- une bounding box sert uniquement à mesurer les débordements ;
- `north`, `south`, `east` et `west` sont dessinées explicitement ;
- l'ordre des frames et leur durée viennent du manifeste, jamais du nom du
  fichier ou de leur position accidentelle dans une planche ;
- Godot possède le déplacement ; les frames ne produisent aucun root motion ;
- les collisions utilisent l'espace stable du `CharacterBody2D`, jamais les
  contours alpha ni les coordonnées d'un atlas compact.

## Premier lot

- `idle_<direction>` : 2 frames, boucle calme ;
- `walk_<direction>` : 4 frames, cycle contact/passage/contact/passage ;
- directions : `south`, `west`, `east`, `north` ;
- collision initiale : capsule/rectangle de pieds indépendante du graphisme ;
- interaction future : zone orientée séparée du corps physique.

## Maturité

Chaque lot distingue les états `visual`, `temporal`, `technical` et `gameplay`.
Une planche techniquement valide reste `candidate` jusqu'à inspection humaine
de l'identité, des directions et de la boucle.

## Recadrage futur

Un atlas compact peut rogner la transparence uniquement s'il enregistre pour
chaque frame : rectangle source, root local, rectangle d'atlas, empreinte
SHA-256 et offset Godot. Le recadrage ne devient jamais l'autorité de placement.

