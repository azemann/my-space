# Cartes Tiled

- Les fichiers `.tmx` placés directement ici sont des niveaux de production.
- `niveau-01-serre.tmx` est explicitement figé et ignoré par le convertisseur.
- `niveau-02-racines.tmx` est la source de vérité du niveau 2.
- `niveau-03-automates.tmx` est la source de vérité du niveau 3.
- `niveau-04-arene-parcours.tmx` est la source Tiled de l'arène-parcours ; son
  intégration multijoueur dans Godot n'est pas encore réalisée.
- Les fichiers de `gabarits/` servent de modèles et ne sont pas régénérés
  automatiquement.
- Les fichiers de `examples/` sont des démonstrations techniques, pas des
  niveaux de production.

Ne jamais déplacer un gabarit dans ce dossier sans lui donner d'abord son nom de
niveau définitif et vérifier son tileset externe.
