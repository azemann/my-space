# Objets de gameplay

Ces scènes sont des modèles réutilisables instanciés par le registre Tiled.

- `movement/` : déplacement du joueur ;
- `hazards/` : dégâts et réapparition ;
- `interactions/` : checkpoint, collecte, levier et sortie ;
- `zones/` : déclencheurs et volumes techniques.

Modifier une scène ici actualise toutes ses instances lors du prochain chargement
du niveau, sans devoir modifier chaque objet séparément.
