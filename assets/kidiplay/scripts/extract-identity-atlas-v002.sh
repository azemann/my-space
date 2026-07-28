#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)

source_image="$project_root/identity/kidiplay-identity-atlas-v002.png"
output_root="$project_root/generated/v002"
spritesheet="$project_root/identity/kidiplay-spritesheet-v002.png"
tile_work_dir=$(mktemp -d)

trap 'rm -rf -- "$tile_work_dir"' EXIT

mkdir -p \
  "$output_root/characters" \
  "$output_root/icons" \
  "$output_root/animals" \
  "$output_root/buttons" \
  "$output_root/decor"

extract_cell() {
  asset_path=$1
  column=$2
  row=$3
  gravity=$4
  tile_index=$5

  crop_x=$((column * 384 + 8))
  crop_y=$((row * 384 + 8))

  convert "$source_image" \
    -crop "368x368+$crop_x+$crop_y" +repage \
    -alpha on \
    -bordercolor '#fffdf5' -border 1 \
    -fuzz 8% -fill none -draw 'matte 0,0 floodfill' \
    -shave 1x1 \
    -trim +repage \
    -resize '340x340>' \
    -gravity "$gravity" \
    -background none \
    -extent 384x384 \
    -define png:color-type=6 \
    "$output_root/$asset_path"

  cp "$output_root/$asset_path" "$tile_work_dir/$tile_index.png"
}

extract_cell characters/mascot-bear.png 0 0 south 00
extract_cell icons/play.png 1 0 center 01
extract_cell icons/memory.png 2 0 center 02
extract_cell icons/coloring.png 3 0 center 03

extract_cell icons/puzzle.png 0 1 center 04
extract_cell icons/music.png 1 1 center 05
extract_cell icons/stickers.png 2 1 center 06
extract_cell animals/rabbit.png 3 1 south 07

extract_cell animals/fox.png 0 2 south 08
extract_cell animals/elephant.png 1 2 south 09
extract_cell animals/lion.png 2 2 south 10
extract_cell buttons/play.png 3 2 center 11

extract_cell buttons/favorite.png 0 3 center 12
extract_cell buttons/star.png 1 3 center 13
extract_cell decor/flowering-bush.png 2 3 south 14
extract_cell decor/cloud-stars.png 3 3 center 15

montage "$tile_work_dir"/*.png \
  -background none \
  -tile 4x4 \
  -geometry +0+0 \
  -define png:color-type=6 \
  "$spritesheet"

printf '%s\n' "Assets écrits dans $output_root"
printf '%s\n' "Spritesheet écrite dans $spritesheet"
