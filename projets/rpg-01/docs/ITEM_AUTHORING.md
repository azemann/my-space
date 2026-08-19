# Créer et gérer les objets d'inventaire

## Séparation des ressources

Chaque objet traverse trois espaces qui ne se mélangent pas :

```text
pipeline/assets/sources/items/<catégorie>/<objet>/
    sources haute définition, prompts, provenance et fichiers de travail

game/content/items/definitions/<catégorie>/<objet>.tres
    données gameplay éditables dans l'Inspecteur Godot

game/content/items/icons/<catégorie>/<objet>.png
    icône runtime finale, transparente et prête à importer
```

Le code générique reste dans `game/systems/inventory/`. Une nouvelle potion,
clé ou ressource ne justifie donc jamais un nouveau script.

## Identité et nommage

L'identifiant suit `<espace_de_noms>.<nom_sémantique>` :

- `material.metal_fragment` ;
- `story.metallic_shard` ;
- `consumable.small_health_potion` ;
- `equipment.rusty_sword`.

Le fichier reprend la partie sémantique en `snake_case`. L'espace de noms
exprime l'autorité (`story`, `material`, `equipment`) tandis que le champ
`category` utilise les catégories gameplay stables `material`, `consumable`,
`quest`, `equipment`, `key` et `misc`. Les dossiers peuvent regrouper ces
familles au pluriel, par exemple `materials/`.

Après publication dans une sauvegarde, un `item_id` ne se renomme plus. Le nom
affiché, la description et l'icône peuvent évoluer librement. Un futur renommage
technique exigera une table de migration explicite ; supprimer silencieusement
une définition rendrait les anciennes sauvegardes incomplètes.

## Procédure

1. créer ou dupliquer un `.tres` sous `game/content/items/definitions/` ;
2. attribuer un `item_id` inédit, une catégorie, une limite de pile et des tags ;
3. placer les sources artistiques et leur provenance sous
   `pipeline/assets/sources/items/` ;
4. exporter l'icône runtime sous `game/content/items/icons/` et la référencer
   depuis la définition ;
5. reconstruire le catalogue :

```bash
godot --headless --path . --script res://pipeline/assets/builders/build_item_catalog.gd
```

6. vérifier le catalogue :

```bash
godot --headless --path . --script res://pipeline/tests/verify_item_catalog.gd
```

`game/content/items/catalog.tres` est une sortie générée. Il ne faut jamais y
ajouter manuellement une définition.

## Objet placé dans Tiled

Une instance ramassable ajoute ces propriétés sur l'objet Tiled :

| Propriété | Rôle |
| --- | --- |
| `inventory_item_id` | `item_id` présent dans le catalogue |
| `inventory_quantity` | quantité strictement positive, `1` par défaut |
| `inventory_instance_id` | identité stable uniquement pour un objet unique |
| `persistent_id` | identité de l'instance dans sa carte |

Le convertisseur refuse un `inventory_item_id` inconnu et ajoute un composant
`InventoryPickup` à la scène générée. Il n'est donc pas nécessaire de dupliquer
la logique dans la carte ou dans l'objet physique.

## Icônes et visuels du monde

L'icône d'inventaire et le visuel au sol sont deux représentations du même type
d'objet, pas la même ressource obligatoire. L'icône privilégie la lisibilité à
petite taille ; le monde conserve son atlas, son ancre de pied et ses collisions.
La liaison est assurée par `item_id`.

Une source générée ou retouchée conserve son prompt et sa provenance. Seule
l'image finale optimisée entre dans `game/`. Les suffixes `v001`, `candidate`
et `source` restent dans le pipeline et n'apparaissent pas dans les chemins
runtime.
