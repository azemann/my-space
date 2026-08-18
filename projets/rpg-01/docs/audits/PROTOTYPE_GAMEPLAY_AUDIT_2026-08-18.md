# Audit de cohérence du prototype — 18 août 2026

## Verdict

Le projet possède un socle réutilisable crédible : runtime persistant, joueur
séparé des cartes, conversion Tiled déterministe, profils psychokinétiques,
caméra configurée et tests de traversabilité. Il ne constitue toutefois pas
encore une tranche jouable cohérente. La contradiction initiale du pont a été
corrigée pendant cet audit : les calques peints sont désormais non physiques et
les volumes explicites décident seuls de la géographie.

L'objectif immédiat n'est donc pas d'ajouter inventaire, combat, dialogues ou
quêtes. Il faut d'abord rendre irréprochable la boucle suivante : marcher,
comprendre le relief, détecter un objet, le saisir, le déplacer, le lancer et
atteindre une sortie de carte sans contradiction.

## Partage des responsabilités

Codex maintient les réglages invisibles : unités, calques et masques physiques,
autorité des données, conventions Tiled, précision des collisions, limites de
caméra, persistance, budget de performance et tests de non-régression.

Le créateur choisit les sensations : Azeman doit-il sembler lourd ou vif, la
télékinésie douce ou brutale, la caméra proche ou contemplative, les effets
discrets ou spectaculaires. Ces choix sont ensuite traduits en ressources de
configuration nommées et testables, jamais dispersés dans les scènes.

## Invariants non négociables

1. Ce que l'image promet, la physique le respecte.
2. Un seul système fait autorité pour chaque donnée ; une couche visuelle ne
   doit pas contredire un volume de traversabilité.
3. Le joueur, les objets tenus et les déclencheurs ne se poussent pas par effet
   accidentel de masque physique.
4. Toute exception spatiale visible — pont, escalier, porte, passage — possède
   un test positif ; chaque frontière possède un test négatif.
5. Une carte générée n'est jamais corrigée à la main : la correction remonte au
   TMX, au TileSet ou au convertisseur.
6. Une propriété de sensation globale vit dans une ressource de configuration,
   pas dans quarante-cinq instances.
7. Clavier-souris et manette donnent accès à la même action, même si leur mode de
   ciblage diffère.
8. Une nouvelle carte doit fonctionner sans connaître la plage du réveil.

## P0 — incohérences qui bloquent la tranche jouable

### 1. Autorité des collisions de terrain — résolu

`WaterBase` conservait les collisions pleines du TileSet. Le calque
`CollisionOverrides` ouvrait correctement les rangées du pont, mais ne pouvait
pas annuler la collision déjà portée par l'eau visuelle.

Décision appliquée : dans une carte importée, les grands calques de terrain
restent visuels et `CollisionOverrides` devient l'autorité exclusive de la
géographie. Les collisions du TileSet restent utiles aux objets réutilisables,
mais ne se cumulent plus avec les volumes de carte. Le test transforme aussi les
coordonnées locales du TMX vers l'espace global avant toute simulation. Eau,
falaises, côtés et limites bloquent ; pont et escalier passent.

### 2. Détection psychokinétique — sélection précise résolue

La surbrillance fantôme cyan/violette rend les états lisibles. La cible est
désormais acquise sur les pixels opaques réels des `Sprite2D` et objets d'atlas
Tiled. Le vide transparent n'est plus cliquable, les chevauchements suivent
l'ordre visuel et le clic recalcule immédiatement sa cible.

La manette emploie également un score directionnel. Il reste à ajouter le
contrôle de ligne de vue entre Azeman et l'objet afin d'interdire une prise au
travers d'un mur ou d'une falaise.

### 3. Le lancer n'a pas encore une physique d'impact complète

La vitesse verticale est simulée visuellement ; l'événement d'impact se produit
quand cette hauteur revient à zéro, pas lorsque le corps heurte réellement un
mur ou un autre objet. Les objets légers peuvent dépasser 1 000 px/s et la
détection continue des collisions n'est pas activée : une petite pierre peut
traverser une paroi fine.

Correction attendue : activer la détection continue seulement pendant les
lancers rapides, capter les contacts réels, séparer impact contre le sol et
impact latéral, puis calculer son, particules, secousse et futurs dégâts depuis
la vitesse relative et le matériau.

## P1 — problèmes qui dégradent fortement le ressenti

- `Escape` sert à la fois à mettre en pause et à annuler la psychokinésie. Une
  règle de priorité et une interface de pause sont nécessaires.
- Seule la pierre d'apprentissage possède les quatre sons. Les 45 objets issus
  de Tiled restent silencieux. Les sons doivent être mutualisés par matériau,
  pas dupliqués en quatre lecteurs sur chaque objet.
- Les collisions des objets dynamiques convertis sont des capsules génériques ;
  les polygones fins du TileSet sont perdus. La forme dynamique doit provenir de
  l'empreinte déclarée ou d'un profil de collision explicite.
- La hauteur psychokinétique est visuelle : elle ne permet pas encore de passer
  au-dessus d'un obstacle bas et ne connaît pas les niveaux de falaise.
- Les `HeightZones` et `ElevationTransitions` existent dans les cartes, mais
  aucun système runtime ne les applique encore au joueur ou aux objets.
- La caméra utilise des zooms 0,90 et 0,85. Sur du pixel art, ces valeurs
  fractionnaires peuvent produire une taille de pixel irrégulière et du
  scintillement en mouvement.
- La force maximale de secousse de caméra n'est jamais réinitialisée ; un ancien
  choc fort peut contaminer les chocs faibles suivants. La secousse devrait
  agir via l'offset de caméra, séparément du suivi lissé.
- Les formats d'écran plus larges affichent davantage de monde grâce au mode
  `expand`, mais aucun test ne garantit que le vide hors carte reste invisible.
- Les zones `Interactions`, `Entrances`, `Exits`, rencontres et audio sont
  converties mais n'ont pas encore de consommateur gameplay. Le signal
  d'interaction du joueur n'est connecté à aucun système.

## P2 — dette de production avant plusieurs cartes

- Les 46 corps psychokinétiques exécutent leurs traitements même au repos. La
  scène compte actuellement environ 380 nœuds et 115 `TileMapLayer`, dont les
  fantômes invisibles. Acceptable pour la plage, insuffisant comme règle pour un
  village dense : les corps endormis devront désactiver leurs mises à jour.
- Quatorze objets générés portent un nom automatique comme `@RigidBody2D@…`.
  Leur nom et leur `persistent_id` doivent venir d'un identifiant stable Tiled,
  jamais seulement d'un numéro susceptible de changer lors d'une reconstruction.
- La persistance conserve position et rotation, mais pas encore les états
  collecté, détruit, ouvert ou activé. Les objets indispensables à un puzzle
  auront également besoin d'une restauration anti-blocage.
- Le wrapper de la plage référence un UID de scène générée devenu invalide et
  produit un avertissement au chargement. Une conversion annoncée « propre » ne
  doit émettre aucun avertissement.
- Après reconstruction d'un PNG, Godot doit réimporter la texture avant de
  rebâtir le TileSet. Cette étape doit être orchestrée par une commande unique.
- Un test Godot en échec peut rester actif au lieu de quitter avec un code
  d'erreur. Il faut un lanceur global borné dans le temps et un récapitulatif.
- Il n'existe pas encore d'interface de reconfiguration des commandes ni de
  contrôles tactiles. La compatibilité mobile ne doit pas être promise avant que
  ces deux points et les budgets graphiques soient testés sur appareil.

## Ce qui est déjà sain

- résolution logique 640 × 360, étirement du viewport et mise à l'échelle
  entière ;
- direction normalisée : pas d'accélération diagonale accidentelle ;
- accélération et freinage configurés dans `player_config.tres` ;
- joueur et caméra persistent lors du changement de carte ;
- séparation des couches Monde, Acteurs, Interactions et Déclencheurs ;
- un objet tenu ou lancé ne pousse plus Azeman ;
- ombre psychokinétique ancrée au sol et indépendante de la rotation ;
- retour visuel distinct pour le survol et la prise ;
- animations d'eau en vraies tuiles animées Godot/Tiled, orientées sud vers nord ;
- conversion Tiled en deux passes, cartes sources et scènes générées séparées ;
- état de session des objets déplacés déjà restauré.

## Ordre de correction recommandé

### Lot A — espace fiable

Terminé le 18 août 2026 : `CollisionOverrides` est autoritaire, le pont et
l'escalier passent, eau, falaises et limites bloquent, et l'UID obsolète du
wrapper de plage a été supprimé.

### Lot B — pouvoir précis

Remplacer la sélection circulaire par des requêtes physiques stables, recalculer
au clic, ajouter l'occlusion et le ciblage directionnel manette, puis tester les
objets superposés et de grandes dimensions.

### Lot C — impact et caméra

Ajouter collisions continues temporaires, contacts réels et sons mutualisés ;
corriger la secousse, choisir une politique de zoom compatible pixel art et
tester 16:9, 16:10, 21:9 et écran étroit.

### Lot D — première boucle RPG

Brancher interaction, entrée/sortie de carte et hauteurs. Ensuite seulement,
construire la découverte narrative de la télékinésie sur la plage.

### Lot E — industrialisation

Optimiser les objets endormis, stabiliser les identifiants, enrichir la
persistance et fournir une commande unique : assets → import Godot → TileSet →
TMX → scènes → tests.

## Test manuel de cinq minutes

Après chaque lot, vérifier dans cet ordre :

1. marcher puis relâcher dans les quatre directions ;
2. longer eau, falaise, arbre et bord de carte sans accroche invisible ;
3. franchir uniquement le pont et les escaliers visibles ;
4. survoler rapidement plusieurs objets, y compris superposés ;
5. saisir, monter, déplacer, lâcher et lancer contre sol puis mur ;
6. confirmer que l'objet ne pousse jamais Azeman ;
7. atteindre une zone de caméra et revenir au cadrage global ;
8. répéter à la manette ;
9. relancer la carte et vérifier les positions persistées ;
10. redimensionner la fenêtre et contrôler les bords du monde.

Le ressenti du créateur complète les tests, mais ne les remplace pas : s'il faut
« deviner » pourquoi une action n'a pas marché, le retour visuel ou la règle de
jeu reste insuffisant.
