# Sources du joueur

```text
identity/                   référence canonique du personnage
frames/<animation>/         PNG 64×64 séparés, autorité visuelle
generation/                 prompts et reçus de provenance
player-sprite-profile.json  canvas, root, directions et timing
```

La planche runtime n'est jamais éditée ici. Elle est reconstruite dans
`game/actors/player/generated/` par `editor/sprites/build_player_sheet.py`.

