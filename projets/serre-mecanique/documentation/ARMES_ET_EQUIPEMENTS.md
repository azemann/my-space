# Armes et équipements

## Architecture

Une arme n'est pas codée directement dans le joueur.

```text
WeaponDefinition (.tres)
  identité, catégorie, texture, position du canon, délai
          ↓
WeaponController (nœud Equipment du joueur)
  inventaire, équipement courant, visée, affichage, signal d'utilisation
          ↓
Comportement spécialisé
  grappin dans le joueur, futurs projectiles ou attaques dans leurs scripts
```

Les définitions vivent dans `resources/weapons/`, les images dans
`assets/weapons/` et les scripts génériques dans `addons/my_space_core/equipment/`.

## Design modulaire et personnalisation

Chaque arme possède une **texture ou un spritesheet spécifique**. Ce visuel peut
ensuite produire plusieurs variantes sans dupliquer le comportement de l'arme :

- silhouette ou pièces interchangeables ;
- palette de couleurs et matériaux ;
- états repos, visée, tir et recharge ;
- effets visuels propres à une amélioration ;
- icône d'inventaire dérivée du même design.

Le PNG décrit l'apparence, `WeaponDefinition` décrit l'identité et les réglages,
et la scène ou le script spécialisé décrit le comportement. Ainsi, personnaliser
le pistolet-grappin ne nécessite pas de recoder le grappin.

## Premier équipement : pistolet-grappin

- souris : viser ;
- clic gauche : tirer la corde ;
- gauche/droite : se balancer ;
- `Z` ou haut : raccourcir la corde ;
- `S` ou bas : allonger la corde ;
- clic gauche ou saut : lâcher sans perdre son élan ;
- clic gauche de nouveau en plein vol : tirer une nouvelle corde.

La boucle reprend les commandes essentielles décrites dans le manuel officiel de
Worms Armageddon : balancement latéral, longueur réglable, décrochage et nouveau
tir en plein vol.

## Surfaces compatibles

Le grappin s'accroche uniquement à :

- une collision Tiled de type `one_way` ;
- une collision de type `grapple_surface` ;
- n'importe quelle collision portant `grapple_enabled=true`.

Un sol `solid` ordinaire est refusé. Cette règle permet de contrôler très
précisément le level design sans créer des zones d'accroche séparées.

## Ajouter une future arme

1. Créer son image dans `assets/weapons/`.
2. Dupliquer `resources/weapons/grappling-pistol.tres`.
3. Changer `weapon_id`, nom, catégorie, texture et position du canon.
4. Ajouter la ressource à l'inventaire du nœud `Player/Equipment`.
5. Connecter le signal d'utilisation à un comportement spécialisé.

Le contrôleur expose `equip(index)` et `equip_next()`. La roue de sélection
utilise déjà `equip(index)` ; `equip_next()` reste disponible pour un futur
raccourci permettant de faire défiler rapidement les armes.

`C` range l'équipement courant sans oublier sa sélection et le ressort au second
appui. Ranger annule une charge en cours et décroche un grappin actif. Choisir une
arme dans la roue la ressort automatiquement. L'action stable
`weapon_holster` reste reconfigurable dans l'Input Map.

## Première arme de combat : bazooka mécanique

Le bazooka est la deuxième ressource de l'inventaire, après le pistolet-grappin.
Il sert de référence à la future famille des armes à projectile.

```text
bazooka.tres
  texture, chambre de pression, durée, puissance minimale, recul, projectile
        ↓
bazooka_rocket.tscn
  vitesse, gravité, durée de vie, masque, scène d'explosion
        ↓
bazooka_explosion.tscn
  animation, rayon, dégâts, projection
        ↓
HealthComponent du personnage
```

### Réglages accessibles dans Godot

| Fichier ou nœud | Réglages principaux |
|---|---|
| `resources/weapons/bazooka.tres` | visuel, icône, position, bouche, durée de charge, puissance minimale, délai, recul |
| `scenes/weapons/projectiles/bazooka_rocket.tscn` | vitesse, gravité, durée maximale, masque de collision |
| `scenes/effects/bazooka_explosion.tscn` | dégâts maximaux et force de projection |
| `BazookaExplosion/DamageRadius` | cercle de dégâts redimensionnable visuellement |
| `resources/effects/bazooka-explosion-frames.tres` | 16 frames et vitesse de lecture |
| `Player/Health` | vie maximale du personnage |

La roquette emploie un rayon physique entre sa position précédente et sa
position suivante. Elle ne traverse donc pas une plateforme simplement parce
qu'elle se déplace rapidement. Son explosion applique une atténuation selon la
distance : les dégâts et le recul sont maximums au centre, puis diminuent
jusqu'au bord du cercle.

Le terrain reste volontairement indestructible dans cette première version.
La destruction sera un système distinct afin qu'une explosion puisse produire
des dégâts sans obligatoirement modifier le décor.

### Tir chargé intégré à l'arme

- maintenir le clic gauche démarre la mise sous pression ;
- l'angle et le sens du tir sont verrouillés au début de la charge ;
- les douze cellules de la chambre s'allument directement sur le bazooka ;
- relâcher le clic gauche tire avec la puissance accumulée ;
- la puissance module la vitesse initiale et le recul, pas les dégâts de
  l'explosion ;
- `Charge Duration` règle le temps de charge maximale et `Minimum Power` la
  force d'un relâchement immédiat.

Le contrôleur générique connaît seulement une valeur `charge_ratio`. Le matériau
visuel appartient à `bazooka.tres` : une autre arme ou un autre jeu peut donc
utiliser une jauge totalement différente sans dépendre de Serre mécanique.

Le son de départ est affecté dans `bazooka.tres` et ne joue qu'au relâchement.
Les nœuds `FlightAudio` et `ExplosionAudio` sont déjà placés dans les scènes,
mais leur flux reste vide. Le son d'explosion est volontairement réservé à une
directive future.

## Roue des armes

La scène `scenes/ui/weapon_selection_panel.tscn` lit directement l'inventaire du
nœud `Player/Equipment`. Elle ne possède donc aucune liste d'armes dupliquée.
Le composant `WeaponWheel` dessine lui-même les secteurs, contours, numéros,
quantités et surbrillances avec l'API 2D de Godot. Aucun fond ImageGen n'est
nécessaire : notre direction visuelle reste entièrement modifiable dans le code
et dans l'éditeur.

- `Tab` : ouvrir ou fermer l'arsenal ;
- `Échap` : fermer ;
- souris : survoler un secteur ;
- gauche/droite : parcourir les armes disponibles ;
- `Entrée`, `1` à `9` ou clic : équiper un secteur disponible ;
- `∞` : équipement sans quantité limitée ;
- cercle barré : emplacement réservé à une future arme.

La première roue contient huit secteurs lisibles. Elle s'agrandit si l'inventaire
en demande davantage, jusqu'à douze secteurs. Pendant qu'elle est ouverte, le tir
principal du contrôleur est bloqué. Une arme ajoutée à l'inventaire apparaît
automatiquement avec son `selection_icon`, son numéro et sa quantité.
