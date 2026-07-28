import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";

import {
  formatVersion,
  nextVersion,
  resolveProject,
  sha256,
  writeFileAtomic
} from "../project.js";
import { requestOpenAIImages } from "../providers/openai-images.js";

const DEFAULT_MODEL = "gpt-image-2";

export async function generateIdentityBoard({
  projectPath,
  promptPath,
  model = DEFAULT_MODEL,
  size = "1536x1024",
  quality = "medium",
  count = 1,
  apiKey = process.env.OPENAI_API_KEY,
  baseUrl = process.env.OPENAI_BASE_URL ?? "https://api.openai.com/v1",
  fetchImpl = globalThis.fetch,
  now = new Date()
} = {}) {
  const context = await resolveProject(projectPath);
  const resolvedPromptPath = promptPath
    ? path.resolve(promptPath)
    : await latestPrompt(context.workspace);
  const prompt = await readFile(resolvedPromptPath, "utf8");
  const outputDirectory = path.join(context.workspace, "generated", "identity");
  await mkdir(outputDirectory, { recursive: true });
  const existingFiles = await readdir(outputDirectory);
  const batch = nextVersion(existingFiles, /^board-b(\d{3})-\d{2}\.png$/);

  const generated = await requestOpenAIImages({
    prompt,
    model,
    size,
    quality,
    count,
    apiKey,
    baseUrl,
    fetchImpl
  });

  const outputPaths = [];
  for (let index = 0; index < generated.images.length; index += 1) {
    const image = generated.images[index];
    const outputPath = path.join(
      outputDirectory,
      `board-b${formatVersion(batch)}-${String(index + 1).padStart(2, "0")}.png`
    );
    await writeFile(outputPath, image, { flag: "wx" });
    outputPaths.push(outputPath);
  }

  const metadata = {
    batch,
    created_at: now.toISOString(),
    provider: "openai",
    model,
    size,
    quality,
    count,
    prompt_path: path.relative(context.workspace, resolvedPromptPath),
    prompt_sha256: sha256(prompt),
    outputs: outputPaths.map((filePath) => path.relative(context.workspace, filePath)),
    request_id: generated.requestId,
    usage: generated.usage
  };
  await writeFileAtomic(
    path.join(outputDirectory, `board-b${formatVersion(batch)}.json`),
    `${JSON.stringify(metadata, null, 2)}\n`
  );

  return { context, outputPaths, metadata };
}

async function latestPrompt(workspace) {
  const directory = path.join(workspace, "prompts", "identity");
  const files = (await readdir(directory))
    .filter((file) => /^identity-board-v\d{3}\.md$/.test(file))
    .sort();
  if (files.length === 0) {
    throw new Error(
      "Aucun prompt d’identité. Exécutez d’abord assetforge identity prompt."
    );
  }
  return path.join(directory, files.at(-1));
}
