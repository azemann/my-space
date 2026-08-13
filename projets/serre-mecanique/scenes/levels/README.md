# Scènes de niveaux

- `niveau-01-serre.tscn` est figée : les changements Godot enregistrés sont
  conservés par la régénération Tiled.
- `niveau-02-racines.tscn` est générée : la modifier directement ne produit
  qu'un changement temporaire qui sera remplacé.

Les scènes `main*.tscn` situées dans le dossier parent assemblent un niveau, le
joueur et l'interface afin de pouvoir lancer chaque niveau avec F6.
