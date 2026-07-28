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
assetforge identity prompt
assetforge identity generate
assetforge identity approve <image>
assetforge generate <type> <name> --description <texte>
```

- `init` crée l’espace AssetForge du projet courant ; cette commande est implémentée ;
- `discuss` mène la conversation qui construit une charte canonique versionnée ;
- `status` calcule l’état réel depuis les artefacts du projet ;
- `identity prompt` produit un prompt de planche résolu et versionné ;
- `identity generate` appelle un fournisseur d’images et conserve la provenance ;
- `identity approve` valide humainement une planche comme référence canonique.
- `generate` transforme une description ou un PNG existant en asset statique
  normalisé, prévisualisable et catalogué.

Pour tester le CLI depuis ce dépôt :

```bash
npm test
npm link
assetforge init /chemin/du/projet --name "Mon projet" --type "jeu-2d"
```

`init` dérive par défaut le nom et l’identifiant depuis le dossier courant. Les
options `--id`, `--name` et `--type` permettent de les fixer explicitement. Une
seconde exécution ne modifie pas l’espace existant.

## Parcours exécutable

```bash
cd /chemin/vers/mon-projet

assetforge init --id mon-projet --name "Mon projet" --type jeu-2d
assetforge discuss
assetforge identity prompt

export OPENAI_API_KEY="..."
assetforge identity generate --size 1536x1024 --quality medium --count 3

assetforge status
assetforge identity approve board-b001-01.png
assetforge status

assetforge generate environment rock_01 \
  --description "rocher cartoon vu de côté" \
  --size 256 \
  --transparent \
  --target phaser
```

Un PNG déjà généré avec Codex, ImageGen ou un autre outil peut être traité sans
appel API grâce à `--input /chemin/source.png`.

Une charte existante peut aussi être importée sans interaction :

```bash
assetforge discuss --brief /chemin/vers/project-brief.json --yes
```

La génération utilise par défaut `gpt-image-2` via l’Image API OpenAI. La clé API
reste dans `OPENAI_API_KEY` et n’est jamais écrite dans `.assetforge/`. Un
abonnement ChatGPT et la facturation de l’API sont deux accès distincts.

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
├── bin/
├── docs/
├── schemas/
├── prompts/
├── examples/
├── templates/
├── src/
└── test/
```

## État

MVP opérationnel : initialisation, discussion guidée, charte versionnée, planche
d’identité, profil visuel et génération d’assets statiques PNG. Le découpage de
personnages, les sprite sheets, les animations et les exporteurs avancés restent
à construire.
