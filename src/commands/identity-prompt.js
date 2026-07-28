import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  formatVersion,
  nextVersion,
  readJson,
  resolveProject,
  sha256,
  writeFileAtomic
} from "../project.js";
import { validateBrief } from "./discuss.js";

const TEMPLATE_PATH = fileURLToPath(
  new URL("../../prompts/identity-board.template.md", import.meta.url)
);

export async function createIdentityPrompt({ projectPath, now = new Date() } = {}) {
  const context = await resolveProject(projectPath);
  const briefPath = path.join(context.workspace, "charter", "project-brief.json");
  const brief = await readJson(briefPath);
  if (!brief) {
    throw new Error("Aucune charte structurée. Exécutez d’abord assetforge discuss.");
  }
  validateBrief(brief);

  const promptDirectory = path.join(context.workspace, "prompts", "identity");
  const files = await readdir(promptDirectory);
  const version = nextVersion(files, /^identity-board-v(\d{3})\.md$/);
  const template = await readFile(TEMPLATE_PATH, "utf8");
  const promptData = {
    ...brief,
    board: {
      ...brief.board,
      project_name_rule: brief.board.allow_project_name
        ? `Aucun texte généré, sauf le nom exact « ${brief.project.name} ».`
        : "Aucun texte généré, y compris le nom du projet."
    }
  };
  const body = renderTemplate(template, promptData);
  const hash = sha256(body);
  const outputPath = path.join(
    promptDirectory,
    `identity-board-v${formatVersion(version)}.md`
  );
  const metadataPath = path.join(
    promptDirectory,
    `identity-board-v${formatVersion(version)}.json`
  );
  await Promise.all([
    writeFileAtomic(outputPath, body),
    writeFileAtomic(
      metadataPath,
      `${JSON.stringify({
        version,
        created_at: now.toISOString(),
        source_charter_version:
          (await readJson(path.join(context.workspace, "charter", "charter-meta.json")))
            ?.version ?? null,
        sha256: hash
      }, null, 2)}\n`
    )
  ]);

  return { context, version, outputPath, metadataPath, hash };
}

function renderTemplate(template, data) {
  return template.replace(/\{\{([a-z_.]+)\}\}/g, (token, key) => {
    const value = key.split(".").reduce((current, segment) => current?.[segment], data);
    if (value === undefined || value === null) {
      throw new Error(`Valeur manquante pour le prompt : ${token}`);
    }
    if (Array.isArray(value)) {
      return key === "negative.constraints"
        ? value.map((item) => `- ${item}`).join("\n")
        : value.join(", ");
    }
    return String(value);
  });
}
