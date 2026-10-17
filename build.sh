#!/usr/bin/env bash
# xSAR article builder: src/articles/<slug>.md  ->  articles/<slug>.html
#                       + articles/index.html + articles/formulas/<hash>.{svg,png}
#                       + articles/formulas/<slug>.txt (X upload manifest)
# Deterministic and offline. articles/ is fully regenerated on every run:
# do not hand-edit anything in it.
#
# Usage: ./build.sh [--strict] [--update-sitemap] [--record-versions] [--help]
set -euo pipefail

export LC_ALL=C TZ=UTC SOURCE_DATE_EPOCH=0 FORCE_SOURCE_DATE=1
cd "$(dirname "$0")"

STRICT=0 SITEMAP=0 RECORD=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    --update-sitemap) SITEMAP=1 ;;
    --record-versions) RECORD=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

SITE=https://xsar.com.au
SRC=src/articles
OUT=articles
TEMPLATE=templates/article.html5
FILTER=filters/article.lua
PANDOC_ARGS=(--from markdown+yaml_metadata_block+bracketed_spans --to html5
  --standalone --template "$TEMPLATE" --math-method=mathml
  --lua-filter "$FILTER")

# ---- tools and versions -------------------------------------------------
for t in pandoc latex dvisvgm resvg oxipng sha256sum; do
  command -v "$t" >/dev/null || { echo "missing tool: $t (see README: Articles pipeline)" >&2; exit 1; }
done

current_version() {
  case "$1" in
    pandoc)  pandoc --version | awk 'NR==1{print $2}' ;;
    texlive) latex --version | sed -n '1s/.*(TeX Live \([0-9]*\).*/\1/p' ;;
    dvisvgm) dvisvgm --version | awk 'NR==1{print $2}' ;;
    resvg)   resvg --version | awk 'NR==1{print $NF}' ;;
    oxipng)  oxipng --version | awk 'NR==1{print $2}' ;;
  esac
}
TOOLS=(pandoc texlive dvisvgm resvg oxipng)

if [ "$RECORD" = 1 ]; then
  { sed -n '/^#/p' tools.versions 2>/dev/null || true
    for t in "${TOOLS[@]}"; do echo "$t $(current_version "$t")"; done; } > tools.versions.new
  mv tools.versions.new tools.versions
  echo "recorded tool versions:"; grep -v '^#' tools.versions
fi

mismatch=0
while read -r tool want; do
  case "$tool" in ''|\#*) continue ;; esac
  have=$(current_version "$tool")
  if [ "$have" != "$want" ]; then
    echo "WARNING: $tool is $have, tools.versions expects $want (output may differ byte-for-byte)" >&2
    mismatch=1
  fi
done < tools.versions
if [ "$mismatch" = 1 ] && [ "$STRICT" = 1 ]; then
  echo "--strict: refusing to build with mismatched tool versions" >&2; exit 1
fi

# ---- build into a scratch stage -----------------------------------------
WORK=$(mktemp -d)
[ -n "${XSAR_KEEP_WORK:-}" ] && echo "work dir kept: $WORK" >&2 || trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/stage"
mkdir -p "$STAGE/formulas" "$WORK/jobs" "$WORK/rows"
export XSAR_WORK="$WORK" XSAR_STAGE="$STAGE"

shopt -s nullglob
sources=("$SRC"/*.md)   # glob order is byte order under LC_ALL=C
for md in "${sources[@]}"; do
  slug=$(basename "$md" .md)
  pandoc "${PANDOC_ARGS[@]}" -o "$STAGE/$slug.html" "$md"
  echo "page     $OUT/$slug.html"
done

# ---- formula images (one per unique hash) --------------------------------
# dvisvgm < 3.5 can emit the glyph <path> defs in an order that depends on the
# run context, so sort the <defs> block into a canonical (byte) order.
canon_svg() {
  local f=$1 s e
  s=$(grep -n '^<defs>$' "$f" | head -n1 | cut -d: -f1)
  e=$(grep -n '^</defs>$' "$f" | head -n1 | cut -d: -f1)
  [ -n "$s" ] && [ -n "$e" ] || return 0
  { head -n "$s" "$f"; sed -n "$((s + 1)),$((e - 1))p" "$f" | sort; tail -n +"$e" "$f"; } > "$f.canon"
  mv "$f.canon" "$f"
}
for job in "$WORK"/jobs/*.tex; do
  h=$(basename "$job" .tex)
  d="$WORK/tex/$h"; mkdir -p "$d"; cp "$job" "$d/f.tex"
  if ! (cd "$d" && latex -interaction=nonstopmode -halt-on-error -no-shell-escape f.tex >/dev/null 2>&1); then
    echo "LaTeX failed for formula $h:" >&2; sed -n '/^!/,+6p' "$d/f.log" >&2; cat "$job" >&2; exit 1
  fi
  (cd "$d" && dvisvgm --no-fonts --exact-bbox --bbox=2pt --verbosity=0 -o f.svg f.dvi)
  canon_svg "$d/f.svg"
  (cd "$d" && resvg --zoom 4 --background white f.svg f.png && oxipng -o 2 --strip all --quiet f.png)
  cp "$d/f.svg" "$STAGE/formulas/$h.svg"
  cp "$d/f.png" "$STAGE/formulas/$h.png"
done
echo "formulas $(ls "$WORK"/jobs | wc -l | tr -d ' ') unique"

# ---- articles index (newest first, slug breaks ties) ---------------------
rows="$WORK/rows.sorted"
cat /dev/null "$WORK"/rows/*.tsv | sort -t "$(printf '\t')" -k1,1r -k2,2 > "$rows"
{
  printf -- '---\ntitle: Articles\nis_index: true\ndescription: "Long-form xSAR articles: engineering notes, research and lessons learned."\n---\n\n'
  printf '````{=html}\n'
  printf '<p>Long-form write-ups from xSAR. Shorter updates are on <a href="https://x.com/xSAR_Research" target="_blank" rel="noopener noreferrer">X @xSAR_Research</a>.</p>\n'
  if [ -s "$rows" ]; then
    printf '<ul class="article-list">\n'
    while IFS="$(printf '\t')" read -r date slug lastmod disp title summary; do
      printf '<li><h2><a href="%s.html">%s</a></h2><time datetime="%s">%s</time><p>%s</p></li>\n' \
        "$slug" "$title" "$date" "$disp" "$summary"
    done < "$rows"
    printf '</ul>\n'
  else
    printf '<p>No articles yet.</p>\n'
  fi
  printf '````\n'
} > "$WORK/index.md"
pandoc "${PANDOC_ARGS[@]}" -o "$STAGE/index.html" "$WORK/index.md"
echo "index    $OUT/index.html ($(wc -l < "$rows" | tr -d ' ') articles)"

# ---- swap the stage in ----------------------------------------------------
rm -rf "$OUT"
cp -R "$STAGE" "$OUT"

# ---- optional sitemap block -------------------------------------------------
if [ "$SITEMAP" = 1 ]; then
  newest=$(cut -f3 "$rows" | sort -r | head -n1)
  {
    echo "  <!-- articles:begin (generated by build.sh --update-sitemap) -->"
    if [ -n "$newest" ]; then
      printf '  <url>\n    <loc>%s/articles/index.html</loc>\n    <lastmod>%s</lastmod>\n    <changefreq>weekly</changefreq>\n    <priority>0.8</priority>\n  </url>\n' "$SITE" "$newest"
    fi
    while IFS="$(printf '\t')" read -r date slug lastmod _; do
      printf '  <url>\n    <loc>%s/articles/%s.html</loc>\n    <lastmod>%s</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>0.7</priority>\n  </url>\n' "$SITE" "$slug" "$lastmod"
    done < "$rows"
    echo "  <!-- articles:end -->"
  } > "$WORK/sitemap.block"
  awk -v blockfile="$WORK/sitemap.block" '
    /<!-- articles:begin/ { skip = 1; next }
    /<!-- articles:end/   { skip = 0; next }
    skip { next }
    /<\/urlset>/ { while ((getline line < blockfile) > 0) print line }
    { print }
  ' sitemap.xml > "$WORK/sitemap.xml"
  cp "$WORK/sitemap.xml" sitemap.xml
  echo "sitemap  sitemap.xml updated"
fi

# ---- fingerprint (compare between runs/machines) ---------------------------
fp=$(find "$OUT" -type f | sort | xargs sha256sum | sha256sum | cut -c1-16)
echo "fingerprint $fp  (same inputs + same tool versions => same fingerprint)"
