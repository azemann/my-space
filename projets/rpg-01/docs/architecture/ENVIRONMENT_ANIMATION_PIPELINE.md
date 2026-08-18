# Pipeline d'animations environnementales

Le mouvement principal d'un environnement pixel-art provient de vraies frames
déclarées dans le `TileSetAtlasSource`. Le shader de profil est une finition
facultative pour les reflets et la teinte ; il ne remplace jamais les frames.

Les familles animées déclarent dans leur catalogue : nombre de frames, durée,
mode de départ, tuiles concernées et direction logique. Le builder compose une
spritesheet à plusieurs rangées, configure l'animation Godot et exporte la même
séquence dans le TSX afin que Tiled puisse également la prévisualiser.

Sur la plage du réveil, les eaux peu profonde et profonde utilisent quatre
frames désynchronisées. Le rivage et l'écume utilisent quatre frames de ressac.
La mer étant au sud de la carte, leur direction est `(0, -1)` : du sud vers le
nord, jusqu'à la plage, puis retrait.

Les cartes ne codent jamais directement un shader de mer, de lave ou de marais.
Un calque Tiled choisit un profil générique avec la propriété :

`environment_animation_profile = water_calm`

Le convertisseur valide l'identifiant, crée un `ShaderMaterial` propre à
l'instance et l'attache au `TileMapLayer`. Le matériau est donc visible dans la
scène Godot générée et ses paramètres ne peuvent pas contaminer une autre carte.

## Profils disponibles

| Identifiant | Usage |
| --- | --- |
| `water_calm` | mer calme, lac, étang |
| `water_flow` | rivière, courant, cascade |
| `shoreline_foam` | rive, écume et ressac |
| `lava_flow` | lave et roche en fusion |
| `poison_swamp` | marais toxique, acide |
| `magic_surface` | portail, sol ou liquide magique |

Les profils sont des ressources éditables dans
`game/systems/environment_animation/profiles/`. Ils centralisent vitesse,
intensité, fréquence spatiale, cadence pixel-art, direction et teinte.

## Surcharges facultatives dans Tiled

- `environment_animation_speed_scale`
- `environment_animation_intensity_scale`
- `environment_animation_direction_x`
- `environment_animation_direction_y`
- `environment_animation_fps`
- `environment_animation_phase`

Ces valeurs ne touchent qu'au rendu. Traversabilité, dégâts, nage, hauteur et
collisions restent décrits par leurs propres calques et contrats gameplay.

Le shader complémentaire ne déplace pas les UV de l'atlas. Il anime seulement
la lumière dans l'espace du monde avec un temps quantifié, ce qui conserve les
pixels et empêche les coutures entre tuiles voisines.
