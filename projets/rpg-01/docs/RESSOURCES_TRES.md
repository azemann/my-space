# Guide des ressources `.tres`

Dans Godot, sélectionnez une ressource dans le panneau **Système de fichiers**, puis laissez la souris sur une propriété de l'Inspecteur pour afficher son infobulle. Les noms ci-dessous apparaissent également dans l'Inspecteur et dans les sélecteurs de ressources.

## Ressources à modifier dans l'éditeur

| Fichier | Rôle | Ce que l'on y règle |
|---|---|---|
| `game/actors/player/player_config.tres` | Déplacement et interactions du joueur | Vitesse, course, accélération, freinage, actions clavier/manette, noms d'animations et distance d'interaction. |
| `game/content/items/catalog.tres` | Catalogue principal des objets | Sortie générée donnant au runtime toutes les définitions et résolvant les identifiants de sauvegarde. |
| `game/content/items/definitions/**/*.tres` | Types d'objets | Nom, description, catégorie, limite de pile, tags, icône et autorisation de jeter. Jamais de quantité runtime. |
| `game/ui/inventory/inventory_ui_config.tres` | Présentation du sac | Texture de panneau, teinte, marges sûres, colonnes, taille des cases, espacements, voile et tailles de texte. La grille défile si elle grandit. |
| `game/config/runtime_budget.tres` | Garde-fous de performance | FPS visés, temps maximal d'une image, quantité conseillée de nœuds, de cibles psychokinétiques et d'empreintes. |
| `game/systems/camera/camera_config.tres` | Caméra principale | Zoom, décalage, lissage, anticipation du mouvement et contraintes pixel-perfect. |
| `game/systems/footprints/beach_wet_sand_footprints.tres` | Empreintes sur le sable humide | Scène visuelle d'une empreinte, terrain requis, espacement des pas, vitesse minimale et quantité affichée. |
| `game/systems/environment_animation/profiles/water_calm.tres` | Eau calme | Pulsation lente et reflets discrets pour les zones abritées. |
| `game/systems/environment_animation/profiles/water_flow.tres` | Eau courante | Courant directionnel plus rapide pour les rivières et cascades. |
| `game/systems/environment_animation/profiles/shoreline_foam.tres` | Écume du rivage | Ressac clair et marqué au contact de la plage. |
| `game/systems/environment_animation/profiles/lava_flow.tres` | Lave | Pulsation chaude, lente et contrastée. |
| `game/systems/environment_animation/profiles/poison_swamp.tres` | Marais empoisonné | Bouillonnement verdâtre irrégulier. |
| `game/systems/environment_animation/profiles/magic_surface.tres` | Surface magique | Ondulation violette rapide et lumineuse. |
| `default_bus_layout.tres` | Mixage audio global | Volume et routage des bus `Master`, `SFX`, `Psychokinesis` et `Ambience`. Cette ressource se règle surtout dans le panneau **Audio** de Godot. |

Tous les profils de surface utilisent le même shader. `speed` règle sa vitesse, `intensity` la force de l'effet, `spatial_frequency` la densité du motif, `animation_fps` sa cadence pixel-art, `flow_direction` son sens, `tint_color` sa couleur et `highlight_threshold` la quantité de reflets clairs.

## Ressources générées ou conservées en archive

| Fichier | Rôle | Modification recommandée |
|---|---|---|
| `game/actors/player/generated/player_frames.tres` | Bibliothèque des animations `idle` et `walk` du joueur dans quatre directions. | Ne pas modifier directement : `pipeline/assets/player/build_player_resources.gd` la reconstruit depuis les sprites sources. |
| `game/world/tileset/world_tileset.tres` | TileSet principal : atlas, terrains, collisions, données de gameplay et objets du monde. | Modifier les sources et `pipeline/assets/builders/build_tileset.gd`, puis reconstruire le TileSet afin de conserver les changements. Les atlas internes portent chacun un nom expliquant leur famille. |
| `archive/foundation/world-foundation-v001.tres` | Ancienne fondation du TileSet, gardée comme référence historique. | Ne pas utiliser pour les nouvelles cartes et ne pas modifier sauf travail d'archivage explicite. |

## À retenir

- Une infobulle décrit l'effet concret de chaque propriété personnalisée.
- `resource_name` donne un nom humain à la ressource sans changer son chemin ni son fonctionnement.
- Les champs natifs complexes du `TileSet`, des `SpriteFrames` et du mixage audio restent documentés par Godot lui-même.
- Pour savoir si une valeur est propre à une scène ou partagée partout, vérifiez le chemin de la ressource affiché en haut de l'Inspecteur.
