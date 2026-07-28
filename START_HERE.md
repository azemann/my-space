# Démarrage AssetForge

## 1. Décrire le projet

Copier :

```text
examples/project-brief.example.json
```

vers :

```text
workspace/project-brief.json
```

Puis remplacer les valeurs d’exemple par le contexte réel du projet.

## 2. Générer le prompt de planche

Le futur CLI lira le brief et remplira :

```text
prompts/identity-board.template.md
```

La première commande visée est :

```bash
assetforge identity prompt workspace/project-brief.json
```

Sortie attendue :

```text
workspace/identity/prompts/identity-board-v001.md
```

## 3. Produire plusieurs explorations

Créer 2 à 4 planches exploratoires. Elles ne sont pas encore canoniques.

```text
workspace/identity/explorations/
├── board-a.png
├── board-b.png
└── board-c.png
```

## 4. Valider une direction

La validation humaine sélectionne une planche ou demande une synthèse. La référence retenue est copiée dans :

```text
workspace/identity/canonical/
```

## 5. Extraire le profil visuel

Décrire ensuite explicitement les constantes observables : palette, formes, contours, texture, lumière, niveau de détail et interdits.

Sortie future :

```text
workspace/identity/style-profile.json
```

## 6. Produire les assets

Les assets ne seront générés qu’après validation du profil canonique.

## Ordre de construction du logiciel

1. CLI de génération de prompt.
2. Validation du brief par JSON Schema.
3. Versionnement des planches et prompts.
4. Profil visuel canonique.
5. Spécification générique d’asset.
6. Import manuel d’image.
7. Traitement PNG/WebP.
8. Validation technique.
9. Adaptateur de génération OpenAI/Codex.
10. Exporteurs moteurs.
