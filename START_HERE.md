# Démarrage AssetForge

AssetForge s’utilise depuis le dépôt du projet qui doit recevoir les assets.

## 1. Initialiser le projet

Commande disponible :

```bash
assetforge init
```

La commande cible le dossier courant. Un autre projet peut être fourni
explicitement, ainsi que son identité stable :

```bash
assetforge init /chemin/vers/kidiplay \
  --id kidiplay \
  --name "KidiPlay" \
  --type children-app
```

Elle n’écrase jamais un espace existant. Si le projet est déjà initialisé, elle
le signale sans modifier ses fichiers.

Elle crée :

```text
.assetforge/
├── project.yaml
├── status.yaml
├── conversation/
│   └── visual-discovery.md
├── charter/
│   ├── charter.md
│   ├── charter.yaml
│   ├── decisions.yaml
│   └── production-rules.yaml
├── references/
├── prompts/
│   └── identity/
├── generated/
├── approved/
├── rejected/
└── catalog/
```

## 2. Commencer la conversation

Commande disponible :

```bash
assetforge discuss
```

L’assistant guidé ne remplit pas un formulaire à la place de l’utilisateur. Il mène une conversation progressive :

1. comprendre le projet et l’expérience recherchée ;
2. préciser les contraintes techniques réelles ;
3. proposer plusieurs directions artistiques ;
4. comparer leurs forces, risques et coûts de production ;
5. permettre de mélanger ou corriger les propositions ;
6. stabiliser une direction ;
7. écrire la charte et l’historique des décisions.

La conversation est enregistrée dans :

```text
.assetforge/conversation/visual-discovery.md
```

Elle peut être reprise plus tard sans recommencer à zéro.

Pour un parcours automatisé ou reproductible, un brief conforme au schéma JSON
peut être fourni :

```bash
assetforge discuss --brief project-brief.json --yes
```

## 3. Produire la charte du projet

La conversation validée génère :

```text
.assetforge/charter/
├── charter.md
├── charter.yaml
├── decisions.yaml
└── production-rules.yaml
```

- `charter.md` est lisible par l’équipe ;
- `charter.yaml` est exploitable par le pipeline ;
- `decisions.yaml` conserve les choix et leurs raisons ;
- `production-rules.yaml` décrit les tailles, formats, transparence, animation et plateformes.

## 4. Générer le prompt de planche

Commande disponible :

```bash
assetforge identity prompt
```

Elle combine la charte, les règles de production et les décisions validées pour créer :

```text
.assetforge/prompts/identity/identity-board-v001.md
```

## 5. Produire plusieurs explorations

Après avoir défini `OPENAI_API_KEY`, créer deux à quatre planches exploratoires :

```bash
assetforge identity generate --count 3 --size 1536x1024 --quality medium
```

```text
.assetforge/generated/identity/
├── board-a.png
├── board-b.png
└── board-c.png
```

Elles ne sont pas encore canoniques.

## 6. Valider une direction

Une planche ou une synthèse est approuvée et copiée dans :

```text
.assetforge/approved/identity/
```

```bash
assetforge identity approve board-b001-01.png
```

La charte peut alors être ajustée pour correspondre à la référence réellement retenue.

## 7. Vérifier l’état

Commande disponible :

```bash
assetforge status
```

Elle doit montrer au minimum :

```text
Projet                  initialisé
Conversation            en cours | stabilisée
Charte                   absente | brouillon | canonique
Planche d’identité       absente | exploratoire | canonique
Profil visuel            absent | prêt
Production d’assets      bloquée | autorisée
```

## Ordre de construction du logiciel

1. ~~`assetforge init`.~~
2. ~~Modèle de données par projet.~~
3. ~~`assetforge status`.~~
4. ~~Protocole de conversation `assetforge discuss`.~~
5. ~~Génération de la charte structurée.~~
6. ~~Génération du prompt de planche.~~
7. ~~Versionnement des planches et validations.~~
8. ~~Spécification d’asset statique.~~
9. ~~Import et traitement PNG.~~
10. Adaptateurs de génération d’assets et exporteurs moteurs.
