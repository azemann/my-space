import { randomUUID } from "node:crypto";
import { access, mkdir, readFile, rename, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ASSETFORGE_VERSION = "0.1.0";
const TEMPLATE_DIRECTORY = fileURLToPath(
  new URL("../../templates/project/", import.meta.url)
);

const DIRECTORIES = [
  "conversation/sessions",
  "charter",
  "references/imported",
  "references/canonical",
  "prompts/identity",
  "prompts/assets",
  "generated/identity",
  "generated/assets",
  "approved/identity",
  "approved/assets",
  "rejected",
  "catalog",
  "reports"
];

export async function initProject({
  projectPath = process.cwd(),
  projectId,
  projectName,
  projectType = "unspecified",
  now = new Date()
} = {}) {
  const root = path.resolve(projectPath);
  await assertDirectory(root);

  const workspacePath = path.join(root, ".assetforge");
  if (await pathExists(workspacePath)) {
    if (await pathExists(path.join(workspacePath, "project.yaml"))) {
      return {
        created: false,
        projectName: projectName ?? path.basename(root),
        workspacePath
      };
    }
    throw new Error(
      `${workspacePath} existe déjà mais ne contient pas de project.yaml ; aucun fichier n’a été modifié.`
    );
  }

  const resolvedName = normalizeValue(projectName ?? path.basename(root), "nom du projet");
  const resolvedId = projectId
    ? validateProjectId(projectId)
    : createProjectId(resolvedName);
  const resolvedType = normalizeValue(projectType, "type du projet");
  const timestamp = now.toISOString();
  const stagingPath = path.join(root, `.assetforge-init-${randomUUID()}`);

  try {
    await mkdir(stagingPath);
    await Promise.all(
      DIRECTORIES.map((directory) =>
        mkdir(path.join(stagingPath, directory), { recursive: true })
      )
    );

    const values = {
      assetforge_version: ASSETFORGE_VERSION,
      project_id: resolvedId,
      project_name: resolvedName,
      project_type: resolvedType,
      created_at: timestamp,
      updated_at: timestamp
    };

    await Promise.all([
      renderTemplate("project.yaml", path.join(stagingPath, "project.yaml"), values),
      renderTemplate("status.yaml", path.join(stagingPath, "status.yaml"), values),
      renderTemplate(
        "decisions.yaml",
        path.join(stagingPath, "charter", "decisions.yaml"),
        values
      ),
      renderTemplate(
        "visual-discovery.md",
        path.join(stagingPath, "conversation", "visual-discovery.md"),
        values
      ),
      renderTemplate(
        "charter.md",
        path.join(stagingPath, "charter", "charter.md"),
        values
      ),
      renderTemplate(
        "charter.yaml",
        path.join(stagingPath, "charter", "charter.yaml"),
        values
      ),
      renderTemplate(
        "production-rules.yaml",
        path.join(stagingPath, "charter", "production-rules.yaml"),
        values
      )
    ]);

    await rename(stagingPath, workspacePath);
  } catch (error) {
    await rm(stagingPath, { recursive: true, force: true });
    if (await pathExists(workspacePath)) {
      throw new Error(
        `${workspacePath} a été créé simultanément ; aucun fichier existant n’a été écrasé.`
      );
    }
    throw error;
  }

  return {
    created: true,
    projectId: resolvedId,
    projectName: resolvedName,
    workspacePath
  };
}

async function assertDirectory(directoryPath) {
  let details;
  try {
    details = await stat(directoryPath);
  } catch (error) {
    if (error.code === "ENOENT") {
      throw new Error(`Le projet n’existe pas : ${directoryPath}`);
    }
    throw error;
  }

  if (!details.isDirectory()) {
    throw new Error(`Le chemin du projet n’est pas un dossier : ${directoryPath}`);
  }
}

async function pathExists(targetPath) {
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

async function renderTemplate(templateName, destination, values) {
  const source = await readFile(path.join(TEMPLATE_DIRECTORY, templateName), "utf8");
  const rendered = source.replace(/\{\{([a-z_]+)\}\}/g, (token, key) => {
    if (!(key in values)) {
      throw new Error(`Variable de template inconnue : ${token}`);
    }
    return yamlString(values[key]);
  });

  if (rendered.includes("{{")) {
    throw new Error(`Le template ${templateName} contient une variable non résolue.`);
  }

  await writeFile(destination, rendered, { encoding: "utf8", flag: "wx" });
}

function yamlString(value) {
  return JSON.stringify(String(value));
}

function normalizeValue(value, label) {
  const normalized = String(value).trim();
  if (!normalized) {
    throw new Error(`Le ${label} ne peut pas être vide.`);
  }
  if (/[\u0000-\u001f]/u.test(normalized)) {
    throw new Error(`Le ${label} contient un caractère de contrôle.`);
  }
  return normalized;
}

function validateProjectId(value) {
  const normalized = normalizeValue(value, "project id");
  if (!/^[a-z0-9](?:[a-z0-9._-]{0,62}[a-z0-9])?$/u.test(normalized)) {
    throw new Error(
      "Le project id doit contenir 1 à 64 caractères parmi a-z, 0-9, point, tiret ou underscore."
    );
  }
  return normalized;
}

function createProjectId(name) {
  const id = name
    .normalize("NFKD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 64)
    .replace(/-+$/g, "");

  return validateProjectId(id || "project");
}
