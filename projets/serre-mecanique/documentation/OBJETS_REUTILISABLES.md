# Objets réutilisables

## Principe

Les tuiles construisent le décor répétitif. Les objets avec un comportement sont
des scènes Godot instanciées par le convertisseur à partir de leur type Tiled.

```text
objet Tiled type="checkpoint"
              ↓
TiledObjectSceneRegistry
              ↓
scenes/objects/interactions/checkpoint_area.tscn
              ↓
position, collision et propriétés provenant du TMX
```

La scène fournit le comportement et les enfants permanents. Le TMX fournit la
position, la taille de collision et les propriétés propres à cette occurrence.

## Registre actuel

| Type Tiled | Scène Godot |
|---|---|
| `climbable` | `objects/movement/climbable_area.tscn` |
| `bounce` | `objects/movement/bounce_pad.tscn` |
| `hazard` | `objects/hazards/hazard_area.tscn` |
| `checkpoint` | `objects/interactions/checkpoint_area.tscn` |
| `collectible` | `objects/interactions/collectible_area.tscn` |
| `exit` | `objects/interactions/exit_door.tscn` |
| `interactable` | `objects/interactions/switch_area.tscn` |
| zones simples | `objects/zones/gameplay_zone.tscn` |

Les zones simples comprennent `trigger`, `death_zone`, `transition`, `water`,
`wind`, `slow_zone` et `conveyor`.

## Ce qui reste généré

Les types `solid`, `one_way`, `wall`, `slope` et `grapple_surface` restent des
corps physiques générés. Ils décrivent de la géométrie, pas des objets autonomes.

## Ajouter un nouvel objet

1. Créer sa scène dans une famille de `scenes/objects/`.
2. Placer son script, ses animations et ses ressources par défaut dans la scène.
3. Ajouter le type et le `PackedScene` dans
   `game/serre/tiled/tiled_object_scene_registry.gd`.
4. Employer exactement ce type sur l'objet Tiled.
5. Régénérer et vérifier que la scène produite contient une instance, pas une
   copie aplatie.

Les propriétés Tiled sont conservées comme métadonnées. Une propriété ajoutée au
TMX peut donc personnaliser une instance sans dupliquer sa scène source.

## Niveau 1 figé

Le niveau 1 utilise lui aussi ces scènes, mais sa géométrie reste éditée dans
Godot : il n'est jamais reconstruit depuis son ancien TMX. Il contient actuellement
15 instances réutilisables :

| Famille | Objets du niveau 1 |
|---|---|
| Mouvement | `Echelle`, `Chaine`, `Ressort` |
| Dangers | `FosseToxique`, `Pics` |
| Progression | `Checkpoint01`, `LevierIrrigation`, `SortieSerre` |
| Collecte | `Graine01` à `Graine05` |
| Zones | `ZoneMort`, `DeclencheurSortie` |

Les formes de collision restent propres à chaque occurrence. Modifier la scène
réutilisable change le comportement commun ; redimensionner une collision dans
`niveau-01-serre.tscn` ne modifie que cet objet.

`LimitesCamera` et `ZoneAmbianceVerriere` restent des zones techniques locales au
niveau. Les huit corps statiques restent de la géométrie locale ; six sont typés
`one_way` et tous sont explicitement autorisés pour le grappin.
