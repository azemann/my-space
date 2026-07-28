import { appendFile, copyFile, mkdir, readFile } from "node:fs/promises";
import path from "node:path";
import readline from "node:readline/promises";

import { formatVersion, pathExists, readJson, resolveProject, writeFileAtomic } from "../project.js";
import { toYaml } from "../yaml.js";

const REQUIRED_STRINGS = [
  ["project", "name"],
  ["project", "type"],
  ["project", "audience"],
  ["project", "usage"],
  ["direction", "universe"],
  ["direction", "mood"],
  ["rendering", "technique"],
  ["rendering", "shapes"],
  ["rendering", "proportions"],
  ["rendering", "outlines"],
  ["rendering", "texture"],
  ["rendering", "lighting"],
  ["rendering", "detail"],
  ["rendering", "contrast"],
  ["rendering", "palette"],
  ["board", "background"]
];

export async function discussProject({
  projectPath,
  briefPath,
  accept = false,
  input = process.stdin,
  output = process.stdout,
  now = new Date()
} = {}) {
  const context = await resolveProject(projectPath);
  let brief;

  if (briefPath) {
    brief = JSON.parse(await readFile(path.resolve(briefPath), "utf8"));
  } else {
    brief = await guidedDiscussion(context.project, { input, output });
  }

  validateBrief(brief);
  if (brief.project.name !== context.project.name) {
    throw new Error(
      `Le brief concerne « ${brief.project.name} », mais le projet courant est « ${context.project.name} ».`
    );
  }

  if (!briefPath && !accept) {
    const terminal = readline.createInterface({ input, output });
    const confirmation = await terminal.question(
      "\nValider cette direction comme charte canonique ? [o/N] "
    );
    terminal.close();
    if (!/^o(?:ui)?$/iu.test(confirmation.trim())) {
      throw new Error("Discussion conservée sans modification de la charte.");
    }
  }

  const charterDirectory = path.join(context.workspace, "charter");
  const metadataPath = path.join(charterDirectory, "charter-meta.json");
  const previousMetadata = await readJson(metadataPath);
  const version = (previousMetadata?.version ?? 0) + 1;
  const timestamp = now.toISOString();

  if (previousMetadata) {
    await archiveCharter(charterDirectory, previousMetadata.version);
  }

  const metadata = {
    status: "canonical",
    version,
    project_id: context.project.id,
    created_at: previousMetadata?.created_at ?? timestamp,
    updated_at: timestamp
  };

  await Promise.all([
    writeFileAtomic(
      path.join(charterDirectory, "project-brief.json"),
      `${JSON.stringify(brief, null, 2)}\n`
    ),
    writeFileAtomic(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`),
    writeFileAtomic(
      path.join(charterDirectory, "charter.yaml"),
      `${toYaml({ ...metadata, brief })}\n`
    ),
    writeFileAtomic(
      path.join(charterDirectory, "charter.md"),
      renderCharterMarkdown(brief, metadata)
    ),
    writeFileAtomic(
      path.join(charterDirectory, "production-rules.yaml"),
      `${toYaml({
        status: "canonical",
        version,
        project_id: context.project.id,
        updated_at: timestamp,
        usage: brief.project.usage,
        platforms: [],
        asset_families: [
          "characters",
          "objects",
          "backgrounds",
          "effects",
          "interface",
          "icons"
        ],
        constraints: brief.negative.constraints
      })}\n`
    ),
    writeFileAtomic(
      path.join(charterDirectory, "decisions.yaml"),
      `${toYaml({
        decisions: [
          {
            id: `VIS-${String(version).padStart(3, "0")}`,
            status: "accepted",
            subject: "visual_direction",
            choice: `${brief.direction.universe} — ${brief.direction.mood}`,
            reason: "Direction explicitement validée pendant la découverte visuelle",
            alternatives: [],
            source_session: `visual-discovery-${formatVersion(version)}`,
            created_at: timestamp
          }
        ]
      })}\n`
    )
  ]);

  await appendConversation(context, brief, version, timestamp);
  return { context, brief, version };
}

export function validateBrief(brief) {
  if (!brief || typeof brief !== "object" || Array.isArray(brief)) {
    throw new Error("Le brief doit être un objet JSON.");
  }

  for (const [section, field] of REQUIRED_STRINGS) {
    if (typeof brief[section]?.[field] !== "string" || !brief[section][field].trim()) {
      throw new Error(`Champ obligatoire absent ou vide : ${section}.${field}`);
    }
  }

  for (const [section, field] of [
    ["direction", "keywords"],
    ["negative", "constraints"]
  ]) {
    const value = brief[section]?.[field];
    if (!Array.isArray(value) || value.some((item) => typeof item !== "string")) {
      throw new Error(`Le champ ${section}.${field} doit être une liste de textes.`);
    }
  }

  if (brief.direction.keywords.length === 0) {
    throw new Error("direction.keywords doit contenir au moins une valeur.");
  }
  if (typeof brief.board?.allow_project_name !== "boolean") {
    throw new Error("board.allow_project_name doit être un booléen.");
  }
}

async function guidedDiscussion(project, { input, output }) {
  const terminal = readline.createInterface({ input, output });
  const ask = async (question, fallback = "") => {
    const suffix = fallback ? ` [${fallback}]` : "";
    const answer = (await terminal.question(`${question}${suffix} : `)).trim();
    return answer || fallback;
  };
  const list = async (question) =>
    (await ask(question))
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);

  try {
    output.write(`\nDécouverte visuelle — ${project.name}\n\n`);
    const projectType = await ask(
      "Type de produit",
      project.type === "unspecified" ? "" : project.type
    );
    const audience = await ask("Public visé");
    const usage = await ask("Supports, tailles et contexte d’usage");
    const universe = await ask("Univers du projet");
    const mood = await ask("Ambiance recherchée");
    const keywords = await list("Mots-clés visuels, séparés par des virgules");
    const technique = await ask("Technique de rendu");
    const shapes = await ask("Langage de formes");
    const proportions = await ask("Proportions");
    const outlines = await ask("Contours");
    const texture = await ask("Textures et matières");
    const lighting = await ask("Éclairage");
    const detail = await ask("Niveau de détail");
    const contrast = await ask("Contraste");
    const palette = await ask("Palette");
    const background = await ask("Fond de la planche", "blanc cassé");
    const constraints = await list("Éléments interdits, séparés par des virgules");

    return {
      project: {
        name: project.name,
        type: projectType,
        audience,
        usage
      },
      direction: { universe, mood, keywords },
      rendering: {
        technique,
        shapes,
        proportions,
        outlines,
        texture,
        lighting,
        detail,
        contrast,
        palette
      },
      board: { background, allow_project_name: false },
      negative: { constraints }
    };
  } finally {
    terminal.close();
  }
}

async function archiveCharter(charterDirectory, version) {
  const archive = path.join(charterDirectory, "versions", `v${formatVersion(version)}`);
  await mkdir(archive, { recursive: true });
  for (const fileName of [
    "project-brief.json",
    "charter-meta.json",
    "charter.yaml",
    "charter.md",
    "production-rules.yaml",
    "decisions.yaml"
  ]) {
    const source = path.join(charterDirectory, fileName);
    if (await pathExists(source)) {
      await copyFile(source, path.join(archive, fileName));
    }
  }
}

async function appendConversation(context, brief, version, timestamp) {
  const sessionName = `visual-discovery-${formatVersion(version)}`;
  const session = `# Session ${sessionName}

- Date : ${timestamp}
- Statut : validée
- Univers : ${brief.direction.universe}
- Ambiance : ${brief.direction.mood}
- Mots-clés : ${brief.direction.keywords.join(", ")}
- Technique : ${brief.rendering.technique}
- Contraintes ouvertes : aucune
`;
  const sessionsDirectory = path.join(context.workspace, "conversation", "sessions");
  await mkdir(sessionsDirectory, { recursive: true });
  await writeFileAtomic(path.join(sessionsDirectory, `${sessionName}.md`), session);
  await appendFile(
    path.join(context.workspace, "conversation", "visual-discovery.md"),
    `\n\n${session}`,
    "utf8"
  );
}

function renderCharterMarkdown(brief, metadata) {
  return `# Charte graphique — ${brief.project.name}

Statut : canonique

Version : ${metadata.version}

## Intention

${brief.direction.universe}. ${brief.direction.mood}.

Mots-clés : ${brief.direction.keywords.join(", ")}.

## Public et usage

${brief.project.audience}. ${brief.project.usage}.

## Langage graphique

- Technique : ${brief.rendering.technique}
- Formes : ${brief.rendering.shapes}
- Proportions : ${brief.rendering.proportions}
- Contours : ${brief.rendering.outlines}
- Texture : ${brief.rendering.texture}
- Éclairage : ${brief.rendering.lighting}
- Détail : ${brief.rendering.detail}
- Contraste : ${brief.rendering.contrast}
- Palette : ${brief.rendering.palette}

## Interdits

${brief.negative.constraints.map((item) => `- ${item}`).join("\n") || "- Aucun"}
`;
}
