# Contrats repris

## Sources examinées

- `projets/fighter-sprites-2d/contracts/FIGHTER_SPRITESHEET_CONTRACT.md` ;
- `projets/fighter-sprites-2d/tools/sprite_pipeline/` ;
- `contrats/ANIMATION_CONTRACT_V1.md` ;
- `contrats/animation-v1.schema.json` ;
- `contrats/animation-integration-v1.schema.json` ;
- `contrats/asset-production-provenance-v1.schema.json` ;
- `contrats/asset-representation-v1.schema.json`.

## Conservé pour le RPG

- frames séparées et canvas fixe comme autorité ;
- origine entre les pieds et espace gameplay stable ;
- durées individuelles et ordre explicite ;
- atlas dérivé sans rotation ;
- recadrage conservant le root et son reçu ;
- statuts séparés visuel, temporel, technique et gameplay ;
- provenance de génération ;
- déplacement appartenant au moteur.

## Écarté du socle joueur

- phases d'attaque `startup`, `active`, `recovery` ;
- hitboxes, throwboxes et règles de cancel ;
- facing latéral canonique avec miroir automatique ;
- root motion de combat ;
- landmarks anatomiques détaillés pour chaque coup.

Ces éléments pourront revenir pour un système de combat, dans un contrat
séparé. Ils ne doivent pas alourdir l'exploration initiale.

