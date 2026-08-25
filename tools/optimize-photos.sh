#!/usr/bin/env bash
# Resize and compress salon photos for the website.
#
# Phone photos are often 4-8 MB, which makes the site slow to load on mobile
# data. This shrinks them to a web-friendly size (max 1600px, ~85% quality),
# which usually lands under 300 KB with no visible difference.
#
# Usage:
#   ./tools/optimize-photos.sh ~/Desktop/salon-photos/*.jpg          # -> assets/portfolio/
#   ./tools/optimize-photos.sh -o assets ~/Desktop/salon.jpg         # -> assets/
#
# Gallery photos belong in assets/portfolio/ (the default). The home page's
# wide salon photo and the two service photos belong in assets/, so pass
# `-o assets` for those.
#
# Originals are never modified.
#
# Requires ImageMagick:  brew install imagemagick        (macOS)
#                        sudo apt install imagemagick    (Ubuntu/Debian)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$REPO_ROOT/assets/portfolio"
MAX_WIDTH=1600
QUALITY=85

usage() {
  cat >&2 <<USAGE
Usage: $(basename "$0") [-o OUTPUT_DIR] photo1.jpg [photo2.jpg ...]

  -o OUTPUT_DIR   Where to write the optimized copies, relative to the repo
                  root. Default: assets/portfolio
                  Use "-o assets" for the salon and service photos.
USAGE
  exit 1
}

while getopts ":o:h" opt; do
  case "$opt" in
    o) OUT_DIR="$REPO_ROOT/${OPTARG#/}" ;;
    h) usage ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage ;;
    :)  echo "Option -$OPTARG needs a directory" >&2; usage ;;
  esac
done
shift $((OPTIND - 1))

[ "$#" -gt 0 ] || usage

if command -v magick >/dev/null 2>&1; then
  MAGICK=magick
elif command -v convert >/dev/null 2>&1; then
  MAGICK=convert
else
  echo "ImageMagick not found. Install it first:" >&2
  echo "  macOS:  brew install imagemagick" >&2
  echo "  Linux:  sudo apt install imagemagick" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
count=0

for src in "$@"; do
  if [ ! -f "$src" ]; then
    echo "skipping (not a file): $src" >&2
    continue
  fi

  base="$(basename "${src%.*}")"
  # lowercase, spaces -> dashes, so the URLs stay clean
  slug="$(echo "$base" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9._-')"
  [ -n "$slug" ] || slug="photo-$((count + 1))"
  dest="$OUT_DIR/$slug.jpg"

  "$MAGICK" "$src" \
    -auto-orient \
    -resize "${MAX_WIDTH}x${MAX_WIDTH}>" \
    -strip \
    -quality "$QUALITY" \
    "$dest"

  before=$(du -h "$src"  | cut -f1)
  after=$(du -h "$dest"  | cut -f1)
  rel="${dest#"$REPO_ROOT"/}"
  echo "$(basename "$src") ($before)  ->  $rel ($after)"
  count=$((count + 1))
done

echo
echo "Optimized $count photo(s) into ${OUT_DIR#"$REPO_ROOT"/}/"
if [ "${OUT_DIR}" = "$REPO_ROOT/assets/portfolio" ]; then
  echo "Next: add each one to portfolio/index.html, for example:"
  echo '  <figure class="gallery-item"><img src="../assets/portfolio/NAME.jpg" alt="Describe the cut" loading="lazy" /></figure>'
fi
