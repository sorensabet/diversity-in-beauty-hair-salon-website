#!/usr/bin/env bash
# Resize and compress salon photos for the website.
#
# Phone photos are often 4–8 MB, which makes the site slow to load on mobile
# data. This shrinks them to a web-friendly size (max 1600px, ~85% quality),
# which usually lands under 300 KB with no visible difference.
#
# Usage:
#   ./tools/optimize-photos.sh ~/Desktop/salon-photos/*.jpg
#
# Optimized copies are written into assets/portfolio/. Originals are untouched.
#
# Requires ImageMagick:  brew install imagemagick   (macOS)
#                        sudo apt install imagemagick   (Ubuntu/Debian)

set -euo pipefail

OUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/portfolio"
MAX_WIDTH=1600
QUALITY=85

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  echo "ImageMagick not found. Install it first:" >&2
  echo "  macOS:  brew install imagemagick" >&2
  echo "  Linux:  sudo apt install imagemagick" >&2
  exit 1
fi

if command -v magick >/dev/null 2>&1; then MAGICK=magick; else MAGICK=convert; fi

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 photo1.jpg photo2.jpg ..." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

for src in "$@"; do
  [ -f "$src" ] || { echo "skipping (not a file): $src" >&2; continue; }
  base="$(basename "${src%.*}")"
  # lowercase, spaces -> dashes, so URLs stay clean
  slug="$(echo "$base" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9._-')"
  dest="$OUT_DIR/$slug.jpg"

  "$MAGICK" "$src" \
    -auto-orient \
    -resize "${MAX_WIDTH}x${MAX_WIDTH}>" \
    -strip \
    -quality "$QUALITY" \
    "$dest"

  before=$(du -h "$src"  | cut -f1)
  after=$(du -h "$dest" | cut -f1)
  echo "$src ($before)  ->  assets/portfolio/$slug.jpg ($after)"
done

echo
echo "Done. Now add each photo to portfolio/index.html, for example:"
echo '  <figure class="gallery-item"><img src="../assets/portfolio/NAME.jpg" alt="Describe the style" loading="lazy" /></figure>'
