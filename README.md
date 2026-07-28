# AssetForge

AssetForge est un pipeline générique de production d’assets visuels assisté par IA.

Son objectif n’est pas seulement de générer une belle image, mais de transformer une intention visuelle en un paquet d’asset cohérent, vérifiable, versionné et exploitable dans un projet réel.

## Principe

```text
Contexte du projet
        ↓
Planche d’identité visuelle
        ↓
Profil visuel canonique
        ↓
Spécification d’asset
        ↓
Génération ou import
        ↓
Traitement technique
        ↓
Validation
        ↓
Export cible
        ↓
Catalogue
```

## Priorité actuelle

La première étape d’AssetForge est la création d’une planche d’identité visuelle suffisamment bien spécifiée pour devenir une référence stable pour toutes les générations suivantes.

## V0

La V0 doit savoir :

- initialiser un espace AssetForge ;
- décrire un projet et sa direction artistique ;
- construire un prompt de planche d’identité visuelle ;
- conserver la planche validée comme référence ;
- produire un profil visuel structuré ;
- décrire un asset avec une spécification générique ;
- accueillir une image générée ou importée ;
- préparer les traitements, validations et exports futurs.

## Structure

```text
assetforge/
├── docs/
├── schemas/
├── presets/
├── prompts/
├── examples/
├── src/
└── workspace/
```

## État

Bootstrap en cours. Le dépôt commence volontairement par le contrat visuel et la structure du pipeline avant d’ajouter les fournisseurs d’image et les exporteurs moteurs.
