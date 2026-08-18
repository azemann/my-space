# Glossaire du projet

Ce document fixe le vocabulaire de référence pour le code, l'éditeur Godot,
Tiled et la documentation. Un terme défini ici ne doit pas être remplacé par un
synonyme dans un contrat technique.

## Monde et exécution

| Terme de référence | Sens précis | Nom dans le code |
| --- | --- | --- |
| Partie | Exécution complète qui survit aux changements de carte. | `GameRoot` |
| Carte | Zone jouable chargeable et remplaçable. Employer « scène » uniquement pour une ressource Godot `PackedScene`. | `current_map`, `level_id` |
| Identifiant de carte | Identité stable et unique d'une carte. | `level_id` |
| Acteur persistant | Acteur qui reste vivant pendant un changement de carte, comme le joueur. | `PersistentActors` |
| Instance du monde | Exemplaire placé d'un asset dans une carte. Deux instances peuvent partager le même asset. | parent de `PersistentWorldInstance` |

## Assets et placements

| Terme de référence | Sens précis | Nom dans le code |
| --- | --- | --- |
| Asset | Ressource réutilisable : texture, tuile, scène, son ou profil. | `asset_id` |
| Placement auteur | Position et réglages définis dans Godot ou Tiled avant l'exécution. | TMX, TSX ou scène `.tscn` |
| Identifiant persistant | Identité stable d'une instance à l'intérieur de sa carte. Ce n'est ni le nom du nœud ni l'identifiant de l'asset. | `persistent_id` |
| Composant de persistance | Nœud Godot enfant qui déclare ce qui doit être mémorisé pour son parent. | `PersistentWorldInstance` |
| Profil | Ressource Godot `.tres` éditable qui centralise les réglages réutilisables d'un comportement. | classe `Resource` spécialisée |
| Empreinte de pas | Marque visuelle temporaire laissée par un acteur sur une surface compatible. Ne pas confondre avec l'empreinte physique d'une collision. | `FootprintDecal2D` |
| Traînée d'empreintes | Composant de carte qui détecte les pas et instancie les empreintes configurées par un profil. | `FootprintTrail2D` |

## Persistance

| Terme de référence | Sens précis | Nom dans le code |
| --- | --- | --- |
| État d'instance | Données mémorisées pour une instance précise. La version actuelle contient position et rotation. | `instance_state` |
| Capture d'état | Lecture des états d'instance avant de libérer une carte. | `capture_map_state()` |
| Restauration d'état | Application des états mémorisés après avoir instancié une carte. | `restore_map_state()` |
| État transitoire | Donnée physique qui ne survit pas au chargement : prise, hauteur, projection ou vélocité. | `normalize_transient_physics` |
| Persistance de session | Mémoire conservée tant que la partie reste ouverte. | `WorldStateStore` |
| Sauvegarde durable | Écriture future sur disque qui survivra à la fermeture du jeu. | futur fichier sous `user://` |

## Configuration dans l'éditeur Godot

Les scènes `.tscn`, ressources `.tres`, nœuds et propriétés de l'Inspecteur
sont prioritaires pour tout réglage artistique ou de gameplay. Un script sert
à relier ces ressources ou à exécuter un comportement impossible à exprimer
dans l'éditeur ; il ne doit pas cacher des valeurs qui peuvent être exposées.

Pour rendre persistante une instance créée directement dans Godot :

1. ajouter un nœud enfant nommé `Persistence` ;
2. lui affecter le script `persistent_world_instance.gd` ;
3. renseigner un `persistent_id` unique dans l'Inspecteur ;
4. régler `persist_position`, `persist_rotation` et
   `normalize_transient_physics` selon le comportement attendu.

Pour un objet placé dans Tiled, ajouter une propriété `persistent_id` sur le
placement. Le convertisseur crée le même composant Godot. En l'absence de cette
propriété, il emploie `tiled.<id>` comme correspondance déterministe.

Le nœud `Game/WorldState` permet de désactiver toute la persistance de session
depuis l'Inspecteur afin de tester les placements auteur.
