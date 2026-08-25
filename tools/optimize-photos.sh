#!/usr/bin/env bash
# Resize and compress salon photos for the website.
#
# Phone photos are often 4–8 MB, which makes the site slow to load on mobile
# data. This shrinks them to fit within 1600px and re-encodes them, which
# usually lands well under 1 MB with no visible difference.
#
# Usage:
#   ./tools/optimize-photos.sh assets/originals/*.jpg
#
# Optimized copies are written into assets/portfolio/. Source files are never
# modified — keep the full-resolution versions in assets/originals/.
#
# Needs ffmpeg (preferred) or ImageMagick. Falls back to `sips`, which ships
# with macOS but gives much coarser control.
#   macOS:  brew install ffmpeg
#   Linux:  sudo apt install ffmpeg

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/assets/portfolio}"
MAX_PX="${MAX_PX:-1600}"     # longest edge, in pixels
QUALITY="${QUALITY:-3}"      # ffmpeg -q:v scale, 2 = best … 31 = worst

if   command -v ffmpeg  >/dev/null 2>&1; then ENGINE=ffmpeg
elif command -v magick  >/dev/null 2>&1; then ENGINE=magick
elif command -v convert >/dev/null 2>&1; then ENGINE=convert
elif command -v sips    >/dev/null 2>&1; then ENGINE=sips
else
  echo "Need ffmpeg or ImageMagick (macOS also has sips). Install ffmpeg:" >&2
  echo "  macOS:  brew install ffmpeg" >&2
  echo "  Linux:  sudo apt install ffmpeg" >&2
  exit 1
fi

[ "$#" -gt 0 ] || { echo "Usage: $0 photo1.jpg photo2.jpg ..." >&2; exit 1; }

mkdir -p "$OUT_DIR"

# "Basic Cut - Before & After.jpg" -> "basic-cut-before-after"
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/&/and/g' -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

human() { du -h "$1" | cut -f1 | tr -d ' '; }

for src in "$@"; do
  [ -f "$src" ] || { echo "skipping (not a file): $src" >&2; continue; }

  dest="$OUT_DIR/$(slugify "$(basename "${src%.*}")").jpg"
  tmp="$dest.tmp.jpg"

  case "$ENGINE" in
    ffmpeg)
      # Shrink the longest edge to MAX_PX. The if(gt(iw,ih),…) pair picks
      # whichever edge is longer; -1 keeps the other edge proportional, and
      # min() means an already-small photo is never blown up.
      ffmpeg -y -loglevel error -i "$src" \
        -vf "scale='if(gt(iw,ih),min(${MAX_PX},iw),-1)':'if(gt(iw,ih),-1,min(${MAX_PX},ih))'" \
        -q:v "$QUALITY" -map_metadata -1 "$tmp"
      ;;
    magick|convert)
      "$ENGINE" "$src" -auto-orient -resize "${MAX_PX}x${MAX_PX}>" -strip -quality 88 "$tmp"
      ;;
    sips)
      cp "$src" "$tmp"
      sips --setProperty format jpeg --setProperty formatOptions 70 \
           --resampleHeightWidthMax "$MAX_PX" "$tmp" --out "$tmp" >/dev/null
      ;;
  esac

  # Re-encoding an already-well-compressed photo can make it bigger. When that
  # happens the original is the better file, so keep it.
  if [ "$(stat -f%z "$tmp" 2>/dev/null || stat -c%s "$tmp")" -lt \
       "$(stat -f%z "$src" 2>/dev/null || stat -c%s "$src")" ]; then
    mv "$tmp" "$dest"
    note=""
  else
    rm -f "$tmp"
    cp "$src" "$dest"
    note="  (kept original — already smaller)"
  fi

  printf '%-46s %6s  ->  %-52s %6s%s\n' \
    "$(basename "$src")" "$(human "$src")" "${dest#"$ROOT"/}" "$(human "$dest")" "$note"
done

echo
echo "Done. Now add each photo to portfolio/index.html, for example:"
echo '  <figure class="gallery-item"><img src="../assets/portfolio/NAME.jpg" alt="Describe the style" loading="lazy" /></figure>'
