# Neon Courier — corrections de mouvement v002

## Repos

La boucle `idle` conserve les pieds plantés, le pivot et la ligne de sol. Le
mouvement est limité à la respiration, au clignement et à une réaction légère
de la veste et de la chaîne. Aucun accroupissement ne rompt la boucle.

## Marche

La planche v001 et l'Identity Atlas canonique servent de references. La
regeneration conserve strictement le personnage, le costume, la palette et le
profil droit.

Les neuf cellules suivent un cycle complet :

1. contact jambe droite en avant ;
2. amorti droit ;
3. passage droit ;
4. point haut droit ;
5. contact oppose, jambe gauche en avant ;
6. amorti gauche ;
7. passage gauche ;
8. point haut gauche ;
9. transition vers la premiere pose.

L'echelle, la camera, la ligne de sol et le pivot restent constants.

## Attaque a la chaine

La sequence suit neuf phases : garde, transfert du poids, anticipation,
acceleration, impact horizontal, depassement, follow-through, recuperation de
la chaine et retour en garde.

La correction cible en priorite la frame centrale d'impact : la taille de la
tete, du torse et des jambes doit correspondre aux cellules voisines. La chaine
peut etre legerement raccourcie ou mise en perspective pour rester contenue
sans reduire le personnage.

## Validation

Les trois planches restent `candidate` jusqu’à vérification des GIF de preview,
de la fermeture des boucles et de la synchronisation de l’impact avec le
gameplay. Les sources utilisent un fond chroma `#00ff00`; le builder local
produit les planches transparentes, l’atlas compact et les métadonnées runtime.
