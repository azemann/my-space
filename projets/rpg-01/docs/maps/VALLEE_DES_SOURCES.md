# Vallée des Sources

Première zone extérieure et scène principale du projet.

## Composition

- village et maison du gardien à l'ouest ;
- potager clôturé au nord-ouest ;
- place pavée, puits et panneau comme centre lisible ;
- axes principaux en terre de `64 px`, assez larges pour croiser PNJ et joueur ;
- chemins secondaires hiérarchisés vers potager, pont, plateau et boucle sud ;
- rivière et bassin à l'est ;
- pont central comme franchissement autorisé ;
- deux plateaux de hauteur 1 accessibles par escaliers ;
- routes nord et sud préparées pour les cartes futures ;
- forêt périphérique, rochers, cultures, plantes d'eau et micro-décor.

## Autorités

- `pipeline/tiled/maps/source/vallee-des-sources.tmx` : placement et données spatiales ;
- `game/world/maps/generated/vallee-des-sources.tscn` : résultat dérivé, lecture seule ;
- `game/world/maps/vallee-des-sources/vallee-des-sources.tscn` : composition runtime éditable.

## Gameplay préparé

- apparitions `village-arrival` et `after-bridge` ;
- entrée de la maison vers le futur intérieur `house-guardian` ;
- interactions du puits, du panneau et du potager ;
- collision exacte de chaque segment d'eau, bassin compris ;
- périmètres complets des falaises, sans contournement latéral ;
- rebord arrière, murs latéraux et double face avant rendent chaque hauteur
  immédiatement visible ;
- limites physiques sur les quatre bords de la carte ;
- passages réservés au pont et aux escaliers ;
- deux zones de hauteur 1 ;
- sorties vers les futures routes nord et sud ;
- limites de caméra sur 1280 × 1280 px ;
- zone caméra prioritaire sur le pont : recul à `1.75` et cadrage légèrement
  relevé pour montrer la traversée.

Le chemin haut du plateau sud et son approche basse sont volontairement
séparés. Leur unique raccord visuel et physique est l'escalier.

Tous les calques peints sont visuels. `Gameplay/CollisionOverrides` porte seul
la géographie physique : l'absence de volume sous le tablier et dans les
escaliers constitue donc une vraie ouverture, sans collision de tuile cachée.

Les futurs acteurs doivent être ajoutés à
`World/PlacedObjects/YSortedObjects` afin de partager le tri vertical avec les
arbres, rochers et accessoires.
