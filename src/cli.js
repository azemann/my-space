import { approveIdentityBoard } from "./commands/identity-approve.js";
import { generateIdentityBoard } from "./commands/identity-generate.js";
import { createIdentityPrompt } from "./commands/identity-prompt.js";
import { discussProject } from "./commands/discuss.js";
import { generateStaticAsset } from "./commands/generate-asset.js";
import { initProject } from "./commands/init.js";
import { formatStatus, getProjectStatus } from "./commands/status.js";

const VERSION = "0.1.0";

const HELP = `AssetForge ${VERSION}

Usage:
  assetforge init [path] [--id <id>] [--name <name>] [--type <type>]
  assetforge discuss [--project <path>] [--brief <brief.json>] [--yes]
  assetforge status [--project <path>] [--json]
  assetforge identity prompt [--project <path>]
  assetforge identity generate [--project <path>] [--model <model>]
                               [--size <size>] [--quality <quality>] [--count <n>]
  assetforge identity approve <image> [--project <path>]
  assetforge generate <type> <name> --description <text> [--size <px|WxH>]
                      [--transparent] [--target <engine>] [--input <png>]
  assetforge validate <image> [--project <path>]

Commands:
  init                Initialise la mémoire artistique locale du projet
  discuss             Conduit la découverte visuelle et produit la charte
  status              Calcule l’état réel du pipeline
  identity prompt     Produit un prompt de planche versionné
  identity generate   Génère une ou plusieurs planches avec OpenAI
  identity approve    Valide une planche comme référence canonique
  generate            Produit et normalise un asset statique exploitable
  validate            Alias de identity approve
`;

export async function run(args, io = console) {
  if (args.length === 0 || args.includes("--help") || args.includes("-h")) {
    io.log(HELP);
    return 0;
  }

  if (args.includes("--version") || args.includes("-v")) {
    io.log(VERSION);
    return 0;
  }

  try {
    const [command, ...commandArgs] = args;
    switch (command) {
      case "init":
        return await runInit(commandArgs, io);
      case "discuss":
        return await runDiscuss(commandArgs, io);
      case "status":
        return await runStatus(commandArgs, io);
      case "identity":
        return await runIdentity(commandArgs, io);
      case "generate":
        return await runGenerate(commandArgs, io);
      case "validate":
        return await runApprove(commandArgs, io);
      default:
        io.error(`Commande inconnue : ${command}\n\n${HELP}`);
        return 2;
    }
  } catch (error) {
    io.error(`Erreur : ${error.message}`);
    return 1;
  }
}

async function runInit(args, io) {
  const parsed = parseArgs(args, {
    values: { "--id": "projectId", "--name": "projectName", "--type": "projectType" },
    maxPositionals: 1
  });
  const result = await initProject({
    ...parsed.options,
    projectPath: parsed.positionals[0] ?? process.cwd()
  });

  io.log(
    result.created
      ? `AssetForge initialisé pour « ${result.projectName} » dans ${result.workspacePath}`
      : `AssetForge est déjà initialisé dans ${result.workspacePath}`
  );
  return 0;
}

async function runDiscuss(args, io) {
  const parsed = parseArgs(args, {
    values: { "--project": "projectPath", "--brief": "briefPath" },
    booleans: { "--yes": "accept" }
  });
  const result = await discussProject(parsed.options);
  io.log(
    `Charte canonique v${result.version} créée pour « ${result.context.project.name} ».`
  );
  return 0;
}

async function runStatus(args, io) {
  const parsed = parseArgs(args, {
    values: { "--project": "projectPath" },
    booleans: { "--json": "json" }
  });
  const status = await getProjectStatus({ ...parsed.options, persist: true });
  io.log(parsed.options.json ? JSON.stringify(status, null, 2) : formatStatus(status));
  return 0;
}

async function runIdentity(args, io) {
  const [subcommand, ...subcommandArgs] = args;
  if (subcommand === "prompt") {
    const parsed = parseArgs(subcommandArgs, {
      values: { "--project": "projectPath" }
    });
    const result = await createIdentityPrompt(parsed.options);
    io.log(`Prompt d’identité v${result.version} créé : ${result.outputPath}`);
    return 0;
  }
  if (subcommand === "generate") {
    const parsed = parseArgs(subcommandArgs, {
      values: {
        "--project": "projectPath",
        "--prompt": "promptPath",
        "--model": "model",
        "--size": "size",
        "--quality": "quality",
        "--count": "count"
      }
    });
    if (parsed.options.count !== undefined) {
      parsed.options.count = Number(parsed.options.count);
    }
    const result = await generateIdentityBoard(parsed.options);
    io.log(`Planche(s) générée(s) :\n${result.outputPaths.join("\n")}`);
    return 0;
  }
  if (subcommand === "approve") {
    return runApprove(subcommandArgs, io);
  }

  throw new Error(`Sous-commande identity inconnue : ${subcommand ?? "(absente)"}`);
}

async function runApprove(args, io) {
  const parsed = parseArgs(args, {
    values: { "--project": "projectPath" },
    maxPositionals: 1,
    minPositionals: 1
  });
  const result = await approveIdentityBoard({
    ...parsed.options,
    imagePath: parsed.positionals[0]
  });
  io.log(`Planche canonique approuvée : ${result.destination}`);
  return 0;
}

async function runGenerate(args, io) {
  const parsed = parseArgs(args, {
    values: {
      "--project": "projectPath",
      "--description": "description",
      "--size": "size",
      "--target": "target",
      "--input": "inputPath",
      "--model": "model",
      "--quality": "quality"
    },
    booleans: { "--transparent": "transparent" },
    minPositionals: 2,
    maxPositionals: 2
  });
  const [type, name] = parsed.positionals;
  const result = await generateStaticAsset({
    ...parsed.options,
    type,
    name
  });
  io.log(`Asset généré et validé : ${result.destination}`);
  return 0;
}

function parseArgs(
  args,
  { values = {}, booleans = {}, maxPositionals = 0, minPositionals = 0 } = {}
) {
  const options = {};
  const positionals = [];

  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument in values) {
      const value = args[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`La valeur de ${argument} est manquante.`);
      }
      options[values[argument]] = value;
      index += 1;
      continue;
    }
    if (argument in booleans) {
      options[booleans[argument]] = true;
      continue;
    }
    if (argument.startsWith("-")) {
      throw new Error(`Option inconnue : ${argument}`);
    }
    positionals.push(argument);
  }

  if (positionals.length > maxPositionals) {
    throw new Error("Trop d’arguments positionnels.");
  }
  if (positionals.length < minPositionals) {
    throw new Error("Un argument obligatoire est manquant.");
  }
  return { options, positionals };
}
