# MySpace

MySpace est un espace générique de création assistée par agents. Il accueille
des projets différents sans leur imposer un framework, un moteur, un style ou
un fournisseur de génération.

Codex orchestre directement, dans le contexte de chaque projet, les agents et
les outils nécessaires pour explorer, produire, contrôler et intégrer les
créations.

L’**Identity Atlas** est le premier workflow développé dans MySpace. Il répond
au besoin de créer des familles d’assets visuellement cohérentes et
techniquement exploitables. Il ne définit pas à lui seul la portée du dépôt.

## Portée générique

MySpace sépare toujours :

```text
Règles et méthodes génériques
              ↓
Profil propre au projet
              ↓
Productions et validations
              ↓
Exports adaptés à la cible
```

Les règles génériques décrivent notamment la cohérence visuelle, les grilles,
les animations, la validation, les formats et les transformations.

Chaque projet conserve ses propres décisions :

- identité et public ;
- direction artistique ;
- types de créations nécessaires ;
- contraintes de taille, d’animation et d’interaction ;
- plateformes ou moteurs cibles ;
- assets, prompts, références et exports.

KidiPlay est le premier cas concret. Ses mascottes, animations et choix
artistiques ne deviennent jamais des valeurs par défaut pour les autres
projets.

## Principe fondateur

Une direction artistique ne devrait pas rester une collection abstraite
d’images d’inspiration. Elle peut être incarnée dans un premier vocabulaire
visuel utilisable par le projet :

- personnages, poses, expressions et langage du mouvement ;
- objets, armes et accessoires ;
- éléments de terrain et de décor ;
- effets visuels ;
- icônes et éléments d’interface ;
- palette, formes, matières et proportions caractéristiques.

Ces éléments sont réunis dans une planche structurée appelée **Identity
Atlas**.

```text
Référence artistique canonique
            +
Premier ensemble d’assets découpables
            =
Identity Atlas
```

## Deux usages, une seule source

L’Identity Atlas sert simultanément :

1. de référence visuelle pour juger la cohérence des générations futures ;
2. de spritesheet dont les cellules peuvent être découpées, normalisées,
   nommées et importées dans le projet.

Il est complété par un **Motion Atlas** lorsque le projet contient des
personnages, créatures, interfaces ou effets animés. Le Motion Atlas verrouille
les poses clés, l’échelle, la ligne de sol, le pivot et le rythme avant de
produire les animations complètes.

La planche n’est donc ni une simple moodboard, ni une spritesheet produite sans
intention artistique. Sa composition fait partie de la conception du projet.

## Chaîne de production

```text
Description du projet et direction artistique
                      ↓
Définition du vocabulaire d’assets
                      ↓
Spécification de la grille et des cellules
                      ↓
Génération de l’Identity Atlas
                      ↓
Validation artistique et technique
                      ↓
Motion Atlas et poses clés
                      ↓
Spritesheets d’animation par action
                      ↓
Découpage des cellules
                      ↓
Nettoyage, pivots et normalisation
                      ↓
PNG sources individuels
                      ↓
Atlas runtime compact + JSON standard
                      ↓
Référence des générations suivantes
```

La grille uniforme appartient au format de travail. Elle stabilise la
génération et permet un découpage déterministe. L’atlas runtime peut ensuite
être rogné et repacké pour économiser la mémoire, à condition de conserver les
tailles sources, pivots et offsets dans ses métadonnées.

## Orchestration par agents

Codex peut composer une chaîne d’agents spécialisée pour chaque projet :

- **direction artistique** : formalise le langage visuel recherché ;
- **conception d’assets** : choisit les éléments représentatifs de l’identité ;
- **composition** : définit la grille, les cellules, les échelles et les poses ;
- **génération** : produit une ou plusieurs planches candidates ;
- **contrôle visuel** : détecte incohérences, artefacts et éléments ambigus ;
- **direction du mouvement** : définit poses clés, rythme, boucles et transitions ;
- **contrôle temporel** : vérifie stabilité, continuité et absence de tremblement ;
- **asset engineering** : découpe, recentre, redimensionne et calcule les pivots ;
- **intégration** : produit les fichiers attendus par le moteur cible.

L’utilisateur conserve les décisions importantes : choix de la direction,
validation de la planche et sélection des assets utilisables.

## Résultats attendus

Une production peut fournir, selon les besoins :

```text
assets/
├── identity/
│   ├── identity-atlas.png
│   ├── identity.json
│   └── motion-atlas.png
├── sources/
│   ├── characters/
│   ├── animations/
│   ├── props/
│   ├── terrain/
│   ├── effects/
│   └── ui/
└── exports/
    ├── atlas.png
    ├── atlas.json
    ├── godot/
    ├── unity/
    └── web/
```

Le format exact appartient au projet et à sa cible : Unity, Godot, Phaser,
PixiJS ou autre.

## Ce que ce dépôt n’impose pas

- aucun `init` ;
- aucun framework applicatif ;
- aucun service permanent ;
- aucun fournisseur unique de génération d’images ;
- aucun style ou vocabulaire artistique partagé entre les projets ;
- aucun type de création limité au jeu vidéo ;
- aucune arborescence obligatoire pour les projets utilisateurs.

Les scripts de traitement ou d’import ne sont créés que lorsqu’un projet réel
en a besoin. Ils restent locaux, inspectables et adaptés à sa chaîne de
production.

## Documentation

- [Contrat de l’Identity Atlas](docs/IDENTITY_ATLAS.md)
- [Modèle générique des projets](docs/PROJECT_MODEL.md)
- [Pipeline, animations et formats standards](docs/PIPELINE_AND_FORMATS.md)
- [Exemple de profil de projet](examples/project-profile.example.json)
- [Exemple de manifeste](examples/identity-atlas.example.json)
- [Exemple de manifeste d’animation](examples/animation-set.example.json)

## Premier cas concret : KidiPlay

La première planche KidiPlay validable utilise une grille déterministe de
`4 × 4`. Ses seize cellules de `384 × 384` sont générées dans une composition
uniforme avant tout découpage.

- [planche d’identité normalisée](assets/kidiplay/identity/kidiplay-identity-atlas-v002.png) ;
- [spritesheet transparente](assets/kidiplay/identity/kidiplay-spritesheet-v002.png) ;
- [manifeste artistique](assets/kidiplay/identity/kidiplay-identity-v002.json) ;
- [atlas JSON Hash compatible](assets/kidiplay/identity/kidiplay-spritesheet-v002.json) ;
- [prompt et répartition](assets/kidiplay/identity/kidiplay-identity-atlas-v002.prompt.md) ;
- [plan de mouvement et premières animations](assets/kidiplay/motion/README.md).

Le script propre à KidiPlay
[`assets/kidiplay/scripts/extract-identity-atlas-v002.sh`](assets/kidiplay/scripts/extract-identity-atlas-v002.sh)
reproduit le détourage, les seize PNG individuels et l’assemblage transparent.
Il n’appartient pas au socle générique.
