# Contrat d’animation v1

## Statut

Le contrat `myspace-animation-v1` est la représentation canonique d’une
animation 2D dans MySpace. Il ne dépend ni d’un moteur, ni d’un outil de
packing, ni d’un fournisseur de génération.

La révision courante du contrat est `1.1.0`. Elle reste dans la famille v1 et
ajoute des sorties de frames, des profils de résolution et des statuts
multidimensionnels sans modifier l’espace de coordonnées canonique.

Une production sépare quatre responsabilités :

```text
planches sources uniformes
            ↓
frames individuelles sur canevas stable
            ↓
atlas graphique compact + JSON Hash
            +
manifeste d’animation et de gameplay
            ↓
adaptateur du moteur choisi
```

Le JSON Hash décrit où dessiner les pixels. Le manifeste d’animation décrit
quand les afficher et comment le gameplay interagit avec eux.

## Décisions verrouillées

### Indexation et temps

- les indices de frame commencent à `0` ;
- l’ordre d’une séquence est explicite, jamais déduit du placement dans
  l’atlas ;
- chaque frame possède une durée en millisecondes ;
- `fps` reste une cadence d’édition et une valeur par défaut ;
- les durées individuelles permettent les poses tenues et les timings
  irréguliers sans dupliquer des images.

Cette représentation correspond aux durées par frame d’Aseprite, de Phaser et
de `SpriteFrames` dans Godot. Un adaptateur Unity les convertira en keyframes
et en fréquence d’échantillonnage.

### Espace de coordonnées

Les collisions ne sont jamais exprimées dans les coordonnées de l’atlas
compact. Elles utilisent un espace stable attaché à l’acteur :

- origine : pivot entre les pieds ;
- axe `x` positif : direction regardée ;
- axe `y` positif : vers le haut ;
- unité : pixel du canevas source ;
- rectangles : `min: [x, y]`, `max: [x, y]`.

Le trimming, le packing et un changement de taille de l’atlas ne modifient donc
pas les données de combat.

### Directions

Une direction est soit `authored`, donc dessinée explicitement, soit
`mirrorOf`, donc dérivée d’une direction existante.

Pour un profil de beat’em all, `right` est la direction canonique et `left`
peut être obtenue par miroir autour de l’axe du pivot. Les hitboxes, hurtboxes,
déplacements racine et points d’attache sont réfléchis avec l’image.

Une direction n’est pas inventée si le gameplay demande un véritable dessin
différent, notamment pour la profondeur, une arme asymétrique ou un texte.

### Collisions

Le contrat distingue :

- `pushbox` : volume physique qui empêche les combattants de se superposer ;
- `hurtboxes` : zones pouvant recevoir un coup ;
- `hitboxes` : zones offensives actives ;
- `sockets` : points d’attache pour effets, sons positionnels ou objets.

La v1 utilise volontairement des rectangles simples. Ils sont déterministes,
faciles à visualiser et directement convertibles vers Godot, Unity, Phaser ou
un runtime PixiJS. Les contours automatiques de sprite restent utiles pour le
décor, mais ne remplacent pas les volumes de combat conçus à la main.

Les collisions réutilisables vivent dans `collisionSets`. Une frame référence
un ensemble et peut ajouter ses hitboxes offensives. Les frames d’une attaque
sans hitbox sont, par définition, inactives.

### Phases et événements

Une attaque déclare des plages inclusives `startup`, `active` et `recovery`.
Les événements sont portés par la frame exacte : ouverture et fermeture de
l’attaque, impact, son, effet ou autre événement propre au jeu.

Les adaptateurs les traduiront en pistes de méthode Godot, Animation Events
Unity, événements Phaser ou callbacks du runtime web.

## Atlas graphique

Le premier export standard est `texturepacker-json-hash` :

- `frames` est un objet indexé par nom stable ;
- `frame` décrit le rectangle compact ;
- `spriteSourceSize` conserve l’offset dans le canevas uniforme ;
- `sourceSize` conserve les dimensions avant trimming ;
- `pivot` conserve l’origine de rendu ;
- `duration` conserve la durée de la frame ;
- `animations` donne les listes ordonnées de frames.

Le packing ne tourne pas les sprites, rogne les zones transparentes, conserve
un padding, extrude un pixel de bord et garde des noms indépendants de la
position dans la texture.

Le JSON Hash peut être chargé directement par Phaser. PixiJS charge également
les spritesheets JSON par son système d’assets. Godot et Unity recevront un
adaptateur qui reconstruit leurs ressources natives lorsque le moteur sera
choisi.

## Frames individuelles et profils de résolution

Les frames individuelles sont une sortie officielle, pas un remplacement de
l’atlas :

- elles gardent un canevas, une origine et une ligne de sol identiques ;
- elles sont faciles à inspecter, comparer, versionner et charger pendant le
  développement ;
- elles évitent qu’un projet consommateur redécoupe lui-même les planches ;
- l’atlas rogné et extrudé reste préférable pour le déploiement.

Chaque entrée de `frameProfiles` déclare un `pathTemplate`, une taille de
canevas, une origine, une échelle par rapport au canevas canonique et ses
usages. Le builder produit ensuite un manifeste `myspace-animation-frames`
contenant l’ordre exact des fichiers par animation.

Neon Courier fournit actuellement :

- `canonical-512` : 512 × 512, pivot `[256, 456]`, travail, contrôle et source
  de packing ;
- `phaser-256` : 256 × 256, pivot `[128, 228]`, intégration légère et debug.

Les collisions restent exprimées en pixels `canonical-512`. Un consommateur du
profil `phaser-256` leur applique donc l’échelle `0.5`.

## Mapping gameplay optionnel

Le contrat d’animation ne décide pas comment un jeu nomme ses états ni quelle
attaque réutilise une séquence. Le contrat optionnel
`myspace-animation-integration` relie les deux mondes :

- état ou action gameplay → identifiant d’animation ;
- profil de frames attendu ;
- autorité temporelle : animation, gameplay ou double source validée ;
- variante de vitesse ou durée cible ;
- politique des phases : les retimer avec le clip, les remplacer ou les
  comparer.

Cette séparation permet à une même `chain-strike` de servir à des variantes
light, heavy et special sans prétendre qu’elles possèdent automatiquement les
mêmes fenêtres de combat.

## Provenance d’import

Un projet consommateur peut écrire un reçu
`myspace-asset-import-receipt` après chaque import. Il enregistre :

- le workspace, l’asset, le manifeste, sa version et éventuellement le commit
  et le SHA-256 importés ;
- le projet, le moteur et la destination ;
- le profil de résolution et la liste des sorties réellement créées ;
- la date et l’outil d’import ;
- les statuts observés au moment de l’import.

Le reçu appartient au projet consommateur. Il permet de savoir si les fichiers
présents proviennent encore de la révision courante de MySpace.

## États de production multidimensionnels

Le champ historique `status` reste un résumé lisible. `statuses` évite qu’une
seule valeur mélange des validations différentes :

- `visual` : cohérence graphique et identité ;
- `temporal` : mouvement, rythme et boucles ;
- `technical` : formats, transparence, pivots, packing et métadonnées ;
- `gameplay` : mapping, intégration et validation dans le jeu.

Par exemple, Neon Courier peut être techniquement `production-ready` tout en
restant visuellement et temporellement `candidate`, et `unmapped` tant
qu’aucun jeu n’a adopté son contrat d’intégration.

### Valeur de synthèse

- `exploration` : rythme ou identité non verrouillés ;
- `candidate` : inspection humaine encore nécessaire ;
- `production-ready` : animation et métadonnées approuvées ;
- `deprecated` : conservée pour l’historique, mais non exportée.

Un atlas techniquement valide ne transforme pas automatiquement une animation
candidate en animation approuvée.

## Contrats associés

- [`animation-v1.schema.json`](../contracts/animation-v1.schema.json) :
  production canonique, frames et atlas ;
- [`animation-frames-v1.schema.json`](../contracts/animation-frames-v1.schema.json) :
  manifeste généré des PNG individuels ;
- [`animation-integration-v1.schema.json`](../contracts/animation-integration-v1.schema.json) :
  mapping facultatif vers le gameplay ;
- [`asset-import-receipt-v1.schema.json`](../contracts/asset-import-receipt-v1.schema.json) :
  provenance constatée par le consommateur.

## Sources de référence

Consultées le 29 juillet 2026 :

- [Aseprite CLI — JSON Hash, tags, padding, trimming et extrusion](https://www.aseprite.org/docs/cli/)
- [Aseprite — slices, pivots et métadonnées](https://www.aseprite.org/docs/slices/)
- [Phaser — chargement des atlas JSON Hash et JSON Array](https://docs.phaser.io/api-documentation/3.88.2/class/textures-texturemanager)
- [Phaser — animations et durées par frame](https://docs.phaser.io/phaser/concepts/animations)
- [PixiJS 8 — chargement des spritesheets JSON](https://pixijs.com/8.x/guides/components/assets)
- [Godot — SpriteFrames, cadence, boucles et durée relative](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html)
- [Godot — pistes d’appel de méthode](https://docs.godotengine.org/en/stable/tutorials/animation/animation_track_types.html)
- [Unity 6 — Sprite Atlas](https://docs.unity3d.com/6000.0/Manual/sprite/atlas/atlas-landing.html)
- [Unity 6 — Animation Events](https://docs.unity3d.com/6000.0/Manual/script-AnimationWindowEvent.html)
- [Unity 6 — formes physiques personnalisées](https://docs.unity3d.com/6000.0/Manual/sprite/sprite-editor/custom-physics-shape/custom-physics-shape-landing.html)
