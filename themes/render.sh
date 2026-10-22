#!/usr/bin/env bash
# Render the theme files from one Catppuccin palette with whiskers
# (https://github.com/catppuccin/whiskers). Edit the templates in themes/,
# not the generated files.
# Usage: themes/render.sh          write the generated files
#        themes/render.sh --check  fail if a generated file is out of date
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

flavor=mocha

# template:output. For output#block, only the lines between the
# "themes/render.sh: begin <block>" and "... end <block>" comments change.
targets=(
  themes/hyprland.lua.tera:.config/hypr/themes/catppuccin.lua
  themes/gtk.css.tera:.config/themes/catppuccin/colors.css
  themes/ghostty.conf.tera:.config/themes/catppuccin/ghostty.conf
  themes/regreet.css.tera:system_configs/etc/greetd/regreet.css
  themes/wayle-palette.toml.tera:.config/wayle/config.toml#palette
)

mode='write'
case "${1:-}" in
  --check) mode='check' ;;
  '') ;;
  *) echo "usage: $0 [--check]" >&2; exit 2 ;;
esac

if ! command -v whiskers > /dev/null; then
  echo 'whiskers not found; get it from https://github.com/catppuccin/whiskers/releases' >&2
  exit 1
fi

# Print FILE with the lines between the BLOCK markers replaced by FRAGMENT.
splice() {
  local file="$1" block="$2" fragment="$3"
  local begin="themes/render.sh: begin $block" end="themes/render.sh: end $block"
  if ! grep -qF "$begin" "$file" || ! grep -qF "$end" "$file"; then
    echo "$file: missing the '$block' marker comments" >&2
    return 1
  fi
  awk -v begin="$begin" -v end="$end" -v fragment="$fragment" '
    index($0, end) { skip = 0 }
    !skip { print }
    index($0, begin) { while ((getline line < fragment) > 0) print line; skip = 1 }
  ' "$file"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

stale=0
for target in "${targets[@]}"; do
  template="${target%%:*}"
  output="${target#*:}"
  block=''
  if [[ "$output" == *'#'* ]]; then
    block="${output#*#}"
    output="${output%%#*}"
  fi

  whiskers "$template" -f "$flavor" > "$tmp/rendered"
  if [[ -n "$block" ]]; then
    splice "$output" "$block" "$tmp/rendered" > "$tmp/new"
  else
    cp "$tmp/rendered" "$tmp/new"
  fi

  cmp -s "$tmp/new" "$output" && continue
  if [[ "$mode" == check ]]; then
    echo "Out of date: $output (run themes/render.sh)" >&2
    diff -u "$output" "$tmp/new" >&2 || true
    stale=1
  else
    cp "$tmp/new" "$output"
    echo "Wrote $output"
  fi
done
exit "$stale"
