#!/usr/bin/env node

import {
  copyFileSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const projectDir = resolve(scriptDir, "..");
const manifestPath = resolve(projectDir, "motion/animation-v1.json");
const manifestDir = dirname(manifestPath);
const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const workDir = mkdtempSync(join(tmpdir(), "neon-courier-atlas-"));

const run = (command, args) =>
  execFileSync(command, args, {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"]
  }).trim();

const ensurePair = (value, label) => {
  if (!Array.isArray(value) || value.length !== 2) {
    throw new Error(`${label} doit contenir exactement deux valeurs`);
  }
};

const nextMultiple = (value, multiple) =>
  Math.ceil(value / multiple) * multiple;

const parseGeometry = (value) => {
  const match = /^(\d+)x(\d+)\+(\d+)\+(\d+)$/.exec(value);
  if (!match) {
    throw new Error(`Géométrie ImageMagick invalide: ${value}`);
  }
  return {
    width: Number(match[1]),
    height: Number(match[2]),
    x: Number(match[3]),
    y: Number(match[4])
  };
};

const assertManifest = () => {
  if (manifest.schemaVersion !== "1.1.0" || manifest.kind !== "myspace-animation") {
    throw new Error("Le manifeste ne respecte pas myspace-animation-v1");
  }
  ensurePair(manifest.coordinateSpace.canvasSize, "coordinateSpace.canvasSize");
  ensurePair(manifest.coordinateSpace.origin, "coordinateSpace.origin");
  if (!Number.isFinite(manifest.coordinateSpace.groundLine)) {
    throw new Error("coordinateSpace.groundLine doit être un nombre");
  }
  if (!manifest.frameProfilesData || !Object.keys(manifest.frameProfiles ?? {}).length) {
    throw new Error("Au moins un frameProfile et frameProfilesData sont requis");
  }
  for (const [profileId, profile] of Object.entries(manifest.frameProfiles)) {
    ensurePair(profile.canvasSize, `${profileId}.canvasSize`);
    ensurePair(profile.origin, `${profileId}.origin`);
    if (!profile.pathTemplate.includes("{animation}") || !profile.pathTemplate.includes("{index}")) {
      throw new Error(`${profileId}: pathTemplate doit contenir {animation} et {index}`);
    }
    if (!(profile.scale > 0)) {
      throw new Error(`${profileId}: scale doit être positif`);
    }
    const expectedSize = manifest.coordinateSpace.canvasSize.map(
      (value) => value * profile.scale
    );
    const expectedOrigin = manifest.coordinateSpace.origin.map(
      (value) => value * profile.scale
    );
    const expectedGroundLine =
      manifest.coordinateSpace.groundLine * profile.scale;
    if (
      profile.canvasSize.some((value, index) => value !== expectedSize[index]) ||
      profile.origin.some((value, index) => value !== expectedOrigin[index]) ||
      !Number.isInteger(expectedGroundLine)
    ) {
      throw new Error(
        `${profileId}: canvasSize/origin/groundLine incohérents avec scale`
      );
    }
  }

  const frameNames = new Set();
  for (const [animationId, animation] of Object.entries(manifest.animations)) {
    if (animation.directions.some((id) => !manifest.directions[id])) {
      throw new Error(`${animationId}: direction inconnue`);
    }
    if (!animation.frames.length) {
      throw new Error(`${animationId}: aucune frame`);
    }

    for (const [index, frame] of animation.frames.entries()) {
      if (frameNames.has(frame.name)) {
        throw new Error(`Nom de frame dupliqué: ${frame.name}`);
      }
      frameNames.add(frame.name);
      ensurePair(frame.cell, `${frame.name}.cell`);
      if (!manifest.collisionSets[frame.collisionSet]) {
        throw new Error(`${frame.name}: collisionSet inconnu`);
      }
      if (frame.durationMs <= 0) {
        throw new Error(`${frame.name}: durationMs doit être positif`);
      }
      if (
        frame.cell[0] >= animation.source.grid.columns ||
        frame.cell[1] >= animation.source.grid.rows
      ) {
        throw new Error(`${frame.name}: cellule hors grille`);
      }
      if (frame.hitboxes?.length && !animation.attack) {
        throw new Error(`${animationId}[${index}]: hitbox sans attaque`);
      }
    }

    for (const [phase, range] of Object.entries(animation.phases ?? {})) {
      ensurePair(range, `${animationId}.phases.${phase}`);
      if (range[0] > range[1] || range[1] >= animation.frames.length) {
        throw new Error(`${animationId}: plage ${phase} invalide`);
      }
    }
  }
};

const createExtrudedSprite = (source, target, width, height, extrude) => {
  if (extrude === 0) {
    run("cp", [source, target]);
    return { width, height };
  }

  run("convert", [
    source,
    "-alpha",
    "on",
    "-virtual-pixel",
    "edge",
    "-set",
    "option:distort:viewport",
    `${width + extrude * 2}x${height + extrude * 2}-${extrude}-${extrude}`,
    "-distort",
    "SRT",
    "0",
    "-define",
    "png:color-type=6",
    target
  ]);

  return {
    width: width + extrude * 2,
    height: height + extrude * 2
  };
};

const build = () => {
  assertManifest();

  const [canvasWidth, canvasHeight] = manifest.coordinateSpace.canvasSize;
  const [originX, originY] = manifest.coordinateSpace.origin;
  const pivot = {x: originX / canvasWidth, y: originY / canvasHeight};
  const entries = [];
  const animationFrameNames = {};
  const frameProfileFiles = Object.fromEntries(
    Object.keys(manifest.frameProfiles).map((profileId) => [
      profileId,
      Object.fromEntries(
        Object.keys(manifest.animations).map((animationId) => [animationId, []])
      )
    ])
  );

  for (const [animationId, animation] of Object.entries(manifest.animations)) {
    const sourcePath = resolve(manifestDir, animation.source.image);
    const normalizedBoardPath = resolve(
      manifestDir,
      animation.source.normalizedBoard
    );
    mkdirSync(dirname(normalizedBoardPath), {recursive: true});

    const [sourceWidth, sourceHeight] = run(
      "identify",
      ["-format", "%w %h", sourcePath]
    ).split(/\s+/).map(Number);
    const {columns, rows, inset} = animation.source.grid;

    if (sourceWidth % columns !== 0 || sourceHeight % rows !== 0) {
      throw new Error(`${animationId}: la source ne se divise pas par sa grille`);
    }

    const cellWidth = sourceWidth / columns;
    const cellHeight = sourceHeight / rows;
    const innerWidth = cellWidth - inset * 2;
    const innerHeight = cellHeight - inset * 2;
    const boardCells = [];
    animationFrameNames[animationId] = [];

    for (const [frameIndex, frame] of animation.frames.entries()) {
      const [column, row] = frame.cell;
      const prefix = `${animationId}-${String(frameIndex).padStart(3, "0")}`;
      const rawPath = join(workDir, `${prefix}-raw.png`);
      const normalizedPath = join(workDir, `${prefix}-canvas.png`);
      const trimmedPath = join(workDir, `${prefix}-trimmed.png`);
      const extrudedPath = join(workDir, `${prefix}-extruded.png`);

      run("convert", [
        sourcePath,
        "-crop",
        `${innerWidth}x${innerHeight}+${column * cellWidth + inset}+${row * cellHeight + inset}`,
        "+repage",
        "-alpha",
        "on",
        "-fuzz",
        `${animation.source.backgroundFuzz}%`,
        "-transparent",
        animation.source.backgroundKey,
        "-resize",
        `${canvasWidth}x${canvasHeight}!`,
        "-channel",
        "A",
        "-morphology",
        "Erode",
        "Diamond:1",
        "+channel",
        "-channel",
        "G",
        "-fx",
        "min(g,max(r,b))",
        "+channel",
        "-define",
        "png:color-type=6",
        rawPath
      ]);

      const rawGeometry = parseGeometry(run("convert", [
        rawPath,
        "-alpha",
        "extract",
        "-threshold",
        "1",
        "-format",
        "%@",
        "info:"
      ]));
      const groundOffset =
        manifest.coordinateSpace.groundLine -
        (rawGeometry.y + rawGeometry.height);

      run("convert", [
        "-size",
        `${canvasWidth}x${canvasHeight}`,
        "xc:none",
        rawPath,
        "-geometry",
        `+0${groundOffset >= 0 ? "+" : ""}${groundOffset}`,
        "-composite",
        "+set",
        "date:create",
        "+set",
        "date:modify",
        "+set",
        "date:timestamp",
        "-strip",
        "-define",
        "png:exclude-chunk=date,time",
        "-define",
        "png:color-type=6",
        normalizedPath
      ]);

      for (const [profileId, profile] of Object.entries(manifest.frameProfiles)) {
        const outputPath = resolve(
          manifestDir,
          profile.pathTemplate
            .replace("{animation}", animationId)
            .replace("{index}", String(frameIndex).padStart(3, "0"))
        );
        mkdirSync(dirname(outputPath), {recursive: true});
        if (profile.scale === 1) {
          copyFileSync(normalizedPath, outputPath);
        } else {
          const scaledPath = join(workDir, `${prefix}-${profileId}-scaled.png`);
          run("convert", [
            normalizedPath,
            "-filter",
            "Lanczos",
            "-resize",
            `${profile.canvasSize[0]}x${profile.canvasSize[1]}!`,
            "-define",
            "png:color-type=6",
            scaledPath
          ]);
          const scaledGeometry = parseGeometry(run("convert", [
            scaledPath,
            "-alpha",
            "extract",
            "-threshold",
            "1",
            "-format",
            "%@",
            "info:"
          ]));
          const profileGroundLine =
            manifest.coordinateSpace.groundLine * profile.scale;
          const profileGroundOffset =
            profileGroundLine -
            (scaledGeometry.y + scaledGeometry.height);
          run("convert", [
            "-size",
            `${profile.canvasSize[0]}x${profile.canvasSize[1]}`,
            "xc:none",
            scaledPath,
            "-geometry",
            `+0${profileGroundOffset >= 0 ? "+" : ""}${profileGroundOffset}`,
            "-composite",
            "+set",
            "date:create",
            "+set",
            "date:modify",
            "+set",
            "date:timestamp",
            "-strip",
            "-define",
            "png:exclude-chunk=date,time",
            "-define",
            "png:color-type=6",
            outputPath
          ]);
        }
        frameProfileFiles[profileId][animationId].push(
          relative(dirname(resolve(manifestDir, manifest.frameProfilesData)), outputPath)
        );
      }

      const corner = run(
        "convert",
        [normalizedPath, "-format", "%[pixel:p{0,0}]", "info:"]
      );
      if (!corner.includes(",0") && !corner.includes("none")) {
        throw new Error(`${frame.name}: le coin n’est pas transparent`);
      }

      const geometry = parseGeometry(run("convert", [
        normalizedPath,
        "-alpha",
        "extract",
        "-threshold",
        "1",
        "-format",
        "%@",
        "info:"
      ]));

      run("convert", [
        normalizedPath,
        "-crop",
        `${geometry.width}x${geometry.height}+${geometry.x}+${geometry.y}`,
        "+repage",
        "-define",
        "png:color-type=6",
        trimmedPath
      ]);

      const packedSize = createExtrudedSprite(
        trimmedPath,
        extrudedPath,
        geometry.width,
        geometry.height,
        manifest.atlas.extrude
      );

      boardCells.push(normalizedPath);
      animationFrameNames[animationId].push(frame.name);
      entries.push({
        frame,
        geometry,
        extrudedPath,
        packedWidth: packedSize.width,
        packedHeight: packedSize.height
      });
    }

    run("montage", [
      ...boardCells,
      "-background",
      "none",
      "-tile",
      `${columns}x${rows}`,
      "-geometry",
      "+0+0",
      "-define",
      "png:color-type=6",
      normalizedBoardPath
    ]);

    const previewPath = resolve(manifestDir, animation.source.preview);
    mkdirSync(dirname(previewPath), {recursive: true});
    const previewArgs = [];
    for (const [index, cellPath] of boardCells.entries()) {
      previewArgs.push(
        "-delay",
        String(Math.max(1, Math.round(animation.frames[index].durationMs / 10))),
        cellPath
      );
    }
    previewArgs.push(
      "-dispose",
      "background",
      "-loop",
      animation.loopMode === "none" ? "1" : "0",
      previewPath
    );
    run("convert", previewArgs);
  }

  const atlasWidth = 2048;
  const padding = manifest.atlas.padding;
  let cursorX = padding;
  let cursorY = padding;
  let rowHeight = 0;
  const packingEntries = [...entries].sort(
    (left, right) =>
      right.packedHeight - left.packedHeight ||
      right.packedWidth - left.packedWidth ||
      left.frame.name.localeCompare(right.frame.name)
  );

  for (const entry of packingEntries) {
    if (entry.packedWidth + padding * 2 > atlasWidth) {
      throw new Error(`${entry.frame.name}: frame trop large pour l’atlas`);
    }
    if (cursorX + entry.packedWidth + padding > atlasWidth) {
      cursorX = padding;
      cursorY += rowHeight + padding;
      rowHeight = 0;
    }
    entry.packedX = cursorX;
    entry.packedY = cursorY;
    cursorX += entry.packedWidth + padding;
    rowHeight = Math.max(rowHeight, entry.packedHeight);
  }

  const atlasHeight = nextMultiple(cursorY + rowHeight + padding, 4);
  const atlasImagePath = resolve(manifestDir, manifest.atlas.image);
  const atlasDataPath = resolve(manifestDir, manifest.atlas.data);
  const runtimeDataPath = resolve(manifestDir, manifest.atlas.runtimeData);
  const frameProfilesDataPath = resolve(
    manifestDir,
    manifest.frameProfilesData
  );
  mkdirSync(dirname(atlasImagePath), {recursive: true});

  const compositeArgs = ["-size", `${atlasWidth}x${atlasHeight}`, "xc:none"];
  for (const entry of entries) {
    compositeArgs.push(
      entry.extrudedPath,
      "-geometry",
      `+${entry.packedX}+${entry.packedY}`,
      "-composite"
    );
  }
  compositeArgs.push(
    "+set",
    "date:create",
    "+set",
    "date:modify",
    "+set",
    "date:timestamp",
    "-strip",
    "-define",
    "png:exclude-chunk=date,time",
    "-define",
    "png:color-type=6",
    atlasImagePath
  );
  run("convert", compositeArgs);

  const atlasFrames = {};
  for (const entry of entries) {
    atlasFrames[entry.frame.name] = {
      frame: {
        x: entry.packedX + manifest.atlas.extrude,
        y: entry.packedY + manifest.atlas.extrude,
        w: entry.geometry.width,
        h: entry.geometry.height
      },
      rotated: false,
      trimmed: true,
      spriteSourceSize: {
        x: entry.geometry.x,
        y: entry.geometry.y,
        w: entry.geometry.width,
        h: entry.geometry.height
      },
      sourceSize: {w: canvasWidth, h: canvasHeight},
      pivot,
      duration: entry.frame.durationMs
    };
  }

  const atlasJson = {
    frames: atlasFrames,
    animations: animationFrameNames,
    meta: {
      app: "MySpace project-local atlas builder",
      version: manifest.schemaVersion,
      image: basename(atlasImagePath),
      format: "RGBA8888",
      size: {w: atlasWidth, h: atlasHeight},
      scale: "1",
      smartupdate: `myspace:${manifest.assetId}:${manifest.schemaVersion}`
    }
  };

  const runtimeAnimations = Object.fromEntries(
    Object.entries(manifest.animations).map(([animationId, animation]) => {
      const {source, ...runtimeAnimation} = animation;
      return [
        animationId,
        {
          ...runtimeAnimation,
          frames: animation.frames.map(({cell, ...frame}) => frame)
        }
      ];
    })
  );

  const runtimeJson = {
    schemaVersion: manifest.schemaVersion,
    kind: "myspace-animation-runtime",
    assetId: manifest.assetId,
    status: manifest.status,
    statuses: manifest.statuses,
    atlas: {
      image: basename(atlasImagePath),
      data: basename(atlasDataPath),
      format: manifest.atlas.format
    },
    coordinateSpace: manifest.coordinateSpace,
    frameProfiles: Object.fromEntries(
      Object.entries(manifest.frameProfiles).map(([profileId, profile]) => [
        profileId,
        {
          manifest: basename(frameProfilesDataPath),
          canvasSize: profile.canvasSize,
          origin: profile.origin,
          scale: profile.scale,
          usage: profile.usage
        }
      ])
    ),
    directions: manifest.directions,
    collisionSets: manifest.collisionSets,
    animations: runtimeAnimations
  };

  const frameProfilesJson = {
    $schema: "../../../contracts/animation-frames-v1.schema.json",
    schemaVersion: manifest.schemaVersion,
    kind: "myspace-animation-frames",
    assetId: manifest.assetId,
    coordinateSpace: {
      units: manifest.coordinateSpace.units,
      xAxis: manifest.coordinateSpace.xAxis,
      yAxis: manifest.coordinateSpace.yAxis,
      frameIndexBase: manifest.coordinateSpace.frameIndexBase
    },
    profiles: Object.fromEntries(
      Object.entries(manifest.frameProfiles).map(([profileId, profile]) => [
        profileId,
        {
          canvasSize: profile.canvasSize,
          origin: profile.origin,
          groundLine: manifest.coordinateSpace.groundLine * profile.scale,
          scale: profile.scale,
          usage: profile.usage,
          animations: frameProfileFiles[profileId]
        }
      ])
    )
  };

  writeFileSync(atlasDataPath, `${JSON.stringify(atlasJson, null, 2)}\n`);
  writeFileSync(runtimeDataPath, `${JSON.stringify(runtimeJson, null, 2)}\n`);
  writeFileSync(
    frameProfilesDataPath,
    `${JSON.stringify(frameProfilesJson, null, 2)}\n`
  );

  console.log(`Atlas: ${atlasImagePath} (${atlasWidth}x${atlasHeight})`);
  console.log(`Frames: ${entries.length}`);
  console.log(`Atlas JSON: ${atlasDataPath}`);
  console.log(`Animation JSON: ${runtimeDataPath}`);
  console.log(`Loose frames JSON: ${frameProfilesDataPath}`);
  for (const [profileId, animations] of Object.entries(frameProfileFiles)) {
    const count = Object.values(animations).reduce(
      (total, files) => total + files.length,
      0
    );
    console.log(`Loose frames ${profileId}: ${count}`);
  }
};

try {
  build();
} finally {
  rmSync(workDir, {recursive: true, force: true});
}
