# Frontière entre générique et Serre mécanique

## Les trois couches

```text
addons/my_space_core/         briques Godot réutilisables
addons/tiled_level_pipeline/  conversion TMX/TSX pilotée par un profil
             ↑
game/serre/                   règles et adaptations propres au jeu
             ↑
assets, maps, scenes, resources
                              contenu produit pour Serre mécanique
```

`addons/serre_editor/` est volontairement spécifique : il présente les niveaux
de Serre dans l'éditeur et demande confirmation avant leur régénération.

## Règle de dépendance

Le jeu peut importer le générique. Le générique ne doit jamais importer le jeu.
En particulier, aucun fichier de `addons/my_space_core/` ou de
`addons/tiled_level_pipeline/` ne doit contenir les mots `serre`, `racines`,
`niveau-01` ou le chemin d'un asset du projet.

## Classement actuel

| Couche | Contenu |
|---|---|
| cœur générique | caméra, configuration de personnage, niveau natif, équipement |
| pipeline générique | lecture TMX/TSX, TileMapLayer, formes de collision et métadonnées |
| profil Serre | niveaux figés, chemins de sortie, registre d'objets, matériau et extension des échelles |
| gameplay Serre | joueur, grappin, échelles, interactions et lancement d'un niveau |
| contenu Serre | PNG, TSX, TMX, scènes, ressources réglées et documentation créative |

## Ajouter un autre jeu

1. Copier ou partager les deux dossiers génériques.
2. Créer son propre profil Tiled sur le modèle de
   `game/serre/tiled/serre_tiled_profile.gd`.
3. Fournir son propre registre d'objets et ses scènes de gameplay.
4. Créer un panneau d'éditeur spécifique seulement si le projet en a besoin.

Un nouveau jeu ne doit pas modifier le convertisseur pour ajouter ses niveaux :
il modifie uniquement son profil.
