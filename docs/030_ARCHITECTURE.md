# Architecture

## Pipeline

```text
Project Brief
    ↓
Visual Identity Board Spec
    ↓
Prompt Builder
    ↓
Image Provider / Manual Import
    ↓
Human Validation
    ↓
Canonical Style Profile
    ↓
Asset Spec
    ↓
Image Processor
    ↓
Validator
    ↓
Exporter
    ↓
Catalog
```

## Modules

### `brief`

Décrit le projet, son public, son support, son ambiance et ses contraintes.

### `identity`

Construit la planche d’identité visuelle, conserve les variantes exploratoires et verrouille une référence canonique.

### `prompt-builder`

Assemble les prompts depuis des données structurées. Les prompts générés restent enregistrés et versionnés.

### `providers`

Adaptateurs interchangeables pour les services de génération d’image ou pour un import manuel.

Le premier adaptateur utilise l’Image API OpenAI avec `gpt-image-2`. Le cœur ne
connaît que le résultat normalisé et les métadonnées de provenance ; la clé API
n’est jamais stockée dans l’espace du projet.

### `processing`

Conversion, canal alpha, recadrage, padding, redimensionnement, miniatures et calcul de bounding box.

La V0 utilise Sharp pour normaliser les PNG statiques. Comme GPT Image 2 ne
fournit pas actuellement de transparence native, AssetForge peut convertir un
fond uniforme connecté aux bords en canal alpha avant le recadrage.

### `validation`

Contrôles techniques automatiques et validation artistique humaine.

### `exporters`

Adaptateurs pour Web, Phaser, PixiJS, Godot, Unity, Android ou autres cibles.

### `catalog`

Index de tous les assets, versions, sources, prompts, validations et exports.

## Contrats stables

Le cœur ne doit connaître ni les API des fournisseurs ni les formats propres aux moteurs. Il échange uniquement des contrats structurés :

- `project-brief` ;
- `identity-board-spec` ;
- `style-profile` ;
- `asset-spec` ;
- `validation-report` ;
- `export-manifest`.

## Répertoires de travail

```text
.assetforge/
├── project.yaml
├── status.yaml
├── conversation/
├── charter/
├── references/
├── prompts/
├── generated/
├── approved/
├── rejected/
├── catalog/
└── reports/
```

Cette arborescence est l’unique espace de travail canonique. Les futurs détails
par asset seront ajoutés sous ces répertoires sans introduire une seconde racine
`workspace/`.
