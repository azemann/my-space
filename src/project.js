import { createHash } from "node:crypto";
import { access, readFile, rename, writeFile } from "node:fs/promises";
import path from "node:path";

export async function resolveProject(projectPath = process.cwd()) {
  const root = path.resolve(projectPath);
  const workspace = path.join(root, ".assetforge");
  const manifestPath = path.join(workspace, "project.yaml");

  if (!(await pathExists(manifestPath))) {
    throw new Error(
      `Aucun projet AssetForge trouvé dans ${root}. Exécutez d’abord assetforge init.`
    );
  }

  const manifest = await readFile(manifestPath, "utf8");
  return {
    root,
    workspace,
    project: {
      id: yamlField(manifest, "id"),
      name: yamlField(manifest, "name"),
      type: yamlField(manifest, "type")
    }
  };
}

export async function pathExists(targetPath) {
  try {
    await access(targetPath);
    return true;
  } catch (error) {
    if (error.code === "ENOENT") {
      return false;
    }
    throw error;
  }
}

export async function readJson(filePath) {
  try {
    return JSON.parse(await readFile(filePath, "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") {
      return null;
    }
    if (error instanceof SyntaxError) {
      throw new Error(`JSON invalide : ${filePath}`);
    }
    throw error;
  }
}

export async function writeFileAtomic(filePath, content) {
  const temporaryPath = `${filePath}.tmp-${process.pid}-${Date.now()}`;
  await writeFile(temporaryPath, content, { encoding: "utf8", flag: "wx" });
  try {
    await rename(temporaryPath, filePath);
  } catch (error) {
    const { rm } = await import("node:fs/promises");
    await rm(temporaryPath, { force: true });
    throw error;
  }
}

export function sha256(content) {
  return createHash("sha256").update(content).digest("hex");
}

export function nextVersion(fileNames, pattern) {
  let highest = 0;
  for (const fileName of fileNames) {
    const match = fileName.match(pattern);
    if (match) {
      highest = Math.max(highest, Number(match[1]));
    }
  }
  return highest + 1;
}

export function formatVersion(version) {
  return String(version).padStart(3, "0");
}

function yamlField(content, field) {
  const match = content.match(new RegExp(`^\\s*${field}:\\s*(.+?)\\s*$`, "m"));
  if (!match) {
    throw new Error(`Champ ${field} absent du manifeste du projet.`);
  }

  const raw = match[1];
  try {
    return JSON.parse(raw);
  } catch {
    return raw.replace(/^['"]|['"]$/g, "");
  }
}
