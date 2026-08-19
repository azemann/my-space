class_name InventoryUIConfig
extends Resource

## Centralise les réglages sûrs de l'écran d'inventaire. La racine reste
## volontairement plein écran ; seuls le panneau intérieur et son style bougent.

@export_category("Panneau")
## Texture facultative placée derrière le contenu du sac.
@export var panel_texture: Texture2D
## Teinte appliquée à la texture du panneau.
@export var panel_texture_modulate := Color.WHITE
## Marge horizontale entre le viewport et le panneau central.
@export_range(0, 200, 1, "suffix:px") var outer_margin_horizontal := 52
## Marge verticale entre le viewport et le panneau central.
@export_range(0, 120, 1, "suffix:px") var outer_margin_vertical := 30
## Marge intérieure à gauche et à droite du contenu.
@export_range(0, 64, 1, "suffix:px") var content_margin_horizontal := 36
## Marge intérieure en haut et en bas du contenu.
@export_range(0, 64, 1, "suffix:px") var content_margin_vertical := 34
## Couleur du voile placé derrière le panneau.
@export var backdrop_color := Color(0.015, 0.025, 0.022, 0.78)

@export_category("Emplacements")
## Nombre de colonnes de la grille ; les lignes supplémentaires défilent.
@export_range(1, 10, 1) var columns := 5
## Largeur souhaitée d'une case, réduite automatiquement si l'écran est trop étroit.
@export_range(40, 180, 1, "suffix:px") var slot_width := 88
## Hauteur d'une case.
@export_range(24, 96, 1, "suffix:px") var slot_height := 30
## Espacement horizontal entre les cases.
@export_range(0, 32, 1, "suffix:px") var slot_gap_horizontal := 5
## Espacement vertical entre les cases.
@export_range(0, 32, 1, "suffix:px") var slot_gap_vertical := 4

@export_category("Texte")
## Taille du titre du sac.
@export_range(10, 36, 1, "suffix:px") var title_font_size := 20
## Taille du nom de l'objet sélectionné.
@export_range(8, 28, 1, "suffix:px") var item_name_font_size := 14
## Espacement vertical entre les sections du panneau.
@export_range(0, 24, 1, "suffix:px") var section_spacing := 5
