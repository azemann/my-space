# Contrat d'inventaire

## Décision de conception

Le sac principal d'Azeman possède 20 emplacements. Un emplacement contient une
pile compatible ou un objet unique. La limite de pile appartient à la
définition de l'objet. Le jeu n'applique aucun poids global.

L'équipement, les objets de quête, les coffres et une future barre rapide ne
doivent pas dupliquer le contenu du sac : ce sont d'autres conteneurs ou des
vues qui référencent les mêmes identités stables.

## Trois identités distinctes

| Identité | Exemple | Autorité |
| --- | --- | --- |
| Type d'objet | `material.metal_fragment` | `ItemDefinition` dans le catalogue |
| Instance unique | `bottle.beach.001` | pile runtime et sauvegarde |
| Instance du monde | `plage-du-reveil/tiled.25` | carte et persistance du monde |

Un objet physique ou psychokinétique ne devient jamais implicitement un objet
d'inventaire. Un futur composant de ramassage fera explicitement le lien avec
une `ItemDefinition` et une quantité.

## Autorités

- `ItemDefinition` est une ressource auteur immuable. Elle contient le nom,
  l'icône, la catégorie, les tags et la limite de pile, jamais une quantité.
- `ItemCatalog` garantit l'unicité des `item_id` et les résout au chargement
  d'une sauvegarde. Le fichier runtime est généré depuis
  `game/content/items/definitions/` et ne s'édite pas à la main.
- `InventoryComponent` possède les piles runtime et reste enfant de l'acteur
  persistant.
- `InventoryPanel` observe le composant. Il n'écrit jamais directement dans
  ses emplacements.
- une sauvegarde conserve des identifiants et des valeurs simples, jamais un
  chemin de nœud, un UID Godot ou une référence de ressource.

## Transactions

`add`, `remove` et `move` sont atomiques. Une opération refusée ne change rien.
Le résultat indique explicitement succès, quantité insuffisante, manque de
place, emplacement invalide ou incompatibilité.

Le ramassage suivra donc cet ordre :

1. demander au sac d'ajouter toute la quantité ;
2. conserver l'objet du monde si la transaction échoue ;
3. marquer l'instance du monde comme collectée uniquement après succès ;
4. émettre ensuite les retours visuels et sonores.

Cette règle interdit les pertes silencieuses lorsque le sac est plein.

La procédure auteur complète, les chemins et les propriétés Tiled sont décrits
dans [le guide de création des objets](../ITEM_AUTHORING.md).

## Extensions prévues

- un conteneur d'équipement à emplacements nommés ;
- un conteneur logique d'objets de quête non jetables ;
- des coffres utilisant la même API de transfert ;
- une barre rapide référençant des emplacements ou des `item_id` ;
- des données d'instance pour durabilité, qualité ou enchantements ;
- migration de sauvegarde à chaque changement de `schema_version`.

Ces extensions ne doivent pas ajouter de règles particulières dans l'interface.

## Où configurer quoi

| Besoin | Ressource ou nœud à modifier |
| --- | --- |
| Nombre d'emplacements | enfant `Inventory` de `game/actors/player/player.tscn` |
| Marges, colonnes, cases, couleurs et textes | `game/ui/inventory/inventory_ui_config.tres` |
| Nom, pile, catégorie et règles d'un objet | définition sous `game/content/items/definitions/` |
| Touche d'ouverture | action `inventory` dans l'Input Map |

La racine `InventoryPanel` reste toujours à `(0, 0)` et couvre le viewport. Elle
ne se déplace pas pour cadrer le sac : les marges sûres de la ressource UI
déplacent uniquement le panneau intérieur et sont limitées automatiquement pour
éviter tout rognage.
