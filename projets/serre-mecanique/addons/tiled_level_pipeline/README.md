# Tiled Level Pipeline

Conversion générique TMX/TSX vers des scènes Godot natives. Le convertisseur ne
connaît aucun niveau ni objet de Serre mécanique : toutes les décisions de projet
lui sont fournies par un profil.

Une carte peut utiliser plusieurs tilesets externes. Chaque balise `tileset` est
convertie en une source d'atlas Godot distincte et son `firstgid` détermine la
source et la cellule utilisées. Les transformations Tiled horizontale, verticale
et diagonale sont conservées.

La conversion se fait en deux passes : tous les TMX, TSX, PNG, noms de calques et
GID sont validés avant la première écriture. Une référence cassée ou un nom de
calque de tuiles dupliqué interrompt donc l'opération sans régénération partielle.

Le profil doit fournir les répertoires d'entrée/sortie, les niveaux figés, les
scènes d'objets, le matériau physique et les éventuels post-traitements.
