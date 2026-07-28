# Modèle générique des projets MySpace

## Principe

MySpace ne possède pas une direction artistique globale. Il fournit des
méthodes génériques, tandis que chaque projet possède son propre contexte, sa
mémoire créative et ses sorties.

```text
MySpace
├── méthodes génériques
├── contrats d’artefacts
├── règles de validation
└── projets indépendants
    ├── KidiPlay
    ├── un jeu 2D
    ├── une application
    └── une future création
```

Aucune référence approuvée dans un projet ne doit influencer silencieusement un
autre projet.

## Profil de projet

Avant une production importante, Codex constitue un profil minimal :

- identifiant et nom du projet ;
- intention et public ;
- familles de créations attendues ;
- direction artistique ou références existantes ;
- contraintes techniques ;
- cibles d’utilisation ;
- règles de validation ;
- formats de livraison.

Le profil peut rester conversationnel. Un JSON est utile lorsqu’un traitement
automatique ou une reprise ultérieure exige une structure stable, mais il n’est
pas une étape d’initialisation obligatoire.

## Artefacts génériques

MySpace reconnaît des rôles d’artefacts plutôt qu’une arborescence rigide.

### Référence

Une référence fixe une intention : planche visuelle, palette, exemple approuvé,
texte directeur, croquis, photographie ou extrait sonore.

### Source

Une source est la version de travail de qualité maximale : PNG, SVG, fichier
éditable, séquence d’images, audio ou autre format pertinent.

### Manifeste

Un manifeste décrit les relations qu’une image seule ne peut pas porter :
noms, rôles, cellules, pivots, durées, transitions, provenance et validations.

### Dérivé

Un dérivé est reproductible depuis les sources : miniature, atlas compact,
variante de résolution, format compressé ou fichier d’import.

### Export

Un export est façonné pour un consommateur précis : application Web, moteur de
jeu, impression, réseau social, documentation ou autre cible.

## Workflows composables

Un projet active seulement les workflows dont il a besoin :

- identité visuelle et familles d’assets ;
- personnages et animations ;
- interfaces et états interactifs ;
- illustrations et arrière-plans ;
- tilesets, textures et décors ;
- effets visuels ;
- traitement, détourage et normalisation ;
- packaging et exports ;
- contrôle de cohérence et validation.

L’Identity Atlas est un workflow parmi ceux-ci. Un projet éditorial ou une
application sans spritesheet peut utiliser les mêmes principes de référence,
validation et export sans créer d’atlas.

## Isolation

Les données propres à un projet doivent rester ensemble :

```text
<projet>/
├── references/
├── identity/
├── sources/
├── generated/
├── motion/
├── exports/
└── scripts/
```

Cette structure est une recommandation lisible, pas une commande `init` ni une
obligation. Un script placé dans le dossier d’un projet est considéré comme
spécifique à ce projet. Un outil réellement générique doit accepter son
contexte en entrée et ne contenir aucun nom, palette ou chemin propre à un cas.

## Passage au générique

Une solution créée pour un projet ne rejoint le socle commun que si :

1. elle répond à un besoin observé dans plusieurs projets ;
2. son comportement ne contient plus de choix artistiques locaux ;
3. ses entrées et sorties sont explicites ;
4. elle est testable sur au moins deux profils différents ;
5. sa généralisation apporte plus de valeur que de complexité.

Cette règle évite de transformer prématurément une expérimentation utile en
framework abstrait.
