#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "${script_dir}/.." && pwd)"
input="${project_dir}/identity/fighter-character-atlas-v002.png"
output="${project_dir}/identity/fighter-character-atlas-v003.png"
work_dir="$(mktemp -d)"

cleanup() {
  rm -rf -- "${work_dir}"
}
trap cleanup EXIT

columns=("5 377" "386 379" "770 379" "1154 376")
rows=("5 401" "412 337" "754 339" "1099 431")
cells=()

for row in 0 1 2 3; do
  read -r crop_y crop_h <<<"${rows[$row]}"
  for column in 0 1 2 3; do
    read -r crop_x crop_w <<<"${columns[$column]}"
    cell="${work_dir}/cell-${row}-${column}.png"

    convert "${input}" \
      -crop "${crop_w}x${crop_h}+${crop_x}+${crop_y}" \
      +repage \
      -shave 14x14 \
      -alpha on \
      -fuzz 15% \
      -transparent "#faf3ed" \
      -trim \
      +repage \
      -resize "366x366>" \
      -gravity center \
      -background "#fff8ed" \
      -extent 384x384 \
      +set date:create \
      +set date:modify \
      +set date:timestamp \
      -strip \
      -define png:exclude-chunk=date,time \
      -define png:color-type=6 \
      "${cell}"

    cells+=("${cell}")
  done
done

montage "${cells[@]}" \
  -background "#fff8ed" \
  -tile 4x4 \
  -geometry +0+0 \
  "${work_dir}/assembled.png"

convert "${work_dir}/assembled.png" \
  -stroke "#4b2751" \
  -strokewidth 5 \
  -fill none \
  -draw "rectangle 2,2 1533,1533" \
  -draw "line 384,0 384,1536" \
  -draw "line 768,0 768,1536" \
  -draw "line 1152,0 1152,1536" \
  -draw "line 0,384 1536,384" \
  -draw "line 0,768 1536,768" \
  -draw "line 0,1152 1536,1152" \
  +set date:create \
  +set date:modify \
  +set date:timestamp \
  -strip \
  -define png:exclude-chunk=date,time \
  -define png:color-type=6 \
  "${output}"

echo "${output}"
