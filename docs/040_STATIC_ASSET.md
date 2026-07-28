# Production d’un asset statique

## Objectif

La commande `assetforge generate` transforme une description ou un PNG existant
en dossier d’asset autonome, inspectable et directement intégrable.

Elle exige un profil visuel actif afin qu’un asset ne soit jamais produit sans
la mémoire artistique du projet courant.

## Génération avec l’Image API

```bash
export OPENAI_API_KEY="..."

assetforge generate environment rock_01 \
  --description "rocher cartoon vu de côté" \
  --size 256 \
  --transparent \
  --target phaser
```

## Traitement d’un PNG obtenu avec Codex ou un autre outil

```bash
assetforge generate environment rock_01 \
  --description "rocher cartoon vu de côté" \
  --size 256 \
  --transparent \
  --target phaser \
  --input /chemin/vers/rock-source.png
```

Ce second mode n’appelle aucune API d’image.

## Transparence

GPT Image 2 ne produit pas actuellement de fond transparent natif. Pour une
génération autonome, AssetForge demande donc un fond magenta uniforme, puis :

1. identifie le fond connecté aux bords ;
2. le remplace par un canal alpha ;
3. recadre le sujet ;
4. réserve une marge technique ;
5. redimensionne dans le canevas final ;
6. vérifie les dimensions, le format et la transparence.

Un PNG fourni avec un canal alpha valide est également accepté.

## Sortie

```text
assets/
└── environment/
    └── rock_01/
        ├── rock_01.png
        ├── rock_01.preview.png
        ├── rock_01.preview.html
        ├── rock_01.json
        └── source-prompt.md
```

Les métadonnées contiennent la provenance, les empreintes SHA-256, le pivot,
la collision simple, les informations du moteur cible et le rapport de
validation technique. L’asset est aussi ajouté à
`.assetforge/catalog/assets.json`.

## Limites de la V0

- assets statiques uniquement ;
- collision automatique limitée à une bounding box déclarative ;
- suppression de fond optimisée pour un fond uniforme ;
- pas encore de découpage de personnage, atlas ou animation.
