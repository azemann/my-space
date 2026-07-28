import { randomUUID } from "node:crypto";
import { mkdir, readFile, rename, rm, writeFile } from "node:fs/promises";
import path from "node:path";

import { createPreviewPng, processStaticAssetPng } from "../processing/png.js";
import { pathExists, readJson, resolveProject, sha256, writeFileAtomic } from "../project.js";
import { requestOpenAIImages } from "../providers/openai-images.js";

const SAFE_ID = /^[a-z0-9](?:[a-z0-9_-]{0,62}[a-z0-9])?$/u;
const SAFE_TYPE = /^[a-z0-9](?:[a-z0-9_-]{0,30}[a-z0-9])?$/u;
const TARGETS = new Set(["generic", "phaser", "pixijs", "godot", "unity"]);

export async function generateStaticAsset({
  projectPath,
  type,
  name,
  description,
  size = "256",
  transparent = false,
  target = "generic",
  inputPath,
  model = "gpt-image-2",
  quality = "medium",
  apiKey = process.env.OPENAI_API_KEY,
  baseUrl = process.env.OPENAI_BASE_URL ?? "https://api.openai.com/v1",
  fetchImpl = globalThis.fetch,
  now = new Date()
} = {}) {
  validateAssetIdentity({ type, name, description, target });
  const dimensions = parseAssetSize(size);
  const context = await resolveProject(projectPath);
  const styleProfile = await readJson(
    path.join(context.workspace, "charter", "style-profile.json")
  );
  if (styleProfile?.status !== "active") {
    throw new Error(
      "Un profil visuel actif est requis. Générez puis approuvez d’abord une planche d’identité."
    );
  }

  const prompt = buildAssetPrompt({
    type,
    name,
    description,
    transparent,
    dimensions,
    target,
    styleProfile
  });
  let source;
  let provenance;

  if (inputPath) {
    const resolvedInput = path.resolve(inputPath);
    source = await readFile(resolvedInput);
    provenance = {
      provider: "manual_or_codex",
      input_path: resolvedInput,
      model: null,
      request_id: null,
      usage: null
    };
  } else {
    const generated = await requestOpenAIImages({
      prompt,
      model,
      size: generationSize(dimensions),
      quality,
      count: 1,
      apiKey,
      baseUrl,
      fetchImpl
    });
    source = generated.images[0];
    provenance = {
      provider: "openai",
      input_path: null,
      model,
      request_id: generated.requestId,
      usage: generated.usage
    };
  }

  const processed = await processStaticAssetPng(source, {
    ...dimensions,
    transparent
  });
  if (!processed.report.transparency_valid) {
    throw new Error(
      "La transparence demandée n’a pas pu être validée ; aucun asset final n’a été publié."
    );
  }

  const assetRoot = path.join(context.root, "assets", type);
  const destination = path.join(assetRoot, name);
  if (await pathExists(destination)) {
    throw new Error(`L’asset existe déjà : ${destination}`);
  }
  await mkdir(assetRoot, { recursive: true });
  const staging = path.join(assetRoot, `.${name}.tmp-${randomUUID()}`);
  await mkdir(staging);

  const timestamp = now.toISOString();
  const pivot = defaultPivot(type);
  const metadata = {
    schema_version: "0.1",
    id: name,
    type,
    description,
    status: "generated",
    width: dimensions.width,
    height: dimensions.height,
    format: "png",
    background: transparent ? "transparent" : "opaque",
    pivot,
    collision: {
      type: type === "ui" || type === "icon" ? "none" : "bounding_box",
      automatic: type !== "ui" && type !== "icon"
    },
    target,
    target_metadata: targetMetadata(target, name, pivot),
    style_profile: styleProfile.id,
    created_at: timestamp,
    prompt_sha256: sha256(prompt),
    source_sha256: sha256(source),
    output_sha256: sha256(processed.buffer),
    provenance,
    validation: {
      passed: true,
      ...processed.report
    },
    tags: uniqueTags([type, target, ...description.toLowerCase().split(/\W+/u)])
  };
  const preview = await createPreviewPng(processed.buffer, dimensions);

  try {
    await Promise.all([
      writeFile(path.join(staging, `${name}.png`), processed.buffer, { flag: "wx" }),
      writeFile(path.join(staging, `${name}.preview.png`), preview, { flag: "wx" }),
      writeFile(
        path.join(staging, `${name}.json`),
        `${JSON.stringify(metadata, null, 2)}\n`,
        { encoding: "utf8", flag: "wx" }
      ),
      writeFile(path.join(staging, "source-prompt.md"), `${prompt}\n`, {
        encoding: "utf8",
        flag: "wx"
      }),
      writeFile(
        path.join(staging, `${name}.preview.html`),
        renderPreviewHtml(name, metadata),
        { encoding: "utf8", flag: "wx" }
      )
    ]);
    await rename(staging, destination);
  } catch (error) {
    await rm(staging, { recursive: true, force: true });
    throw error;
  }

  await updateCatalog(context, metadata, destination);
  return { context, destination, metadata };
}

export function parseAssetSize(value) {
  const match = /^(\d+)(?:x(\d+))?$/u.exec(String(value));
  if (!match) {
    throw new Error("La taille doit être un entier ou WIDTHxHEIGHT.");
  }
  const width = Number(match[1]);
  const height = Number(match[2] ?? match[1]);
  if (
    !Number.isInteger(width) ||
    !Number.isInteger(height) ||
    width < 16 ||
    height < 16 ||
    width > 4096 ||
    height > 4096
  ) {
    throw new Error("Chaque dimension finale doit être comprise entre 16 et 4096 pixels.");
  }
  return { width, height };
}

function validateAssetIdentity({ type, name, description, target }) {
  if (!SAFE_TYPE.test(type ?? "")) {
    throw new Error("Le type doit être un identifiant sûr en minuscules.");
  }
  if (!SAFE_ID.test(name ?? "")) {
    throw new Error("Le nom doit être un identifiant sûr en minuscules.");
  }
  if (typeof description !== "string" || !description.trim()) {
    throw new Error("Une description est requise.");
  }
  if (!TARGETS.has(target)) {
    throw new Error(`Moteur cible non supporté : ${target}`);
  }
}

function buildAssetPrompt({
  type,
  name,
  description,
  transparent,
  dimensions,
  target,
  styleProfile
}) {
  return `# AssetForge — asset statique

Créer un seul asset 2D isolé.

Asset : ${name}
Catégorie : ${type}
Description : ${description}
Usage final : ${dimensions.width} × ${dimensions.height} px dans ${target}

Direction artistique canonique :
- Univers : ${styleProfile.direction.universe}
- Ambiance : ${styleProfile.direction.mood}
- Mots-clés : ${styleProfile.direction.keywords.join(", ")}
- Technique : ${styleProfile.rendering.technique}
- Formes : ${styleProfile.rendering.shapes}
- Proportions : ${styleProfile.rendering.proportions}
- Contours : ${styleProfile.rendering.outlines}
- Texture : ${styleProfile.rendering.texture}
- Éclairage : ${styleProfile.rendering.lighting}
- Détail : ${styleProfile.rendering.detail}
- Contraste : ${styleProfile.rendering.contrast}
- Palette : ${styleProfile.rendering.palette}

Contraintes techniques :
- un seul objet, entièrement visible, centré et sans contact avec les bords ;
- vue adaptée à un jeu 2D et silhouette immédiatement lisible ;
- aucune légende, aucun texte, aucun filigrane, aucun cadre ;
- pas de décor, pas de scène, pas d’objet secondaire ;
${transparent
    ? "- fond parfaitement uniforme de couleur magenta pure #FF00FF, sans ombre portée sur le fond ; ce fond sera supprimé techniquement après génération ;"
    : "- fond simple et discret ;"}
- respecter strictement la direction artistique fournie ;
- éviter : ${styleProfile.negative.constraints.join(", ")}.
`;
}

function generationSize({ width, height }) {
  if (width === height) {
    return "1024x1024";
  }
  return width > height ? "1536x1024" : "1024x1536";
}

function defaultPivot(type) {
  return type === "environment" || type === "character"
    ? { x: 0.5, y: 1 }
    : { x: 0.5, y: 0.5 };
}

function targetMetadata(target, name, pivot) {
  switch (target) {
    case "phaser":
      return { texture_key: name, origin: pivot };
    case "pixijs":
      return { texture_id: name, anchor: pivot };
    case "godot":
      return { resource_name: name, centered: pivot.x === 0.5 && pivot.y === 0.5 };
    case "unity":
      return { sprite_name: name, pivot, pixels_per_unit: 100 };
    default:
      return {};
  }
}

function uniqueTags(values) {
  return [...new Set(values.filter((value) => value && value.length >= 3))].slice(0, 20);
}

async function updateCatalog(context, metadata, destination) {
  const catalogPath = path.join(context.workspace, "catalog", "assets.json");
  const catalog = (await readJson(catalogPath)) ?? {
    schema_version: "0.1",
    assets: []
  };
  catalog.assets.push({
    id: metadata.id,
    type: metadata.type,
    status: metadata.status,
    path: path.relative(context.root, destination),
    target: metadata.target,
    output_sha256: metadata.output_sha256,
    created_at: metadata.created_at
  });
  await writeFileAtomic(catalogPath, `${JSON.stringify(catalog, null, 2)}\n`);
}

function renderPreviewHtml(name, metadata) {
  const escapedMetadata = JSON.stringify(metadata, null, 2)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
  return `<!doctype html>
<html lang="fr">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Aperçu — ${name}</title>
<style>
  body{font:16px system-ui;margin:2rem;background:#17191d;color:#f7f7f7}
  main{display:grid;grid-template-columns:minmax(280px,1fr) minmax(320px,1fr);gap:2rem}
  figure{margin:0;display:grid;place-items:center;min-height:420px;border-radius:16px;
    background-color:#eee;background-image:linear-gradient(45deg,#ccc 25%,transparent 25%),
    linear-gradient(-45deg,#ccc 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#ccc 75%),
    linear-gradient(-45deg,transparent 75%,#ccc 75%);background-size:32px 32px;
    background-position:0 0,0 16px,16px -16px,-16px 0}
  img{image-rendering:auto;max-width:90%;max-height:70vh}
  pre{white-space:pre-wrap;overflow-wrap:anywhere;background:#24272d;padding:1rem;border-radius:12px}
  @media(max-width:760px){main{grid-template-columns:1fr}}
</style>
<main>
  <figure><img src="${name}.png" alt="Asset ${name}"></figure>
  <section><h1>${name}</h1><pre>${escapedMetadata}</pre></section>
</main>
</html>
`;
}
