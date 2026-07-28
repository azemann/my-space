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

### `processing`

Conversion, canal alpha, recadrage, padding, redimensionnement, miniatures et calcul de bounding box.

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
workspace/
├── project.yaml
├── identity/
│   ├── brief.yaml
│   ├── prompts/
│   ├── explorations/
│   ├── canonical/
│   └── style-profile.yaml
├── assets/
│   └── <asset-id>/
│       ├── spec.yaml
│       ├── source/
│       ├── processed/
│       ├── validation/
│       └── exports/
└── catalog.json
```
