import { Buffer } from "node:buffer";

export async function requestOpenAIImages({
  prompt,
  model = "gpt-image-2",
  size = "1024x1024",
  quality = "medium",
  count = 1,
  apiKey = process.env.OPENAI_API_KEY,
  baseUrl = process.env.OPENAI_BASE_URL ?? "https://api.openai.com/v1",
  fetchImpl = globalThis.fetch
} = {}) {
  if (!apiKey) {
    throw new Error(
      "OPENAI_API_KEY est requis pour générer une image. Utilisez --input pour traiter un PNG existant."
    );
  }
  validateImageOptions({ size, quality, count });

  const response = await fetchImpl(`${baseUrl.replace(/\/+$/u, "")}/images/generations`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model,
      prompt,
      n: count,
      size,
      quality,
      output_format: "png"
    })
  });

  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    throw new Error(
      `OpenAI Image API (${response.status}) : ${payload?.error?.message ?? "réponse invalide"}`
    );
  }
  if (!Array.isArray(payload?.data) || payload.data.length !== count) {
    throw new Error("La réponse du fournisseur ne contient pas le nombre d’images attendu.");
  }

  const images = payload.data.map((item, index) => {
    if (typeof item?.b64_json !== "string" || !item.b64_json) {
      throw new Error(`Image ${index + 1} absente de la réponse du fournisseur.`);
    }
    const image = Buffer.from(item.b64_json, "base64");
    if (!isPng(image)) {
      throw new Error(`Image ${index + 1} invalide : le fournisseur n’a pas renvoyé un PNG.`);
    }
    return image;
  });

  return {
    images,
    usage: payload.usage ?? null,
    requestId: response.headers.get("x-request-id")
  };
}

export function validateImageOptions({ size, quality, count }) {
  if (!isValidSize(size)) {
    throw new Error(
      `Taille de génération non supportée : ${size}. Les dimensions doivent être des multiples de 16, respecter un ratio maximal de 3:1 et contenir entre 655360 et 8294400 pixels.`
    );
  }
  if (!new Set(["low", "medium", "high", "auto"]).has(quality)) {
    throw new Error(`Qualité non supportée : ${quality}`);
  }
  if (!Number.isInteger(count) || count < 1 || count > 4) {
    throw new Error("Le nombre d’images doit être compris entre 1 et 4.");
  }
}

function isValidSize(size) {
  if (size === "auto") {
    return true;
  }
  const match = /^(\d+)x(\d+)$/u.exec(size);
  if (!match) {
    return false;
  }
  const width = Number(match[1]);
  const height = Number(match[2]);
  const pixels = width * height;
  return (
    width <= 3840 &&
    height <= 3840 &&
    width % 16 === 0 &&
    height % 16 === 0 &&
    Math.max(width, height) / Math.min(width, height) <= 3 &&
    pixels >= 655_360 &&
    pixels <= 8_294_400
  );
}

function isPng(content) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return content.length >= signature.length && content.subarray(0, 8).equals(signature);
}
