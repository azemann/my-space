# Contrat psychokinétique

Tout asset spatial possède une réponse psychokinétique explicite. Cela ne rend
pas tous les éléments physiques ou déplaçables : le profil décrit seulement ce
que le monde doit répondre lorsque le pouvoir le sonde.

## Scène canonique d'un petit objet manipulable

Tout accessoire Tiled déclaré `movable` doit rester une instance de
`res://game/world/objects/psychokinetic_prop.tscn` après conversion. Il expose
les enfants `Persistence`, `StateMachine`, `Presentation`, `Visual`,
`SelectionGhost`, `SelectionArea/HoverShape`, `PhysicsFootprint` et `Shadow`.

Les autorités ne se chevauchent pas :

- `PsychokineticBody2D` applique uniquement poursuite, impulsion, collision et
  hauteur logique ;
- `PsychokinesisStateMachine` valide les transitions de gameplay ;
- `PsychokinesisInteractionArea2D` porte le picking natif ;
- `PsychokinesisPresentation2D` porte halo, élévation visuelle, ombre, sons et
  particules ;
- `PersistentWorldInstance` conserve uniquement l'état durable.

La séquence canonique est `idle → targeted → held → charging → thrown →
landing → idle`. `attracted` est réservé à la future phase où un objet rejoint
Azeman avant d'être stabilisé. Une transition non prévue est refusée et
signalée, plutôt que de produire plusieurs booléens contradictoires.

Le test de carte refuse un objet aplati ou détaché de cette scène Godot, un
identifiant persistant vide ou dupliqué, une collision de TileSet réactivée ou
l'absence du profil, de l'empreinte ou de l'ombre.

## Perception des objets masqués — différée

Le socle ne possède plus de cercle de perception, d'anneau automatique ou de
seconde méthode de ciblage. Les placements `psychic_concealed=true` restent des
intentions auteur utilisables plus tard, mais ne modifient pas le survol. La
découverte d'un objet sous l'eau, le sable ou les feuillages devra devenir une
mécanique séparée avec ses propres retours et tests, sans contaminer la
sélection ordinaire.

Un accessoire au repos est figé. Sa physique est réveillée à la prise, au dépôt
ou à la projection. Une limite de terrain ne peut donc plus expulser un objet
volontairement placé sous l'eau avant que le joueur ne le découvre.

## Réactivité et manipulation directe

Le survol est évalué à chaque image rendue. Le contrôleur lit
`CanvasItem.get_global_mouse_position()`, déjà exprimé dans le monde de la
caméra, puis interroge directement les formes de la `SelectionArea`. Il
n'emploie ni événement de picking implicite, ni cache physique, ni tolérance,
ni hystérésis.

À la prise, le contrôleur mémorise le décalage entre la souris et l'ancre
physique. Il conserve ensuite le pixel réellement saisi sous le pointeur, y
compris lorsque la hauteur change. Le corps ne doit jamais être recentré sous
la souris au moment du clic.

## Zone de survol Godot

Chaque objet manipulable expose une `SelectionArea` distincte de sa collision
physique. Sa forme `HoverShape` est l'unique géométrie du survol en jeu ; la
position globale de la souris et les transformations de caméra sont fournies
par le même canvas Godot. La pierre test et les objets issus de Tiled passent
par le même chemin. Pour un asset d'atlas, le convertisseur centre une
`RectangleShape2D` sur `visual_focus_offset` et la dimensionne avec
`content_width/content_height`. La cellule transparente complète de l'atlas et
la petite empreinte des pieds ne participent jamais au survol.

## Données obligatoires

| Champ | Valeurs |
| --- | --- |
| `psychokinesis_response` | `anchored`, `reactive`, `movable` |
| `psychokinesis_mass` | `light`, `medium`, `heavy`, `immense` |
| `psychokinesis_material` | matériau produisant sons et réactions |
| `psychokinesis_breakable` | destruction autorisée ou non |
| `psychokinesis_required_power` | puissance minimale entière |

`anchored` signifie que l'objet appartient au terrain ou à une structure.
`reactive` autorise une vibration, une flexion ou un effet de résistance sans
déplacement. `movable` autorise une future instance physique lorsque le niveau
du pouvoir est suffisant.

## Autorités

- les catalogues d'assets portent les profils de base ;
- le TileSet Godot expose les cinq champs comme données personnalisées ;
- les collections TSX les transmettent aux objets placés dans Tiled ;
- `PsychokinesisProfile` représente le même contrat pour les scènes dynamiques ;
- les composants V2 portent états, interaction et présentation sans dépendre
  de Tiled.

Le convertisseur Tiled transforme automatiquement chaque objet de TileSet marqué
`movable` en `PsychokineticBody2D`. Son `TileMapLayer` devient seulement son
enfant visuel ; la masse, l'empreinte, l'ombre et les collisions appartiennent à
l'entité physique générée. Les terrains peints, volumes gameplay, bâtiments et
autres structures restent hors de cette conversion.

Sur la plage du réveil, les 30 assets de props sont `movable` au niveau de
pouvoir 0 et leurs 47 instances Tiled sont donc manipulables. Avec la pierre
d'apprentissage, le runtime contient 48 cibles. La masse continue
de distinguer petits débris, objets moyens et éléments lourds sans les rendre
arbitrairement impossibles à saisir.

## Ressenti runtime minimal

Une cible mobile expose visuellement sa sélection, frémit lors de l'arrachement,
conserve une ombre au sol, accepte une hauteur virtuelle et retombe après une
projection en arc. La charge fait varier l'impulsion sans changer le profil
matériel de l'objet.

Les trois états visuels ne doivent jamais être confondus :

- **détecté** : un halo cyan de deux pixels et un léger remplissage lumineux
  épousent exactement la silhouette réelle, sans translation ni oscillation ;
- **maintenu** : le fantôme tend vers le violet et un anneau confirme la prise ;
- **chargé** : la couleur et l'anneau gagnent en intensité jusqu'au lancer.

Le fantôme est un retour visuel, pas la géométrie de sélection. Le curseur
interroge la `SelectionArea`, dimensionnée sur le
contenu détouré plutôt que sur la cellule d'atlas complète. En cas
de chevauchement, le `z_index`, puis la position Y et enfin la distance au
curseur déterminent l'objet visuellement prioritaire. Le clic lit l'état de
survol courant au moment de la prise.
Lors d'un changement de cible, l'ancien halo disparaît immédiatement : deux
silhouettes de survol ne doivent jamais rester visibles en même temps.

Pour un objet Tiled, le centre du contenu opaque est calculé depuis
`content_offset`, `content_size` et `foot_anchor`. Ce centre commun positionne le
point de prise, l'anneau et l'arrivée du faisceau. Il est interdit de le déduire
de la taille de la cellule d'atlas ou d'un rayon générique.

À la manette, l'alignement avec la direction visée prime sur la distance brute :
un objet légèrement plus loin mais placé devant le stick doit gagner sur un
objet proche situé hors axe. La vérification future de ligne de vue empêchera la
prise au travers d'un obstacle opaque.

Pour la première version du pouvoir, la détection couvre `208 px` autour
d'Azeman et la manipulation reste bornée à `224 px`. Ces valeurs couvrent le
voisinage utile dans le cadrage 640 × 360 sans transformer toute la carte en
zone cliquable.

La manipulation horizontale est une poursuite physique : elle conserve inertie,
masse et collisions avec le monde. Le curseur fournit une cible bornée par le
rayon du pouvoir, jamais une téléportation directe de frame en frame. Pendant la
charge, le point de maintien est verrouillé et le pointeur devient une visée.

Les petits objets manipulables vivent sur la couche physique `Interactions` et
masquent le `Monde solide`. Ils heurtent donc le terrain sans entrer dans le
masque de locomotion du joueur : une pierre tenue ou projetée ne doit jamais le
pousser ni le bloquer. Les futurs dégâts passent par une zone d'impact dédiée,
indépendante de la collision de déplacement.

Les sons `lift`, `hold`, `throw` et `impact` sont déclenchés par le composant
`Presentation`. Le matériau choisit l'impact ; la pierre d'apprentissage
emploie actuellement `impact-stone.wav`.

## Persistance des instances déplacées

Chaque `PsychokineticBody2D` placé possède un enfant `Persistence` configuré
avec un `persistent_id`. Le corps psychokinétique reste responsable de sa
physique ; le composant `PersistentWorldInstance` reste responsable de son état
d'instance. Cette séparation permet de réutiliser le même composant sur des
coffres, leviers, PNJ ou autres objets qui ne sont pas psychokinétiques.

La position et la rotation sont restaurées. La prise, la hauteur, la projection
et les vélocités sont des états transitoires : au retour dans la carte, l'objet
repose au sol et sa collision normale est rétablie.
