# Audit d'architecture — 11 août 2026

## Verdict

La structure des fichiers possède désormais une frontière saine entre les
briques réutilisables et Serre mécanique. Les neuf contrôles automatiques passent,
dont une régénération complète du niveau 2 et un test interdisant les dépendances
du générique vers le jeu.

## Acquis solides

- niveau 1 figé et protégé de la régénération ;
- niveau 2 piloté par sa source Tiled ;
- objets de gameplay instanciés depuis des scènes réutilisables ;
- profil Serre séparé du convertisseur TMX/TSX ;
- configurations, niveau natif et équipement rangés dans le cœur générique ;
- panneau d'éditeur explicitement identifié comme propre au jeu ;
- tests des niveaux, contrôles, échelles, grappin, objets et frontière.

## Dettes fonctionnelles restantes

| Priorité | Constat | Conséquence |
|---|---|---|
| haute | `ZoneMort` du niveau 1 a `monitoring=false` | la zone ne détecte pas le joueur |
| haute | levier et sortie ne font qu'afficher un message | la boucle de fin de niveau n'est pas jouable |
| haute | le grappin reste dans `player.gd` | ajouter des armes alourdira le joueur |
| moyenne | commandes lues avec des constantes `KEY_*` | remappage et manette difficiles |
| moyenne | graines supprimées sans inventaire ni score | aucune progression de collecte persistante |
| moyenne | caméra réglée sur une limite fixe | futurs niveaux de tailles différentes mal cadrés |
| basse | `AnimationPlayer` des objets est encore vide | architecture visuelle prête mais non animée |

## Prochain découpage recommandé

Le prochain chantier ne doit plus déplacer des dossiers. Il doit découpler le
comportement :

1. créer un état de partie/niveau pour collecte, leviers et sorties ;
2. extraire le grappin dans un composant d'équipement ;
3. remplacer les touches physiques par des actions `InputMap` ;
4. connecter la caméra aux limites de `LevelDefinition` ;
5. ajouter des tests fonctionnels levier → porte → changement de niveau.

La règle reste : une abstraction ne rejoint le cœur générique qu'après avoir été
utilisée par au moins deux projets ou conçue sans aucune dépendance au vocabulaire
de Serre mécanique.
