import { readdir } from "node:fs/promises";
import path from "node:path";

import { pathExists, readJson, resolveProject, writeFileAtomic } from "../project.js";
import { toYaml } from "../yaml.js";

export async function getProjectStatus({ projectPath, persist = false } = {}) {
  const context = await resolveProject(projectPath);
  const charterMetadata = await readJson(
    path.join(context.workspace, "charter", "charter-meta.json")
  );
  const promptFiles = await safeReadDirectory(
    path.join(context.workspace, "prompts", "identity")
  );
  const generatedFiles = await safeReadDirectory(
    path.join(context.workspace, "generated", "identity")
  );
  const approvedFiles = await safeReadDirectory(
    path.join(context.workspace, "approved", "identity")
  );
  const styleProfile = await readJson(
    path.join(context.workspace, "charter", "style-profile.json")
  );
  const catalog = await readJson(
    path.join(context.workspace, "catalog", "assets.json")
  );

  const prompts = promptFiles.filter((file) => /^identity-board-v\d{3}\.md$/.test(file));
  const generated = generatedFiles.filter((file) => /\.png$/i.test(file));
  const approved = approvedFiles.filter((file) => /\.png$/i.test(file));
  const hasConversation =
    (await safeReadDirectory(path.join(context.workspace, "conversation", "sessions")))
      .length > 0;

  const status = {
    project: {
      initialized: true,
      id: context.project.id,
      name: context.project.name
    },
    conversation: {
      status: charterMetadata ? "stabilized" : hasConversation ? "in_progress" : "not_started"
    },
    charter: {
      status: charterMetadata?.status ?? "absent",
      version: charterMetadata?.version ?? null
    },
    identity_prompt: {
      status: prompts.length ? "ready" : "absent",
      versions: prompts.length
    },
    identity_board: {
      status: approved.length
        ? "canonical"
        : generated.length
          ? "exploratory"
          : "absent",
      generated: generated.length,
      approved: approved.length
    },
    style_profile: {
      status: styleProfile?.status === "active" ? "ready" : "absent",
      active_version: styleProfile?.version ?? null,
      id: styleProfile?.id ?? null
    },
    assets: {
      generated: catalog?.assets?.length ?? 0
    },
    production: {
      status:
        approved.length &&
        charterMetadata?.status === "canonical" &&
        styleProfile?.status === "active"
        ? "authorized"
        : "blocked",
      reason:
        charterMetadata?.status !== "canonical"
          ? "canonical_charter_required"
          : !approved.length
            ? "canonical_identity_board_required"
            : styleProfile?.status !== "active"
              ? "active_style_profile_required"
              : null
    }
  };

  if (persist) {
    await writeFileAtomic(
      path.join(context.workspace, "status.yaml"),
      `${toYaml({ ...status, updated_at: new Date().toISOString() })}\n`
    );
  }
  return status;
}

export function formatStatus(status) {
  const value = (label, state, detail = "") =>
    `${label.padEnd(24)} ${state}${detail ? ` (${detail})` : ""}`;

  return [
    value("Projet", "initialisé", `${status.project.name} / ${status.project.id}`),
    value("Conversation", status.conversation.status),
    value(
      "Charte",
      status.charter.status,
      status.charter.version ? `v${status.charter.version}` : ""
    ),
    value("Prompt d’identité", status.identity_prompt.status),
    value(
      "Planche d’identité",
      status.identity_board.status,
      `${status.identity_board.generated} générée(s), ${status.identity_board.approved} approuvée(s)`
    ),
    value(
      "Profil visuel",
      status.style_profile.status,
      status.style_profile.id ?? ""
    ),
    value("Assets catalogués", String(status.assets.generated)),
    value(
      "Production d’assets",
      status.production.status,
      status.production.reason ?? ""
    )
  ].join("\n");
}

async function safeReadDirectory(directory) {
  if (!(await pathExists(directory))) {
    return [];
  }
  return readdir(directory);
}
