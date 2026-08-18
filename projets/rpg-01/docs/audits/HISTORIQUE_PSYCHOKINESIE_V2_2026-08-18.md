# Historique — reconstruction de la psychokinésie V2

Date : 18 août 2026

## Point de départ

Le premier prototype mélangeait dans un même script le survol, la physique,
la hauteur, le halo, les ombres, les sons et la persistance. La sélection
combinait successivement requêtes physiques, lecture alpha, tolérance,
hystérésis et perception des objets cachés. Les comportements différaient
également entre la pierre laboratoire et les objets issus de Tiled.

Le symptôme visible était un survol imprécis ou décalé, malgré des corrections
locales répétées.

## Décisions prises

1. Une seule scène canonique reste utilisée par tous les accessoires Tiled :
   `game/world/objects/psychokinetic_prop.tscn`.
2. Chaque objet possède une géométrie de survol indépendante de sa physique :
   `SelectionArea/HoverShape`.
3. La collision directe du corps est nommée `PhysicsFootprint` et reste à
   l'ancre au sol. Elle ne participe jamais au survol.
4. La souris est lue avec `CanvasItem.get_global_mouse_position()` puis testée
   directement contre les `HoverShape` dans le même monde 2D.
5. La perception des objets dissimulés est reportée à une mécanique future et
   séparée. Elle ne modifie plus la sélection ordinaire.
6. Les états sont contrôlés par une machine explicite : `idle`, `targeted`,
   `attracted`, `held`, `charging`, `thrown`, `landing`.

## Architecture obtenue

Le contrôleur persistant expose dans `game/core/main.tscn` :

- `TargetDetector` pour la portée et la priorité visuelle ;
- `ManipulationAnchor` pour la destination physique de l'objet tenu ;
- `AimIndicator` pour le faisceau et la direction de projection.

Chaque objet manipulable expose :

- `StateMachine` pour les transitions ;
- `SelectionArea/HoverShape` pour le survol ;
- `Presentation` pour le halo, l'élévation visuelle, l'ombre, les sons et les
  particules ;
- `PhysicsFootprint` pour les collisions au sol ;
- `Persistence` pour l'état durable.

`PsychokineticBody2D` conserve uniquement l'orchestration de la poursuite du
`RigidBody2D`, la hauteur logique, la projection et l'atterrissage.

## Défaut géométrique découvert

La pierre laboratoire affichait son visuel et sa `SelectionArea` à `y=-43`,
mais conservait `visual_focus_offset=-30`. Le premier tick la déplaçait donc de
13 pixels. `visual_focus_offset` est maintenant explicitement fixé à
`Vector2(0, -43)` dans `practice_stone.tscn`.

Les objets Tiled calculent leur centre depuis :

```text
content_offset + content_size / 2 - foot_anchor
```

Le test `editor/tests/verify_psychokinesis_alignment.gd` compare ce centre de
contenu réellement rendu avec la position globale de chaque `HoverShape`.

## Migration et validations

- toutes les cartes Tiled ont été régénérées ;
- 47 accessoires Tiled et la pierre laboratoire utilisent le contrat V2 ;
- 48 objets vérifiés avec une erreur d'alignement maximale de `0,000 px` ;
- ciblage, prise, charge, hauteur, lancer et atterrissage validés ;
- collisions de plage, pont, escaliers, falaises et eau validés ;
- persistance des 48 instances validée ;
- caméra, plein écran et viewport logique validés ;
- budget validé avec zéro cible inactive en traitement ;
- 15 tests Python du pipeline réussis.

## Règle pour la suite

Ne jamais corriger le survol par une marge ou un rayon tant que les quatre
positions suivantes n'ont pas été comparées : centre du contenu détouré,
`HoverShape`, souris globale du canvas et transformation du halo. Toute nouvelle
famille d'objets doit passer le test d'alignement avant son intégration à une
carte.
