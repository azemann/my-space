# Journal de conception — objets et combinaisons

Ce document conserve les réflexions de conception concernant les objets du
monde, la psychokinésie, le ramassage, la transformation et les combinaisons.
Il s'agit d'un journal vivant : une idée notée ici n'est pas nécessairement une
règle adoptée ni une fonctionnalité déjà implémentée.

Les règles techniques stables restent décrites dans le
[contrat d'inventaire](../contracts/INVENTORY_CONTRACT.md), le
[contrat psychokinétique](../contracts/PSYCHOKINESIS_CONTRACT.md) et le
[guide de création des objets](../ITEM_AUTHORING.md).

## État actuel du prototype

Au 19 août 2026 :

- la Plage du réveil utilise 30 types d'assets mobiles par psychokinésie ;
- 47 instances psychokinétiques sont placées sur la carte ;
- le catalogue d'inventaire contient trois définitions :
  `material.metal_fragment`, `story.metallic_shard` et
  `story.corked_bottle` ;
- seul l'éclat métallique de l'épave est actuellement configuré comme
  ramassable dans la carte Tiled ;
- aucune mécanique de recette, combinaison, fusion ou démantèlement n'est
  encore implémentée.

## Principe de classement envisagé

Un objet qui réagit à la psychokinésie n'est pas automatiquement un objet
d'inventaire. Chaque type d'objet du monde pourra recevoir l'un des usages
suivants :

| Usage | Signification | Exemple envisagé |
| --- | --- | --- |
| Manipulable uniquement | Reste dans le monde et sert aux puzzles ou au décor | gros rocher |
| Ramassable directement | Disparaît du monde et rejoint le sac | corde, bouteille |
| Cassable ou démontable | Produit des ressources plus petites | caisse donnant des planches |
| Transformable dans le monde | Change d'état sans entrer dans le sac | torche éteinte allumée |
| Objet narratif | Suit des règles particulières de quête | éclat métallique anormal |

## Registre initial des objets de la plage

Ce tableau sert à décider progressivement quels objets méritent une définition
d'inventaire. Les propositions ne sont pas encore adoptées.

| Famille | Objets du catalogue psychokinétique | Traitement envisagé |
| --- | --- | --- |
| Littoral | coquillages, étoile de mer, galets, algues, écume et débris | petits objets ramassables ou ingrédients |
| Bois flotté | brindilles et troncs | brindilles ramassables ; troncs à casser ou déplacer |
| Épave | mât, voile, planches, membrure, cordages | démontage en bois, tissu et corde |
| Contenants | caisses, tonneau, bouteille, sacoche, paquet de tissu | ouvrir, casser, fouiller ou ramasser selon la taille |
| Outils et débris | filet, ancre brisée, panneau, éclat métallique | matériaux, outils improvisés ou objets narratifs |
| Minéral | pierre d'entraînement, rocher mobile, rocher lourd | projectile, puzzle ou source de fragments |
| Végétation | jeune palmier, herbe et arbuste de dune | décor réactif ou récolte ponctuelle |

## Première sélection de ressources possibles

Pour éviter que chaque élément du décor devienne du butin, le premier essai
pourrait se limiter à :

- brindilles ;
- corde ;
- planche ;
- tissu déchiré ;
- fragment métallique ;
- bouteille ;
- algue ;
- coquillage ;
- petite pierre.

## Transformations à distinguer

Les termes restent provisoires, mais ils désignent des actions différentes :

- **combinaison** : des objets différents produisent un résultat précis ;
- **fusion** : plusieurs exemplaires ou variantes deviennent un objet amélioré ;
- **démantèlement** : un objet du monde ou du sac produit des composants ;
- **transformation** : un objet change d'état sans nécessairement changer
  d'identité ;
- **réparation** : des composants restaurent un objet incomplet ou cassé.

## Premières recettes à explorer

| Entrées | Résultat envisagé | Type |
| --- | --- | --- |
| brindilles + tissu déchiré | torche éteinte | combinaison |
| torche éteinte + source de feu | torche allumée | transformation |
| corde + planche | réparation improvisée | combinaison |
| fragments métalliques × 3 | pièce métallique | fusion |
| caisse brisée | planches + fragments | démantèlement |
| bouteille + algue | préparation inconnue | expérimentation |

## Questions ouvertes

- Les combinaisons sont-elles choisies dans le sac ou réalisées physiquement
  dans le monde avec la psychokinésie ?
- Une tentative invalide consomme-t-elle les ingrédients ?
- Le résultat d'une recette inconnue est-il révélé avant validation ?
- La psychokinésie peut-elle démanteler directement un objet cassable ?
- Les objets lourds nécessitent-ils un outil, un niveau de pouvoir ou plusieurs
  impacts avant de produire des composants ?
- Les recettes utilisent-elles des identifiants exacts, des tags génériques
  comme `wood` et `metal`, ou les deux ?

## Décisions prises

### 19 août 2026 — Séparer monde, inventaire et transformation

- conserver une liste explicite des objets psychokinétiques candidats au
  ramassage ;
- ne jamais rendre tous les objets psychokinétiques automatiquement
  ramassables ;
- prévoir des objets qui restent dans le monde mais produisent des composants ;
- tenir les futures recettes séparées des définitions d'objets et du code de
  l'interface ;
- utiliser ce document pour suivre les décisions de conception avant leur
  formalisation dans les contrats techniques.

## Prochaine séance

Passer les neuf ressources candidates une par une et décider pour chacune :

1. son identifiant stable ;
2. sa quantité maximale par pile ;
3. son mode d'obtention ;
4. ses tags de matière et d'usage ;
5. ses premières combinaisons ;
6. ce qui arrive à son instance physique après collecte ou transformation.
