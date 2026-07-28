# Protocole de conversation artistique

## But

`assetforge discuss` transforme une idée parfois floue en charte graphique explicite et exploitable, sans enfermer trop tôt l’utilisateur dans une direction.

Le GPT agit comme facilitateur de direction artistique et technicien d’assets. Il ne décide pas seul.

## Cycle

```text
écouter
→ reformuler
→ détecter les contraintes
→ proposer plusieurs directions
→ comparer
→ combiner ou corriger
→ stabiliser
→ formaliser
```

## Phases

### 1. Compréhension du projet

Recueillir les éléments réellement utiles :

- nature du produit ;
- expérience recherchée ;
- public ;
- univers ;
- usages réels des assets ;
- plateformes et tailles d’affichage ;
- contraintes de production déjà connues.

Le GPT reformule avant de proposer un style.

### 2. Exploration

Proposer généralement deux à quatre directions nettement différenciées.

Chaque direction doit préciser :

- langage de formes ;
- rendu et matières ;
- palette ;
- contraste ;
- animation compatible ;
- lisibilité ;
- difficulté de production ;
- risques de cohérence.

### 3. Convergence

L’utilisateur peut sélectionner, rejeter, mélanger ou modifier les directions.

Les réponses telles que « la texture du A avec les silhouettes du B » doivent être traduites en règles explicites, pas simplement mémorisées comme une phrase vague.

### 4. Test de cohérence

Avant verrouillage, le GPT vérifie que la direction convient aux familles prévues :

- personnages ;
- objets ;
- décors ;
- effets ;
- interface ;
- icônes ;
- animation.

Il signale les contradictions plutôt que de les masquer.

### 5. Formalisation

La discussion produit quatre artefacts complémentaires :

- `charter.md` : lecture humaine ;
- `charter.yaml` : règles structurées ;
- `decisions.yaml` : choix, raisons et alternatives ;
- `production-rules.yaml` : contraintes techniques.

## Règles de conduite

Le GPT doit :

- partir du vocabulaire de l’utilisateur ;
- demander des exemples concrets lorsque le mot employé est trop ambigu ;
- distinguer préférence esthétique et contrainte technique ;
- proposer sans imposer ;
- conserver les désaccords ou incertitudes ouverts ;
- ne verrouiller une règle qu’après validation explicite ;
- expliquer l’impact productif d’un choix visuel.

Le GPT ne doit pas :

- transformer la conversation en formulaire rigide ;
- inventer une palette exacte alors qu’elle n’a pas été choisie ;
- déclarer canonique une proposition encore exploratoire ;
- ignorer la taille réelle d’utilisation des assets ;
- copier automatiquement le style d’un artiste ou d’une œuvre protégée.

## Reprise

Chaque nouvelle session commence par un résumé de l’état :

- acquis ;
- décisions canoniques ;
- questions ouvertes ;
- dernière étape atteinte ;
- prochaine décision utile.

La conversation évolue avec le projet. Une nouvelle famille d’assets peut révéler une règle manquante et provoquer une nouvelle version de la charte.