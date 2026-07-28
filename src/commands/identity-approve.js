import { copyFile, mkdir, readFile } from "node:fs/promises";
import path from "node:path";

import {
  pathExists,
  readJson,
  resolveProject,
  sha256,
  writeFileAtomic
} from "../project.js";
import { toYaml } from "../yaml.js";

export async function approveIdentityBoard({
  projectPath,
  imagePath,
  now = new Date()
} = {}) {
  if (!imagePath) {
    throw new Error("Le chemin de la planche à approuver est requis.");
  }

  const context = await resolveProject(projectPath);
  const generatedDirectory = path.join(context.workspace, "generated", "identity");
  const source = path.isAbsolute(imagePath)
    ? path.resolve(imagePath)
    : path.resolve(generatedDirectory, imagePath);
  const relative = path.relative(generatedDirectory, source);
  if (relative.startsWith("..") || path.isAbsolute(relative)) {
    throw new Error("Seule une planche générée dans ce projet peut être approuvée.");
  }
  if (!(await pathExists(source))) {
    throw new Error(`Planche introuvable : ${source}`);
  }
  if (path.extname(source).toLowerCase() !== ".png") {
    throw new Error("La planche à approuver doit être un fichier PNG.");
  }

  const approvedDirectory = path.join(context.workspace, "approved", "identity");
  await mkdir(approvedDirectory, { recursive: true });
  const destination = path.join(approvedDirectory, path.basename(source));
  if (!(await pathExists(destination))) {
    await copyFile(source, destination);
  }
  const content = await readFile(destination);
  const brief = await readJson(
    path.join(context.workspace, "charter", "project-brief.json")
  );
  const charterMetadata = await readJson(
    path.join(context.workspace, "charter", "charter-meta.json")
  );
  if (!brief || !charterMetadata) {
    throw new Error("La charte canonique est requise avant l’approbation.");
  }
  const boardHash = sha256(content);
  const styleProfile = {
    id: `${context.project.id}-style-v${charterMetadata.version}`,
    status: "active",
    version: charterMetadata.version,
    project_id: context.project.id,
    created_at: now.toISOString(),
    canonical_board: {
      path: path.relative(context.workspace, destination),
      sha256: boardHash
    },
    direction: brief.direction,
    rendering: brief.rendering,
    negative: brief.negative
  };
  await writeFileAtomic(
    `${destination}.approval.json`,
    `${JSON.stringify({
      status: "canonical",
      approved_at: now.toISOString(),
      source: path.relative(context.workspace, source),
      sha256: boardHash
    }, null, 2)}\n`
  );
  await Promise.all([
    writeFileAtomic(
      path.join(context.workspace, "charter", "style-profile.json"),
      `${JSON.stringify(styleProfile, null, 2)}\n`
    ),
    writeFileAtomic(
      path.join(context.workspace, "charter", "style-profile.yaml"),
      `${toYaml(styleProfile)}\n`
    )
  ]);

  return { context, destination, styleProfile };
}
