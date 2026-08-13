# Sources audio LMMS

Ce dossier conserve les projets de fabrication sonore `.mmp` ou `.mmpz`. Godot
ne lit pas directement ces fichiers : ils restent les sources modifiables, comme
les fichiers ImageGen avant leur transformation en assets runtime.

## Organisation

```text
sources/lmms/
├── weapons/
│   └── bazooka/
│       └── bazooka-fire.mmp
└── music/
```

LMMS est installé sur cette machine avec Flatpak :

- application : `io.lmms.LMMS` ;
- version vérifiée : 1.2.2 ;
- lanceur graphique :
  `/home/evan/.local/share/flatpak/exports/share/applications/io.lmms.LMMS.desktop`.

Le terminal ne trouve pas une commande `lmms` classique, car l'exécutable se
trouve dans le conteneur Flatpak. Pour ouvrir LMMS :

```bash
flatpak run io.lmms.LMMS
```

## Export vers Godot

Pour un effet sonore ponctuel :

- exporter en WAV 48 kHz, 16 ou 24 bits ;
- conserver un peu d'espace avant la saturation, idéalement un pic sous -1 dB ;
- retirer le silence inutile au début ;
- placer l'export dans `assets/audio/sfx/weapons/bazooka/`.

Pour une boucle longue ou une musique, préférer OGG afin de réduire la taille.
Le projet LMMS reste la source de vérité ; le WAV ou l'OGG est seulement l'asset
runtime réexportable.

### Export reproductible en ligne de commande

LMMS peut rendre directement un projet sans ouvrir son interface :

```bash
flatpak run --command=lmms io.lmms.LMMS render \
  sources/lmms/weapons/bazooka/bazooka-fire.mmp \
  --format wav \
  --samplerate 48000 \
  --interpolation sincbest \
  --oversampling 2 \
  --output assets/audio/sfx/weapons/bazooka/bazooka-fire.wav
```

Le fichier rendu par LMMS contient une courte queue silencieuse. Godot peut la
lire sans effet audible ; le prochain tir interrompt simplement cette queue.

## Correspondances du bazooka

| Événement | Export Godot | Affectation dans l'inspecteur |
|---|---|---|
| départ du tir et souffle arrière | `bazooka-fire.wav` | `bazooka.tres > Audio > Fire Audio` |
| vol continu de la roquette | à concevoir | `bazooka_rocket.tscn > FlightAudio > Stream` |
| impact et explosion | **réservé à une directive future** | `bazooka_explosion.tscn > ExplosionAudio > Stream` |

Le vol devra être une boucle propre. Dans Godot, il faudra activer la boucle sur
la ressource WAV importée si LMMS exporte seulement un cycle. Aucun son
d'explosion n'est actuellement créé ni affecté.

## Mixage Godot

Les armes utilisent le bus `Weapons`, envoyé dans `SFX`, lui-même envoyé dans
`Master`. On peut ainsi baisser toutes les armes, tous les bruitages ou le jeu
entier sans modifier les fichiers audio.
