# Espace AssetForge d’un projet

## Principe

AssetForge est installé ou exécuté comme un moteur commun, mais toutes les données artistiques sont stockées dans le projet courant.

La racine locale est toujours :

```text
.assetforge/
```

Cet espace appartient au projet. Il peut être versionné avec Git afin que l’équipe partage la même charte, les mêmes références et les mêmes décisions.

## Arborescence

```text
.assetforge/
├── project.yaml
├── status.yaml
├── conversation/
│   ├── visual-discovery.md
│   └── sessions/
├── charter/
│   ├── charter.md
│   ├── charter.yaml
│   ├── decisions.yaml
│   └── production-rules.yaml
├── references/
│   ├── imported/
│   └── canonical/
├── prompts/
│   ├── identity/
│   └── assets/
├── generated/
│   ├── identity/
│   └── assets/
├── approved/
│   ├── identity/
│   └── assets/
├── rejected/
├── catalog/
│   └── assets.json
└── reports/
```

## Responsabilité des fichiers

### `project.yaml`

Identité stable du projet, type de produit, plateformes et version de format AssetForge.

### `status.yaml`

État synthétique du pipeline. Ce fichier ne remplace pas les artefacts sources ; il permet de savoir quelles étapes sont autorisées.

### `conversation/`

Mémoire de la discussion artistique. Elle contient les formulations de l’utilisateur, les propositions du GPT, les corrections, les incertitudes et les décisions retenues.

### `charter/`

Contrat artistique et technique du projet.

### `references/`

Images importées ou produites qui servent effectivement de références visuelles. Une image n’est canonique qu’après validation humaine.

### `prompts/`

Prompts résolus et versionnés. Les templates génériques restent dans le dépôt AssetForge ; les prompts produits appartiennent au projet.

### `generated/`

Productions non encore validées.

### `approved/`

Productions acceptées et utilisables.

### `rejected/`

Productions refusées conservées pour éviter de répéter les mêmes erreurs.

### `catalog/`

Index des assets, versions, statuts, formats, usages et relations.

## Isolation

AssetForge doit toujours résoudre le projet depuis le répertoire courant ou un chemin explicitement fourni.

Il est interdit de :

- réutiliser silencieusement la charte d’un autre projet ;
- modifier une charte canonique sans créer une nouvelle version ;
- traiter une image générée comme canonique sans validation ;
- autoriser la production finale tant que les prérequis déclarés dans `status.yaml` ne sont pas satisfaits.

## Portabilité

Le dossier `.assetforge/` doit rester lisible sans AssetForge. Les formats de base sont Markdown, YAML, JSON et images standards.