# Pipeline, animations et formats standards

Le format canonique détaillé est défini dans
[`ANIMATION_CONTRACT_V1.md`](ANIMATION_CONTRACT_V1.md). Cette page conserve la
vue d’ensemble du pipeline et des formats cibles.

## Séparation des responsabilités

Le workflow manipule quatre types d’artefacts.

```text
Identity Atlas
    Référence artistique et assets statiques représentatifs
                         ↓
Motion Atlas
    Poses clés, expressions, vues, échelle et langage du mouvement
                         ↓
Sources de production
    PNG individuels et séquences d’animation sur grilles uniformes
                         ↓
Exports runtime
    Atlas compact, JSON standard et fichiers propres au moteur
```

Une même image ne doit pas porter toutes ces responsabilités. La planche
d’identité peut être directement découpable, mais elle reste une source. Les
exports runtime sont des dérivés reproductibles.

## Identity Atlas

La génération commence à partir d’un gabarit déterministe :

- nombre de lignes et de colonnes fixé ;
- cellules identiques ;
- marges internes constantes ;
- une cellule et un rôle par asset ;
- aucun texte dans les zones extractibles ;
- palette et règles artistiques verrouillées ;
- ordre des cellules décrit avant la génération.

Cette uniformité empêche le modèle de créer une jolie planche impossible à
découper. Elle ne signifie pas que l’atlas final devra conserver tout l’espace
transparent de chaque cellule.

## Motion Atlas

Le Motion Atlas est la constitution animée du projet. Pour un personnage, il
fixe au minimum :

- vue de face, trois-quarts, profil et dos lorsque le gameplay l’exige ;
- pose neutre et centre de gravité ;
- expressions principales ;
- anticipations et poses extrêmes ;
- ligne de sol ;
- pivot commun ;
- proportions et volume constants ;
- éléments secondaires susceptibles de bouger ;
- rythme général : calme, rebondi, énergique, lourd ou élastique.

Il ne remplace pas les spritesheets d’animation. Il fournit les références à
respecter lors de leur génération.

## Spritesheets d’animation

Chaque action importante possède sa propre séquence homogène :

```text
mascot_bear/
├── idle/
│   ├── 0001.png
│   ├── 0002.png
│   └── ...
├── walk/
├── celebrate/
├── react_success/
└── react_error/
```

Une séquence déclare :

- son nom stable ;
- sa vue ;
- son nombre de frames ;
- sa cadence en images par seconde ;
- son ordre de lecture ;
- son mode `once`, `loop` ou `pingpong` ;
- son pivot et sa ligne de sol ;
- ses événements éventuels : impact, son, émission ou changement d’état ;
- ses transitions autorisées.

Les frames restent sur un canevas identique avant packing. Le personnage ne
doit pas changer silencieusement de taille, de costume, de palette ou de pivot.

### Contrôles temporels

La validation d’une animation vérifie :

- conservation de l’identité entre les frames ;
- stabilité du pivot et absence de tremblement involontaire ;
- continuité des volumes et des contours ;
- lisibilité des poses clés à la taille réelle du jeu ;
- fermeture propre des boucles ;
- absence de duplication, inversion ou saut de frame ;
- trajectoire cohérente des mains, pieds, accessoires et effets ;
- cadence et durée conformes à l’intention.

Une frame peut être régénérée isolément seulement si son remplacement conserve
les poses voisines et la trajectoire globale.

## Format runtime commun

Le format d’échange privilégié est **TexturePacker JSON Hash**. Il est compris
ou facilement adapté par Phaser, PixiJS, Aseprite et de nombreux outils.

```json
{
  "frames": {
    "mascot/idle/0001.png": {
      "frame": { "x": 2, "y": 2, "w": 180, "h": 220 },
      "rotated": false,
      "trimmed": true,
      "spriteSourceSize": { "x": 102, "y": 148, "w": 180, "h": 220 },
      "sourceSize": { "w": 384, "h": 384 },
      "anchor": { "x": 0.5, "y": 1.0 },
      "duration": 125
    }
  },
  "animations": {
    "mascot_idle": [
      "mascot/idle/0001.png",
      "mascot/idle/0002.png"
    ]
  },
  "meta": {
    "image": "kidiplay-atlas.png",
    "format": "RGBA8888",
    "size": { "w": 2048, "h": 2048 },
    "scale": "1"
  }
}
```

`sourceSize` préserve le canevas avant rognage. `spriteSourceSize` replace le
rectangle rogné dans ce canevas. Ces données empêchent le personnage de bouger
quand les silhouettes des frames ont des dimensions différentes.

Le manifeste artistique reste séparé. Il peut référencer ce JSON mais ne doit
pas remplacer sa structure standard.

## Règles de texture

Les sources utilisent par défaut :

- PNG RGBA 8 bits ;
- espace colorimétrique sRGB ;
- alpha droit pour les fichiers de travail ;
- transparence réelle dans les sorties ;
- noms stables en minuscules, séparés par `/` et `-` ;
- pivots normalisés entre `0` et `1`.

Lors du packing runtime :

- ajouter du padding entre sprites ;
- extruder les pixels de bord pour éviter le bleeding au filtrage ;
- conserver les tailles sources et offsets après trimming ;
- désactiver la rotation lorsque la cible ou le type d’asset la supporte mal ;
- produire une variante de résolution avec `meta.scale` si nécessaire ;
- choisir la taille maximale et le caractère puissance-de-deux selon la cible,
  plutôt que de l’imposer aux sources artistiques.

Une texture `1536 × 1536` est acceptable comme source de travail. Un profil
mobile ou WebGL peut choisir de repacker dans une ou plusieurs textures
`1024 × 1024` ou `2048 × 2048`.

## Types spécialisés

### Boutons et panneaux

Un bouton redimensionnable doit séparer :

1. le fond extensible ;
2. le pictogramme ;
3. les états normal, survolé, pressé et désactivé.

Le fond déclare des bordures 9-slice. Un bouton illustré fusionnant fond et
pictogramme ne doit pas être étiré arbitrairement.

### Tilesets

Un tileset déclare la taille de tuile, les marges, les voisins autorisés et les
règles de raccord. La validation doit tester les répétitions horizontales,
verticales et les coins.

### Effets visuels

Les effets déclarent la cadence, le mode de mélange, le pivot, la durée et la
zone maximale. Les fumées et particules semi-transparentes demandent un contrôle
particulier de l’alpha et des franges colorées.

### Arrière-plans

Les arrière-plans ne sont pas forcés dans la grille des sprites. Ils peuvent
être décomposés en couches de parallaxe, avec dimensions, zone sûre et facteur
de défilement propres.

## Profils de sortie

### Phaser et PixiJS

- PNG d’atlas ;
- TexturePacker JSON Hash ;
- `frames`, `meta` et éventuellement `animations` ;
- `anchor` pour les pivots ;
- cache busting ou nom versionné pour le Web.

### Godot

- grille uniforme avec `hframes` et `vframes` pour les séquences simples ;
- `AtlasTexture` pour des régions nommées ;
- `SpriteFrames` pour animations, cadence et boucles ;
- ressources `.tres` générées seulement quand un projet Godot le demande.

### Unity

- PNG sources individuels ou texture découpable ;
- pivots et modes d’import explicites ;
- Sprite Atlas V2 construit par Unity pour le runtime ;
- clips d’animation et contrôleur produits seulement dans un projet Unity.

### Aseprite

- JSON Hash ou JSON Array ;
- slices pour pivots et 9-slices ;
- tags pour les groupes d’animation ;
- durées de frames conservées à l’export.

## Références de format

- [TexturePacker — documentation](https://www.codeandweb.com/texturepacker/documentation)
- [TexturePacker — exemple JSON Hash](https://www.codeandweb.com/texturepacker-online/index.html)
- [Phaser — Texture Manager](https://docs.phaser.io/api-documentation/class/textures-texturemanager)
- [PixiJS — spritesheets](https://pixijs.com/7.x/guides/components/sprite-sheets)
- [Godot — animation 2D par spritesheet](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)
- [Godot — AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html)
- [Unity — Sprite Atlas V2](https://docs.unity3d.com/2022.3/Documentation/Manual/SpriteAtlasV2.html)
- [Aseprite — export CLI](https://www.aseprite.org/docs/cli/)
- [Aseprite — slices et pivots](https://www.aseprite.org/docs/slices/)
