# Prompt — Planche d’identité visuelle

Créer une planche professionnelle d’identité visuelle pour le projet « {{project.name}} », un {{project.type}} destiné à {{project.audience}}.

## Rôle de la planche

Cette planche n’est pas une simple image d’inspiration. Elle doit devenir la référence canonique utilisée pour produire les futurs personnages, objets, décors, icônes, interfaces et variantes du projet.

Elle doit rendre immédiatement observables et comparables :

- le langage de formes ;
- les proportions ;
- la palette ;
- les contours ;
- les textures ;
- l’éclairage ;
- le niveau de détail ;
- la lisibilité à petite taille ;
- les éléments interdits.

## Intention du projet

Univers : {{direction.universe}}

Ambiance : {{direction.mood}}

Mots-clés : {{direction.keywords}}

Public et contexte d’usage : {{project.usage}}

## Langage graphique

Technique de rendu : {{rendering.technique}}

Formes dominantes : {{rendering.shapes}}

Proportions : {{rendering.proportions}}

Contours : {{rendering.outlines}}

Textures et matières : {{rendering.texture}}

Éclairage : {{rendering.lighting}}

Niveau de détail : {{rendering.detail}}

Contraste : {{rendering.contrast}}

Palette souhaitée : {{rendering.palette}}

## Composition obligatoire

Organiser une seule grande planche claire en zones visuelles distinctes et bien espacées.

Présenter :

1. Une palette principale de 6 à 10 couleurs sous forme d’échantillons sans texte parasite.
2. Un ensemble de formes fondamentales illustrant les coins, courbes, angles, épaisseurs et proportions caractéristiques.
3. Un sujet principal cohérent présenté de face, de profil, en trois quarts et dans une pose neutre.
4. Trois expressions clairement différentes du même sujet sans modifier son identité, ses proportions ou ses vêtements.
5. Une famille de 4 à 6 objets représentatifs de l’univers.
6. Trois icônes simples permettant de vérifier la lisibilité du style à petite taille.
7. Un bouton principal, un bouton secondaire et une carte d’interface.
8. Un élément de premier plan et un élément d’arrière-plan.
9. Un petit exemple de scène réunissant plusieurs éléments sans introduire de nouveau style.

## Cohérence stricte

Tous les éléments doivent sembler produits par la même direction artistique.

Conserver exactement :

- le même langage de formes ;
- les mêmes proportions ;
- la même palette ;
- la même logique de contours ;
- la même texture ;
- la même lumière ;
- le même niveau de simplification ;
- la même densité de détails.

## Contraintes de production

- Aucun élément coupé par les bords.
- Aucun élément ne touche le bord de la planche.
- Aucun chevauchement empêchant l’isolation d’un asset.
- Fond {{board.background}} uniforme et discret.
- Aucun mockup de téléphone, tablette ou ordinateur.
- Aucun cadre décoratif inutile.
- Aucun filigrane.
- Aucun logo parasite.
- {{board.project_name_rule}}
- Silhouettes lisibles à petite taille.
- Vues et expressions clairement séparées.
- Pas de changement de personnage entre les différentes vues.
- Pas de changement de palette entre les zones.
- Pas de mélange 2D/3D non demandé.
- Pas d’arrière-plan narratif complexe.

## Éléments explicitement interdits

{{negative.constraints}}

## Résultat attendu

Une vraie feuille de direction artistique exploitable par une équipe de production et par un pipeline logiciel. La planche doit permettre de dériver ensuite un profil visuel structuré et des prompts spécialisés sans réinterpréter le style à chaque génération.
