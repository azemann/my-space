# Contrat de conception des cartes RPG

Ce contrat s'applique à la vallée et à toutes les futures maps : extérieurs,
intérieurs, grottes, donjons et villages.

## Principe fondamental

L'image explique l'espace au joueur ; la physique doit tenir exactement cette
promesse. Une rivière visible bloque. Une falaise visible ne se contourne pas
par un bord oublié. Un pont, un escalier ou une porte est une exception explicite
à une frontière autrement continue.

Dans une scène convertie, tous les `TileMapLayer` peints ont leurs collisions
désactivées. `Gameplay/CollisionOverrides` est l'unique autorité des frontières
géographiques. Les objets nommés placés depuis une collection Tiled restent une
autorité distincte pour leur propre empreinte : arbre, rocher, clôture, maison
ou objet psychokinétique.

## Les quatre graphes d'une map

1. **Visuel** : terrains, objets, premier plan et Y-sort.
2. **Traversabilité** : solides continus et passages autorisés.
3. **Sémantique** : hauteurs, surfaces, interactions, entrées et sorties.
4. **Caméra** : limites globales et zones de cadrage prioritaires.

Ces graphes se correspondent mais restent sur des calques séparés pour être
inspectables dans Tiled et dans Godot.

## Calques obligatoires

| Calque | Responsabilité |
| --- | --- |
| `CollisionOverrides` | eau, relief, limites et volumes propres à la map |
| `HeightZones` | niveau entier du sol occupé |
| `ElevationTransitions` | seul lien autorisé entre deux hauteurs |
| `Entrances` / `Exits` | changement de scène avec destination et spawn |
| `Interactions` | volumes et identifiants d'action |
| `SpawnPoints` | points d'apparition stables et uniques |
| `CameraZones` | limites, zoom, décalage et priorité |

## Règles de construction

- Les objets réutilisables portent leur collision de pied dans le TileSet.
- Chaque instance dont l'état doit être restauré porte un `persistent_id`
  unique dans sa carte ; l'identifiant d'asset ne remplace jamais cet identifiant.
- Les obstacles géographiques portent leur collision uniquement dans
  `CollisionOverrides`.
- Les collisions suivent les pieds et les frontières, jamais toute la hauteur
  visuelle d'un arbre ou d'une façade.
- Une hauteur supérieure est fermée sur tout son périmètre, avec une ouverture
  par transition déclarée.
- L'eau reste bloquée sous son décor ; une bande de traversée n'est ouverte que
  sous le tablier réel d'un pont.
- Le bord d'une map est solide même lorsqu'une zone de sortie le précède.
- Les zones de détection utilisent la couche `Interactions` et observent la
  couche `Acteurs`.
- Une zone caméra locale doit avoir une priorité supérieure à la zone globale.
- Un axe principal extérieur mesure au moins deux tuiles lorsque deux acteurs
  doivent pouvoir se croiser ; un sentier d'une tuile doit avoir une raison de
  level design explicite.
- Un chemin de hauteur différente ne touche jamais graphiquement un chemin bas
  à travers une falaise : leur jonction doit passer par la transition visible.

## Définition de “jouable”

Une map n'est pas jouable parce qu'elle s'affiche. Elle l'est lorsque :

- le validateur `pipeline/tiled/tools/map_contract.py` réussit ;
- le convertisseur Godot réussit sans avertissement ;
- chaque famille d'obstacle possède un test de non-franchissement ;
- chaque pont, escalier et porte possède un test de franchissement ;
- le joueur ne peut ni quitter les limites ni atteindre une hauteur par le côté ;
- les zones caméra détectent le joueur et reviennent au cadrage global en sortie.

Le test de référence actuel est `pipeline/tests/verify_world_traversal.gd`.
