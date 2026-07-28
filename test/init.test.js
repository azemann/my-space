import assert from "node:assert/strict";
import { mkdtemp, mkdir, readFile, readdir, stat, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import sharp from "sharp";
import test from "node:test";

import { run } from "../src/cli.js";
import { approveIdentityBoard } from "../src/commands/identity-approve.js";
import { generateIdentityBoard } from "../src/commands/identity-generate.js";
import { getProjectStatus } from "../src/commands/status.js";

test("init crée un espace AssetForge complet dans le projet ciblé", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "KidiPlay");
  await mkdir(project);

  const { stdout } = await runCli([
    "init",
    project,
    "--id",
    "kidiplay",
    "--name",
    "KidiPlay",
    "--type",
    "children-app"
  ]);

  assert.match(stdout, /AssetForge initialisé/);
  assert.deepEqual(await topLevelEntries(path.join(project, ".assetforge")), [
    "approved",
    "catalog",
    "charter",
    "conversation",
    "generated",
    "project.yaml",
    "prompts",
    "references",
    "rejected",
    "reports",
    "status.yaml"
  ]);

  const manifest = await readFile(
    path.join(project, ".assetforge", "project.yaml"),
    "utf8"
  );
  assert.match(manifest, /id: "kidiplay"/);
  assert.match(manifest, /name: "KidiPlay"/);
  assert.match(manifest, /type: "children-app"/);
  assert.match(manifest, /version: "0\.1\.0"/);
});

test("init est idempotent et ne modifie pas un espace existant", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "existing-project");
  await mkdir(project);

  await runCli(["init", project]);
  const manifestPath = path.join(project, ".assetforge", "project.yaml");
  const before = await readFile(manifestPath, "utf8");
  const beforeDetails = await stat(manifestPath);

  const { stdout } = await runCli(["init", project, "--name", "Autre nom"]);
  const after = await readFile(manifestPath, "utf8");
  const afterDetails = await stat(manifestPath);

  assert.match(stdout, /déjà initialisé/);
  assert.equal(after, before);
  assert.equal(afterDetails.mtimeMs, beforeDetails.mtimeMs);
});

test("deux projets conservent des identités séparées", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const firstProject = path.join(temporaryRoot, "kidiplay");
  const secondProject = path.join(temporaryRoot, "flux-explorer");
  await Promise.all([mkdir(firstProject), mkdir(secondProject)]);

  await Promise.all([
    runCli(["init", firstProject, "--name", "KidiPlay"]),
    runCli(["init", secondProject, "--name", "Flux Explorer"])
  ]);

  const [firstManifest, secondManifest] = await Promise.all([
    readFile(path.join(firstProject, ".assetforge", "project.yaml"), "utf8"),
    readFile(path.join(secondProject, ".assetforge", "project.yaml"), "utf8")
  ]);

  assert.match(firstManifest, /id: "kidiplay"/);
  assert.doesNotMatch(firstManifest, /flux-explorer/);
  assert.match(secondManifest, /id: "flux-explorer"/);
  assert.doesNotMatch(secondManifest, /kidiplay/);
});

test("init refuse un dossier .assetforge étranger sans l’écraser", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "unsafe-project");
  const workspace = path.join(project, ".assetforge");
  await mkdir(workspace, { recursive: true });

  await assert.rejects(
    runCli(["init", project]),
    (error) => {
      assert.equal(error.code, 1);
      assert.match(error.stderr, /aucun fichier n’a été modifié/);
      return true;
    }
  );
});

test("le pipeline produit, génère et approuve une planche sans mélanger les projets", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "example-project");
  await mkdir(project);
  await runCli([
    "init",
    project,
    "--id",
    "example-project",
    "--name",
    "Example Project",
    "--type",
    "jeu 2D"
  ]);

  const briefPath = path.resolve("examples/project-brief.example.json");
  const discussion = await runCli([
    "discuss",
    "--project",
    project,
    "--brief",
    briefPath,
    "--yes"
  ]);
  assert.match(discussion.stdout, /Charte canonique v1/);

  const promptResult = await runCli(["identity", "prompt", "--project", project]);
  assert.match(promptResult.stdout, /Prompt d’identité v1/);
  const promptPath = path.join(
    project,
    ".assetforge",
    "prompts",
    "identity",
    "identity-board-v001.md"
  );
  const prompt = await readFile(promptPath, "utf8");
  assert.match(prompt, /Example Project/);
  assert.match(prompt, /organique, lisible, expressif, doux/);
  assert.doesNotMatch(prompt, /\{\{/);

  let request;
  const generation = await generateIdentityBoard({
    projectPath: project,
    apiKey: "test-key",
    fetchImpl: async (url, options) => {
      request = { url, options };
      return new Response(
        JSON.stringify({
          data: [{
            b64_json: Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
              .toString("base64")
          }],
          usage: { input_tokens: 10, output_tokens: 20 }
        }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }
  });
  assert.equal(request.url, "https://api.openai.com/v1/images/generations");
  assert.equal(request.options.headers.Authorization, "Bearer test-key");
  assert.deepEqual(
    {
      model: JSON.parse(request.options.body).model,
      size: JSON.parse(request.options.body).size,
      quality: JSON.parse(request.options.body).quality
    },
    { model: "gpt-image-2", size: "1536x1024", quality: "medium" }
  );
  assert.equal(generation.outputPaths.length, 1);

  await approveIdentityBoard({
    projectPath: project,
    imagePath: generation.outputPaths[0]
  });
  const status = await getProjectStatus({ projectPath: project });
  assert.equal(status.charter.status, "canonical");
  assert.equal(status.identity_prompt.status, "ready");
  assert.equal(status.identity_board.status, "canonical");
  assert.equal(status.style_profile.status, "ready");
  assert.equal(status.style_profile.id, "example-project-style-v1");
  assert.equal(status.production.status, "authorized");
});

test("une nouvelle discussion archive la charte précédente", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "versioned-project");
  await mkdir(project);
  await runCli([
    "init",
    project,
    "--name",
    "Example Project",
    "--type",
    "jeu 2D"
  ]);
  const briefPath = path.resolve("examples/project-brief.example.json");

  await runCli(["discuss", "--project", project, "--brief", briefPath, "--yes"]);
  await runCli(["discuss", "--project", project, "--brief", briefPath, "--yes"]);

  const metadata = JSON.parse(
    await readFile(
      path.join(project, ".assetforge", "charter", "charter-meta.json"),
      "utf8"
    )
  );
  assert.equal(metadata.version, 2);
  assert.ok(
    await stat(
      path.join(
        project,
        ".assetforge",
        "charter",
        "versions",
        "v001",
        "charter.yaml"
      )
    )
  );
});

test("la génération explique clairement l’absence de clé API", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "no-key-project");
  await mkdir(project);
  await runCli([
    "init",
    project,
    "--name",
    "Example Project",
    "--type",
    "jeu 2D"
  ]);
  const briefPath = path.resolve("examples/project-brief.example.json");
  await runCli(["discuss", "--project", project, "--brief", briefPath, "--yes"]);
  await runCli(["identity", "prompt", "--project", project]);

  await assert.rejects(
    generateIdentityBoard({ projectPath: project, apiKey: "" }),
    /OPENAI_API_KEY/
  );
});

test("generate transforme un PNG Codex en asset transparent normalisé", async (context) => {
  const temporaryRoot = await temporaryDirectory(context);
  const project = path.join(temporaryRoot, "static-assets");
  await mkdir(project);
  await runCli([
    "init",
    project,
    "--name",
    "Static Assets",
    "--type",
    "jeu 2D"
  ]);

  const brief = JSON.parse(
    await readFile(path.resolve("examples/project-brief.example.json"), "utf8")
  );
  await writeFile(
    path.join(project, ".assetforge", "charter", "style-profile.json"),
    `${JSON.stringify({
      id: "static-assets-style-v1",
      status: "active",
      version: 1,
      project_id: "static-assets",
      direction: brief.direction,
      rendering: brief.rendering,
      negative: brief.negative
    }, null, 2)}\n`
  );

  const inputPath = path.join(temporaryRoot, "codex-rock.png");
  const subject = Buffer.from(
    '<svg width="64" height="64"><rect width="64" height="64" rx="12" fill="#2456d8"/></svg>'
  );
  await sharp({
    create: {
      width: 128,
      height: 128,
      channels: 4,
      background: { r: 255, g: 0, b: 255, alpha: 1 }
    }
  })
    .composite([{ input: subject, left: 32, top: 32 }])
    .png()
    .toFile(inputPath);

  const result = await runCli([
    "generate",
    "environment",
    "rock_01",
    "--project",
    project,
    "--description",
    "rocher cartoon bleu vu de côté",
    "--size",
    "64",
    "--transparent",
    "--target",
    "phaser",
    "--input",
    inputPath
  ]);
  assert.match(result.stdout, /Asset généré et validé/);

  const assetDirectory = path.join(project, "assets", "environment", "rock_01");
  const outputPath = path.join(assetDirectory, "rock_01.png");
  const outputMetadata = await sharp(outputPath).metadata();
  const outputStats = await sharp(outputPath).stats();
  assert.equal(outputMetadata.width, 64);
  assert.equal(outputMetadata.height, 64);
  assert.equal(outputStats.isOpaque, false);

  const metadata = JSON.parse(
    await readFile(path.join(assetDirectory, "rock_01.json"), "utf8")
  );
  assert.equal(metadata.validation.passed, true);
  assert.equal(metadata.validation.transparency_valid, true);
  assert.equal(metadata.target_metadata.texture_key, "rock_01");
  assert.equal(metadata.provenance.provider, "manual_or_codex");
  assert.ok(metadata.validation.removed_background_pixels > 0);

  await Promise.all([
    stat(path.join(assetDirectory, "rock_01.preview.png")),
    stat(path.join(assetDirectory, "rock_01.preview.html")),
    stat(path.join(assetDirectory, "source-prompt.md"))
  ]);
  const catalog = JSON.parse(
    await readFile(path.join(project, ".assetforge", "catalog", "assets.json"), "utf8")
  );
  assert.equal(catalog.assets[0].path, "assets/environment/rock_01");
});

async function temporaryDirectory(context) {
  const directory = await mkdtemp(path.join(os.tmpdir(), "assetforge-test-"));
  context.after(async () => {
    const { rm } = await import("node:fs/promises");
    await rm(directory, { recursive: true, force: true });
  });
  return directory;
}

async function runCli(args) {
  const stdout = [];
  const stderr = [];
  const code = await run(args, {
    log: (message) => stdout.push(message),
    error: (message) => stderr.push(message)
  });
  const result = {
    stdout: stdout.join("\n"),
    stderr: stderr.join("\n")
  };

  if (code !== 0) {
    const error = new Error(result.stderr);
    Object.assign(error, result, { code });
    throw error;
  }

  return result;
}

async function topLevelEntries(directory) {
  return (await readdir(directory)).sort();
}
