import sharp from "sharp";

export async function processStaticAssetPng(
  source,
  {
    width,
    height,
    transparent = false,
    paddingRatio = 0.08,
    backgroundTolerance = 105
  }
) {
  let working = source;
  let removedBackgroundPixels = 0;

  const sourceStats = await sharp(source).stats();
  if (transparent && sourceStats.isOpaque) {
    const result = await removeConnectedBackground(source, {
      tolerance: backgroundTolerance
    });
    working = result.buffer;
    removedBackgroundPixels = result.removedPixels;
  }

  const trimmed = await sharp(working)
    .trim({
      background: transparent
        ? { r: 0, g: 0, b: 0, alpha: 0 }
        : undefined,
      threshold: transparent ? 1 : 12
    })
    .png()
    .toBuffer({ resolveWithObject: true });

  const innerWidth = Math.max(1, Math.round(width * (1 - paddingRatio * 2)));
  const innerHeight = Math.max(1, Math.round(height * (1 - paddingRatio * 2)));
  const resized = await sharp(trimmed.data)
    .resize({
      width: innerWidth,
      height: innerHeight,
      fit: "inside",
      withoutEnlargement: false
    })
    .png()
    .toBuffer({ resolveWithObject: true });

  const left = Math.floor((width - resized.info.width) / 2);
  const top = Math.floor((height - resized.info.height) / 2);
  const background = transparent
    ? { r: 0, g: 0, b: 0, alpha: 0 }
    : { r: 255, g: 255, b: 255, alpha: 1 };
  const output = await sharp({
    create: {
      width,
      height,
      channels: 4,
      background
    }
  })
    .composite([{ input: resized.data, left, top }])
    .png()
    .toBuffer();

  const metadata = await sharp(output).metadata();
  const stats = await sharp(output).stats();
  const alpha = await alphaCoverage(output);
  const validTransparency = transparent ? !stats.isOpaque && alpha.transparentPixels > 0 : true;

  return {
    buffer: output,
    report: {
      format: metadata.format,
      width: metadata.width,
      height: metadata.height,
      channels: metadata.channels,
      has_alpha: metadata.hasAlpha,
      transparency_valid: validTransparency,
      transparent_pixel_ratio: alpha.transparentPixels / alpha.totalPixels,
      removed_background_pixels: removedBackgroundPixels,
      source_trimmed_width: trimmed.info.width,
      source_trimmed_height: trimmed.info.height,
      content_width: resized.info.width,
      content_height: resized.info.height,
      content_offset: { x: left, y: top }
    }
  };
}

export async function createPreviewPng(asset, { width, height }) {
  const cell = Math.max(8, Math.round(Math.min(width, height) / 16));
  const checkerboard = Buffer.from(`<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <pattern id="checker" width="${cell * 2}" height="${cell * 2}" patternUnits="userSpaceOnUse">
      <rect width="${cell * 2}" height="${cell * 2}" fill="#f4f4f4"/>
      <rect width="${cell}" height="${cell}" fill="#d8d8d8"/>
      <rect x="${cell}" y="${cell}" width="${cell}" height="${cell}" fill="#d8d8d8"/>
    </pattern>
  </defs>
  <rect width="100%" height="100%" fill="url(#checker)"/>
</svg>`);

  return sharp(checkerboard)
    .composite([{ input: asset, left: 0, top: 0 }])
    .png()
    .toBuffer();
}

async function removeConnectedBackground(source, { tolerance }) {
  const raw = await sharp(source)
    .ensureAlpha()
    .toColourspace("srgb")
    .raw()
    .toBuffer({ resolveWithObject: true });
  const { width, height, channels } = raw.info;
  const pixels = Buffer.from(raw.data);
  const targetColour = inferCornerColour(pixels, width, height, channels);
  const visited = new Uint8Array(width * height);
  const queue = new Int32Array(width * height);
  let head = 0;
  let tail = 0;

  const enqueue = (x, y) => {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return;
    }
    const pixelIndex = y * width + x;
    if (visited[pixelIndex]) {
      return;
    }
    const offset = pixelIndex * channels;
    if (!nearColour(pixels, offset, targetColour, tolerance)) {
      return;
    }
    visited[pixelIndex] = 1;
    queue[tail] = pixelIndex;
    tail += 1;
  };

  for (let x = 0; x < width; x += 1) {
    enqueue(x, 0);
    enqueue(x, height - 1);
  }
  for (let y = 0; y < height; y += 1) {
    enqueue(0, y);
    enqueue(width - 1, y);
  }

  while (head < tail) {
    const pixelIndex = queue[head];
    head += 1;
    const x = pixelIndex % width;
    const y = Math.floor(pixelIndex / width);
    const offset = pixelIndex * channels;
    pixels[offset] = 0;
    pixels[offset + 1] = 0;
    pixels[offset + 2] = 0;
    pixels[offset + 3] = 0;
    enqueue(x - 1, y);
    enqueue(x + 1, y);
    enqueue(x, y - 1);
    enqueue(x, y + 1);
  }

  return {
    buffer: await sharp(pixels, {
      raw: { width, height, channels }
    }).png().toBuffer(),
    removedPixels: tail
  };
}

function inferCornerColour(pixels, width, height, channels) {
  const offsets = [
    0,
    (width - 1) * channels,
    (height - 1) * width * channels,
    (height * width - 1) * channels
  ];
  const median = (channel) => {
    const values = offsets.map((offset) => pixels[offset + channel]).sort((a, b) => a - b);
    return Math.round((values[1] + values[2]) / 2);
  };
  return { r: median(0), g: median(1), b: median(2) };
}

function nearColour(pixels, offset, target, tolerance) {
  const red = pixels[offset] - target.r;
  const green = pixels[offset + 1] - target.g;
  const blue = pixels[offset + 2] - target.b;
  return Math.sqrt(red * red + green * green + blue * blue) <= tolerance;
}

async function alphaCoverage(image) {
  const raw = await sharp(image).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let transparentPixels = 0;
  for (let offset = 3; offset < raw.data.length; offset += raw.info.channels) {
    if (raw.data[offset] < 255) {
      transparentPixels += 1;
    }
  }
  return {
    transparentPixels,
    totalPixels: raw.info.width * raw.info.height
  };
}
