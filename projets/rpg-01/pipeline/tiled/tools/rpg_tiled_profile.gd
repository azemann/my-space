class_name RpgTiledProfile
extends RefCounted

const ObjectScenes = preload("res://game/world/objects/world_object_scene_registry.gd")

const TILE_SIZE := Vector2i(32, 32)
const MAPS_DIRECTORY := "res://pipeline/tiled/maps/source"
const TILESET_PATH := "res://game/world/tileset/world_tileset.tres"
const GENERATED_SCENES_DIRECTORY := "res://game/world/maps/generated"

const TILE_GROUPS := {
	"Ground": "Terrain",
	"GroundVariations": "Terrain",
	"Paths": "Terrain",
	"CultivatedSoil": "Terrain",
	"StoneFloors": "Terrain",
	"WaterBase": "Water",
	"WaterBanks": "Water",
	"Waterfalls": "Water",
	"WaterEffects": "Water",
	"CliffBack": "Relief",
	"CliffFaces": "Relief",
	"CliffFront": "Relief",
	"Stairs": "Relief",
	"Floors": "Architecture",
	"Bridges": "Architecture",
	"WallsBack": "Architecture",
	"Buildings": "Architecture",
	"Fences": "Architecture",
	"WallsFront": "Architecture",
	"Shadows": "Decoration",
	"GroundDecor": "Decoration",
	"PropsBack": "Decoration",
	"Vegetation": "Decoration",
	"YSortedProps": "Decoration",
	"Canopy": "Decoration",
	"Foreground": "Decoration",
}

const OBJECT_GROUPS := {
	"ArchitectureObjects": "tile_objects",
	"BoundaryObjects": "tile_objects",
	"GroundObjects": "tile_objects",
	"YSortedObjects": "tile_objects",
	"WaterObjects": "tile_objects",
	"ForegroundObjects": "tile_objects",
	"HeightZones": "height_zone",
	"ElevationTransitions": "elevation_transition",
	"CollisionOverrides": "collision",
	"Navigation": "navigation",
	"Entrances": "entrance",
	"Exits": "exit",
	"Interactions": "interaction",
	"Entities": "entity",
	"SpawnPoints": "spawn",
	"EncounterZones": "encounter_zone",
	"CameraZones": "camera_zone",
	"AudioZones": "audio_zone",
}

const LAYER_DESCRIPTIONS := {
	"Ground": "Sol principal marchable : herbe, chemins, pierre, eau et terres cultivées.",
	"GroundVariations": "Variantes discrètes du sol sans changement de collision.",
	"Paths": "Chemins raccordables et leurs bordures.",
	"CultivatedSoil": "Terre cultivée, sillons et bordures de potager.",
	"StoneFloors": "Pavés extérieurs, cours et bordures minérales.",
	"WaterBase": "Surface d'eau principale, bloquante tant qu'aucun mode de traversée ne l'autorise.",
	"WaterBanks": "Berges qui séparent explicitement terre et eau.",
	"Waterfalls": "Départs, chutes et impacts des cascades.",
	"WaterEffects": "Écume, courant, cascades et animations superposées à l'eau.",
	"CliffBack": "Rebords hauts situés derrière les acteurs.",
	"CliffFaces": "Faces verticales bloquantes des falaises.",
	"CliffFront": "Rebords de premier plan pouvant masquer les pieds d'un acteur.",
	"Stairs": "Représentation visuelle des transitions explicites entre niveaux.",
	"Floors": "Sols construits : intérieurs, cours, dalles et planchers.",
	"Bridges": "Ponts, passerelles et appuis traversant un obstacle.",
	"WallsBack": "Murs situés derrière les acteurs.",
	"Buildings": "Bâtiments et grands assemblages architecturaux.",
	"Fences": "Clôtures, portails et poteaux.",
	"WallsFront": "Façades et parties hautes pouvant passer devant le joueur.",
	"Shadows": "Ombres portées indépendantes des sprites qui les produisent.",
	"GroundDecor": "Décor posé au sol sans fonction gameplay.",
	"PropsBack": "Accessoires toujours dessinés derrière les acteurs.",
	"Vegetation": "Végétation basse et moyenne triée autour des personnages.",
	"YSortedProps": "Objets ancrés au sol et triés par leur origine verticale.",
	"Canopy": "Cimes et feuillages de premier plan passant devant le joueur.",
	"Foreground": "Décor placé volontairement devant l'action.",
	"ArchitectureObjects": "Maisons, ponts et grands assemblages posés depuis la bibliothèque Tiled.",
	"BoundaryObjects": "Clôtures, portails et murs posés comme objets visuels.",
	"GroundObjects": "Petits éléments plaqués au sol sans tri vertical.",
	"YSortedObjects": "Arbres, rochers et accessoires triés selon leur point de pied.",
	"WaterObjects": "Plantes et accessoires placés sur les surfaces d'eau.",
	"ForegroundObjects": "Objets destinés à masquer volontairement les acteurs.",
	"HeightZones": "Zones portant un niveau de hauteur entier.",
	"ElevationTransitions": "Escaliers et autres passages reliant explicitement deux hauteurs.",
	"CollisionOverrides": "Volumes physiques autoritaires indépendants des pixels du décor.",
	"Navigation": "Surfaces marchables et exclusions utilisées pour la navigation.",
	"Entrances": "Portes et accès vers une autre scène.",
	"Exits": "Sorties et destinations de retour.",
	"Interactions": "Déclencheurs, portes, eau, récoltes et changements de zone.",
	"Entities": "Positions et paramètres d'instances des PNJ, ennemis et objets persistants.",
	"SpawnPoints": "Points nommés d'apparition du joueur et des autres acteurs.",
	"EncounterZones": "Zones où des rencontres ou événements peuvent être déclenchés.",
	"CameraZones": "Limites, cadrages et comportements locaux de caméra.",
	"AudioZones": "Ambiances et transitions sonores spatiales.",
	"solid": "Obstacle physique importé depuis un volume Tiled.",
	"walkable": "Surface autorisée pour la navigation des acteurs.",
	"water": "Zone d'eau portant ses paramètres de traversée et d'interaction.",
	"player_spawn": "Position initiale du joueur définie dans Tiled.",
}

const GROUP_DESCRIPTIONS := {
	"Terrain": "Fond naturel et relief du monde.",
	"Architecture": "Structures construites et éléments de franchissement.",
	"Decoration": "Profondeur visuelle sans autorité gameplay implicite.",
	"PlacedObjects": "Objets nommés posés par leur point de pied depuis la bibliothèque du monde.",
	"Gameplay": "Données invisibles et typées qui pilotent le jeu.",
}


static func tile_group(layer_name: String) -> String:
	return str(TILE_GROUPS.get(layer_name, "Ungrouped"))


static func object_role(layer_name: String) -> String:
	return str(OBJECT_GROUPS.get(layer_name, "object"))


static func description(item_name: String) -> String:
	return str(LAYER_DESCRIPTIONS.get(item_name, GROUP_DESCRIPTIONS.get(item_name, "Élément importé depuis Tiled.")))


static func level_scene_path(level_id: String) -> String:
	return GENERATED_SCENES_DIRECTORY.path_join("%s.tscn" % level_id)


static func has_object_scene(kind: StringName) -> bool:
	return ObjectScenes.has_scene(kind)


static func instantiate_object(kind: StringName) -> Node2D:
	return ObjectScenes.instantiate(kind)


static func object_scene_path(kind: StringName) -> String:
	return ObjectScenes.scene_path(kind)
