# AssetForge

AssetForge est un pipeline générique de production d’assets visuels assisté par IA.

Son objectif n’est pas seulement de générer une belle image, mais de transformer une intention visuelle en un paquet d’asset cohérent, vérifiable, versionné et exploitable dans un projet réel.

## Règle fondatrice

AssetForge est un moteur générique, mais chaque projet possède sa propre mémoire artistique.

Chaque projet conserve localement :

- sa conversation de découverte visuelle ;
- sa charte graphique ;
- ses décisions et leurs raisons ;
- ses références approuvées ;
- ses prompts versionnés ;
- ses assets générés, rejetés et validés ;
- son catalogue et son état de production.

AssetForge ne partage jamais automatiquement une identité visuelle entre deux projets.

## Principe

```text
Conversation guidée par projet
        ↓
Charte graphique explicite
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
Catalogue du projet
```

## Deux niveaux

### Moteur AssetForge

Le moteur fournit les capacités communes :

- discussion artistique guidée ;
- formalisation de la charte ;
- construction de prompts ;
- validation ;
- traitement d’image ;
- export ;
- catalogage.

### Espace local du projet

Après `assetforge init`, le dépôt utilisateur reçoit :

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
└── catalog/
```

## Commandes fondatrices

```bash
assetforge init
assetforge discuss
assetforge status
```

- `init` crée l’espace AssetForge du projet courant ;
- `discuss` mène ou reprend la conversation qui construit la charte ;
- `status` affiche l’état de la charte, de la planche canonique et de la production.

## Priorité actuelle

La première étape n’est pas la génération isolée d’une image. C’est la production, par conversation, d’une charte graphique suffisamment précise pour piloter ensuite une planche d’identité visuelle et des familles d’assets cohérentes.

## V0

La V0 doit savoir :

- initialiser AssetForge dans n’importe quel projet ;
- reprendre une conversation sans perdre les décisions précédentes ;
- produire `charter.md` et `charter.yaml` ;
- enregistrer les décisions dans `decisions.yaml` ;
- produire les règles techniques dans `production-rules.yaml` ;
- construire un prompt versionné de planche d’identité visuelle ;
- conserver une planche validée comme référence canonique ;
- exposer clairement l’état du pipeline.

La génération, le détourage, les atlas et les exporteurs moteurs viendront ensuite comme modules séparés.

## Structure du dépôt AssetForge

```text
assetforge/
├── docs/
├── schemas/
├── presets/
├── prompts/
├── examples/
├── templates/
└── src/
```

## État

Bootstrap en cours. Le contrat de fonctionnement par projet est maintenant fixé.