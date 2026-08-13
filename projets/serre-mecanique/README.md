# Serre mécanique

Prototype de jeu de plateforme 2D construit avec Tiled autour d'une serre industrielle abandonnée.

L'organisation complète de l'éditeur, les sources de vérité et la routine de
travail sont décrites dans
[`documentation/ORGANISATION_GODOT.md`](documentation/ORGANISATION_GODOT.md).
L'architecture extensible des armes et équipements est décrite dans
[`documentation/ARMES_ET_EQUIPEMENTS.md`](documentation/ARMES_ET_EQUIPEMENTS.md).
Le registre reliant les types Tiled aux scènes Godot est documenté dans
[`documentation/OBJETS_REUTILISABLES.md`](documentation/OBJETS_REUTILISABLES.md).
La frontière entre outils génériques et code du jeu est fixée dans
[`documentation/FRONTIERE_GENERIQUE_JEU.md`](documentation/FRONTIERE_GENERIQUE_JEU.md).
Le dernier état des forces et dettes techniques se trouve dans
[`documentation/AUDIT_ARCHITECTURE_2026-08-11.md`](documentation/AUDIT_ARCHITECTURE_2026-08-11.md).

## Lancer dans Godot

Le dossier est aussi un projet Godot 4. Ouvrir `project.godot` dans l'éditeur, puis
lancer la scène principale avec F6/F5. Le niveau principal est une scène Godot native
éditable utilisant des `TileMapLayer`, des corps physiques et des zones d'interaction.

Le menu **Projet > Outils > Régénérer les niveaux Tiled** reconvertit les fichiers TMX.
Cette opération remplace les scènes portant le même nom : les réglages partagés doivent
être modifiés dans les ressources `.tres`, et les ajouts propres à Godot dans une scène
parente ou dans des scènes d'interaction réutilisables.

Commandes : A/D, Q/D ou les flèches pour marcher, Espace pour sauter, Z pour
monter et S pour descendre dans une zone escaladable, et R pour réapparaître.
Avec le pistolet-grappin, la souris vise, le clic gauche tire ou décroche, Z raccourcit la
corde et S l'allonge. Z ne déclenche jamais un saut.

## Ouvrir dans Tiled

Les cartes jouables se trouvent directement dans `maps/`. La carte technique
`maps/examples/serre-mecanique-demo.tmj` utilise le tileset externe
`assets/tilesets/serre-mecanique-32x32.tsx` et une grille orthogonale de 32 × 32 pixels.

Le niveau jouable principal est `maps/niveau-01-serre.tmx`. Il contient six calques
visuels, un calque de collisions, un calque d'entités et un calque de zones techniques.

Le tileset contient 80 tuiles sur 16 colonnes :

- terrain en pierre et plateformes végétalisées ;
- structures métalliques, vitres et tuyauterie ;
- eau, dangers et éléments interactifs ;
- végétation et machines décoratives.

Les tuiles solides, plateformes à sens unique, dangers, échelle, chaîne, ressort,
leviers et porte possèdent des types ou propriétés Tiled prêts à être exploités par le jeu.

Le gabarit [`maps/gabarits/niveau-02-gabarit.tmx`](maps/gabarits/niveau-02-gabarit.tmx)
prépare huit calques visuels et huit calques d'objets séparés pour les collisions,
mouvements, dangers, entités, interactions, caméra, audio et repères. Il montre
aussi les cinq formes prises en charge : rectangle, ellipse, polygone, polyligne
et point. Le vocabulaire complet se trouve dans
[`documentation/CAHIER_VOCABULAIRE.md`](documentation/CAHIER_VOCABULAIRE.md).

Le niveau 2 construit avec la nouvelle planche est
[`maps/niveau-02-racines.tmx`](maps/niveau-02-racines.tmx). Pour le tester sans
changer le démarrage normal du projet, ouvrir puis lancer
[`scenes/launchers/niveau-02.tscn`](scenes/launchers/niveau-02.tscn) avec F6 dans Godot.

Le niveau 3, **La nef des automates**, utilise la direction artistique de la
planche ImageGen avec des masques modulaires corrigés bord à bord. Sa source éditable est
[`maps/niveau-03-automates.tmx`](maps/niveau-03-automates.tmx) et sa scène de test
est [`scenes/launchers/niveau-03.tscn`](scenes/launchers/niveau-03.tscn).

Le niveau 4, **L'arène des semences**, est un parkour symétrique préparé dans
[`maps/niveau-04-arene-parcours.tmx`](maps/niveau-04-arene-parcours.tmx). Sa
scène [`scenes/launchers/niveau-04.tscn`](scenes/launchers/niveau-04.tscn)
permet un test solo ; les quatre apparitions et les emplacements d'armes sont
déjà présents comme repères, mais leur logique multijoueur reste à développer.

## Régénérer

```sh
python3 game/serre/tools/generate_tileset.py
python3 game/serre/tools/generate_level_01.py
python3 game/serre/tools/generate_level_02_template.py
python3 game/serre/tools/generate_level_02.py
python3 game/serre/tools/generate_level_03.py
python3 game/serre/tools/generate_level_04_arena.py
```

Le générateur est déterministe et exige Pillow. Il recrée le PNG, le TSX et la carte
de démonstration sans interpolation : chaque cellule du PNG mesure exactement 32 × 32 pixels.
Toutes les tuiles solides sont opaques de bord à bord. Les plateformes à sens unique
ont une surface continue de 32 pixels de large, alignée avec leur collision de 8 pixels.
