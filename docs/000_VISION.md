# Vision AssetForge

## Problème

Les générateurs d’images produisent des visuels, mais un asset de jeu ou d’application est un objet technique : il possède un rôle, une taille, un cadrage, une transparence, une variante, une cible d’export, des métadonnées et une relation avec une identité visuelle.

## Proposition

AssetForge transforme une intention en chaîne de production reproductible.

Il sépare clairement :

1. la définition du langage visuel ;
2. la génération ou l’import de l’image ;
3. le traitement technique ;
4. la validation ;
5. l’export ;
6. le catalogage.

## Principe fondateur

Aucun asset ne doit être produit sans contexte visuel explicite.

Le premier artefact d’un projet AssetForge est donc une planche d’identité visuelle accompagnée d’un profil structuré et versionné.

## Portée

AssetForge doit rester :

- indépendant du style ;
- indépendant du fournisseur d’image ;
- indépendant du moteur cible ;
- utilisable en CLI avant toute interface graphique ;
- compatible avec une génération IA ou un import manuel ;
- inspectable et réversible.

## Non-objectifs initiaux

La V0 ne cherche pas encore à :

- animer automatiquement des personnages ;
- produire des squelettes 2D ;
- garantir la cohérence parfaite entre plusieurs poses ;
- remplacer un artiste ;
- supporter tous les moteurs de jeu.

Elle cherche d’abord à rendre fiable le passage :

```text
intention → identité visuelle → asset normalisé
```
