# Sources audio LMMS

Les projets `.mmp` sont les masters éditables. Godot utilise uniquement leurs
exports dans `game/audio/sfx/psychokinesis/`.

Chaque effet est isolé afin que sa composition, son volume et son enveloppe
puissent évoluer sans modifier les autres événements du pouvoir.

## Export

```bash
flatpak run --command=lmms io.lmms.LMMS render SOURCE.mmp \
  --format wav --samplerate 48000 --interpolation sincbest \
  --oversampling 2 --output DESTINATION.wav
```

Les quatre événements initiaux sont `lift`, `hold`, `throw` et
`impact-stone`. La boucle de maintien est relancée par Godot tant que l'objet
reste suspendu.
