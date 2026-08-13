class_name WeaponDefinition
extends Resource

enum Category {
	WEAPON,
	TOOL,
	MOBILITY,
}

@export_group("Identité")
## Identifiant technique stable utilisé par les scripts et les sauvegardes. Ne pas le traduire ni le modifier après publication.
@export var weapon_id: StringName
## Nom présenté au joueur dans la roue des armes.
@export var display_name := "Équipement"
## Famille affichée et utilisée pour organiser l'arsenal : arme, outil ou mobilité.
@export var category := Category.WEAPON
## Résumé du fonctionnement et du rôle tactique de l'équipement.
@export_multiline var gameplay_description := ""
## Mots-clés décrivant les aptitudes principales. Ils pourront servir aux filtres et aux aides de l'interface.
@export var abilities: PackedStringArray = []

@export_group("Visuel")
## Image affichée dans les mains du personnage. Elle tourne avec la direction de visée.
@export var texture: Texture2D
## Décalage en pixels du sprite par rapport au nœud Equipment. X déplace le long de l'arme, Y perpendiculairement.
@export var visual_offset := Vector2(12, 0)
## Échelle visuelle de l'arme uniquement. Elle ne modifie ni le projectile ni les collisions.
@export var visual_scale := Vector2.ONE
## Position locale de sortie du projectile ou de la corde. Elle doit correspondre visuellement à la bouche de l'arme.
@export var muzzle_offset := Vector2(30, 0)

@export_group("Sélecteur")
## Icône utilisée dans la roue. Si elle est vide, la texture principale de l'arme est utilisée.
@export var selection_icon: Texture2D
## Quantité affichée dans la roue. La valeur -1 signifie munitions illimitées.
@export var ammo_count := -1
## Priorité prévue pour trier les armes dans l'arsenal. Une valeur faible apparaît avant une valeur élevée.
@export var selector_order := 0

@export_group("Utilisation")
## Temps minimal en secondes entre deux utilisations. Augmenter ralentit la cadence de tir.
@export var cooldown := 0.0
## Scène créée à la bouche lors du tir. Laisser vide pour un équipement sans projectile, comme le grappin.
@export var projectile_scene: PackedScene
## Vitesse en pixels/seconde retranchée au joueur dans la direction opposée au tir. Zéro désactive le recul.
@export var recoil_impulse := 0.0

@export_group("Charge de puissance")
## Active le cycle maintenir pour charger, relâcher pour utiliser. Désactivé, l'équipement agit immédiatement à l'appui.
@export var charge_enabled := false
## Temps en secondes nécessaire pour atteindre la puissance maximale. Une durée courte rend l'arme nerveuse ; une durée longue rend le choix de puissance plus précis.
@export_range(0.1, 5.0, 0.05, "or_greater") var charge_duration := 1.25
## Part de la vitesse maximale conservée lors d'un relâchement immédiat. 0.25 signifie qu'un tir très bref part à 25 % de sa vitesse maximale.
@export_range(0.0, 1.0, 0.01) var minimum_power := 0.25
## Matériau visuel optionnel recevant le paramètre shader `charge_ratio`. Chaque jeu peut ainsi dessiner sa charge sans dépendance dans le contrôleur générique.
@export var charge_material: Material

@export_group("Audio")
## Son ponctuel joué à chaque utilisation réussie. Pour le bazooka : départ du tir et souffle arrière exportés depuis LMMS.
@export var fire_audio: AudioStream
## Volume du son de tir en décibels. 0 dB conserve le niveau original ; une valeur négative atténue le son.
@export_range(-60.0, 12.0, 0.1) var fire_volume_db := 0.0
## Hauteur et vitesse du son de tir. 1.0 est normal ; une valeur légèrement variable évite une répétition trop mécanique.
@export_range(0.25, 4.0, 0.01) var fire_pitch_scale := 1.0
