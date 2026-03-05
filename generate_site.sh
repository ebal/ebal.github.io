#!/usr/bin/env bash
set -euo pipefail

MARKDOWN_DIR="markdown"
DOCS_DIR="docs"
INDEX_FILE="$DOCS_DIR/index.html"
GITHUB_IMG_BASE_URL="https://raw.githubusercontent.com/ebal/ebal.github.io/main/img"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc is required but was not found in PATH."
  exit 1
fi

if [[ ! -d "$MARKDOWN_DIR" ]]; then
  echo "Error: markdown directory not found: $MARKDOWN_DIR"
  exit 1
fi

if [[ ! -d "$DOCS_DIR" ]]; then
  echo "Error: docs directory not found: $DOCS_DIR"
  exit 1
fi

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "Error: index file not found: $INDEX_FILE"
  exit 1
fi

rand_color() {
  printf '#%06X' "$((RANDOM * RANDOM % 16777216))"
}

slug_to_title() {
  local slug="$1"
  echo "$slug" | tr '_-' '  ' | awk '{
    out=""
    for (i = 1; i <= NF; i++) {
      w = $i
      out = out (i > 1 ? " " : "") toupper(substr(w, 1, 1)) substr(w, 2)
    }
    print out
  }'
}

extract_title() {
  local md_file="$1"
  local fallback="$2"
  local title
  title="$(awk '/^# / {sub(/^# /, "", $0); print; exit}' "$md_file" || true)"
  if [[ -z "$title" ]]; then
    title="$fallback"
  fi
  echo "$title"
}

rewrite_local_img_urls() {
  sed -E \
    -e "s#src=\"((\\./|\\.\\./)*)img/+([^\"]+)\"#src=\"$GITHUB_IMG_BASE_URL/\\3\"#g" \
    -e "s#src='((\\./|\\.\\./)*)img/+([^']+)'#src='$GITHUB_IMG_BASE_URL/\\3'#g"
}

md_epoch() {
  local md_file="$1"
  date -r "$md_file" '+%s' 2>/dev/null || stat -c '%Y' "$md_file" 2>/dev/null || echo 0
}

md_date() {
  local md_file="$1"
  date -r "$md_file" '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d'
}

rebuild_index_posts() {
  local row epoch html_file title post_date escaped_title
  local block=""

  while IFS='|' read -r epoch html_file title post_date; do
    escaped_title="$(printf '%s' "$title" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')"
    block+="            <a class=\"post\" href=\"$html_file\">"$'\n'
    block+="                <h2 class=\"post-title\">$escaped_title</h2>"$'\n'
    block+="                <p class=\"post-date\">$post_date</p>"$'\n'
    block+="            </a>"$'\n'
    block+=$'\n'
  done < <(
    shopt -s nullglob
    for md_file in "$MARKDOWN_DIR"/*.md; do
      base_name="$(basename "$md_file" .md)"
      html_file="$base_name.html"
      if [[ "$html_file" == "index.html" ]]; then
        continue
      fi
      title_fallback="$(slug_to_title "$base_name")"
      title="$(extract_title "$md_file" "$title_fallback")"
      post_date="$(md_date "$md_file")"
      epoch="$(md_epoch "$md_file")"
      printf '%s|%s|%s|%s\n' "$epoch" "$html_file" "$title" "$post_date"
    done | sort -t'|' -k1,1nr
  )

  awk -v block="$block" '
    BEGIN {
      in_posts = 0
      skip_post = 0
      inserted = 0
    }
    {
      if ($0 ~ /<a class="post"/) {
        skip_post = 1
      }

      if (skip_post) {
        if ($0 ~ /<\/a>/) {
          skip_post = 0
        }
        next
      }

      if (!inserted && index($0, "<div class=\"posts\">")) {
        print
        printf "%s", block
        inserted = 1
        in_posts = 1
        next
      }

      if (in_posts) {
        if (index($0, "</div>")) {
          print
          in_posts = 0
        }
        next
      }

      print
    }
  ' "$INDEX_FILE" > "$INDEX_FILE.tmp"

  mv "$INDEX_FILE.tmp" "$INDEX_FILE"
}

new_files=()

shopt -s nullglob
for md_file in "$MARKDOWN_DIR"/*.md; do
  base_name="$(basename "$md_file" .md)"
  output_html="$DOCS_DIR/$base_name.html"

  if [[ -f "$output_html" ]]; then
    continue
  fi

  c1="$(rand_color)"
  c2="$(rand_color)"
  c3="$(rand_color)"
  c4="$(rand_color)"
  c5="$(rand_color)"

  title_fallback="$(slug_to_title "$base_name")"
  title="$(extract_title "$md_file" "$title_fallback")"
  body_html="$(pandoc -f gfm -t html "$md_file" | rewrite_local_img_urls)"

  cat > "$output_html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    :root {
      --c1: $c1;
      --c2: $c2;
      --c3: $c3;
      --c4: $c4;
      --c5: $c5;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Segoe UI", Tahoma, Verdana, sans-serif;
      line-height: 1.7;
      color: #1f2328;
      background:
        radial-gradient(circle at 85% 15%, color-mix(in srgb, var(--c5) 25%, transparent), transparent 40%),
        linear-gradient(135deg, color-mix(in srgb, var(--c1) 20%, white), color-mix(in srgb, var(--c2) 25%, white));
      padding: 2rem 1rem;
    }
    .page {
      width: min(900px, 100%);
      margin: 0 auto;
      background: color-mix(in srgb, var(--c1) 18%, white);
      border: 1px solid color-mix(in srgb, var(--c4) 35%, #ffffff);
      border-radius: 14px;
      box-shadow: 0 16px 32px color-mix(in srgb, var(--c5) 20%, transparent);
      padding: 2rem;
    }
    h1, h2, h3 {
      line-height: 1.25;
      color: color-mix(in srgb, var(--c5) 80%, #000000);
    }
    a {
      color: color-mix(in srgb, var(--c4) 85%, #000000);
      text-decoration: none;
    }
    a:hover { text-decoration: underline; }
    hr {
      border: 0;
      border-top: 1px solid color-mix(in srgb, var(--c3) 40%, #ffffff);
      margin: 2rem 0;
    }
    pre, code {
      background: color-mix(in srgb, var(--c2) 16%, #ffffff);
      border-radius: 6px;
    }
    pre { padding: 1rem; overflow-x: auto; }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 1.2rem 0;
      background: #fff;
    }
    th, td {
      border: 1px solid color-mix(in srgb, var(--c3) 35%, #ffffff);
      padding: 0.6rem 0.7rem;
      text-align: left;
      vertical-align: top;
    }
    th {
      background: color-mix(in srgb, var(--c2) 24%, #ffffff);
      color: color-mix(in srgb, var(--c5) 78%, #000000);
    }
    .palette {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      margin-top: 1rem;
    }
    .swatch {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      font-size: 0.85rem;
      color: #333;
      background: #fff;
      border: 1px solid #ddd;
      border-radius: 999px;
      padding: 0.25rem 0.55rem 0.25rem 0.3rem;
    }
    .dot {
      width: 0.85rem;
      height: 0.85rem;
      border-radius: 999px;
      border: 1px solid rgba(0,0,0,0.15);
    }
    @media (max-width: 700px) {
      .page { padding: 1.2rem; }
    }
  </style>
</head>
<body>
  <main class="page">
    $body_html
    <hr>
    <section aria-label="Generated color palette">
      <h3>Generated Palette</h3>
      <div class="palette">
        <span class="swatch"><span class="dot" style="background:$c1"></span>$c1</span>
        <span class="swatch"><span class="dot" style="background:$c2"></span>$c2</span>
        <span class="swatch"><span class="dot" style="background:$c3"></span>$c3</span>
        <span class="swatch"><span class="dot" style="background:$c4"></span>$c4</span>
        <span class="swatch"><span class="dot" style="background:$c5"></span>$c5</span>
      </div>
    </section>
    <p style="margin-top:1.4rem;">
      <a href="index.html" style="display:inline-block;padding:0.5rem 0.85rem;border-radius:999px;background:color-mix(in srgb, var(--c5) 70%, #000000);color:#fff;text-decoration:none;">Back to all posts</a>
    </p>
  </main>
</body>
</html>
EOF

  new_files+=("$base_name")
  echo "Generated: $output_html"
done

if [[ ${#new_files[@]} -eq 0 ]]; then
  echo "No new markdown files found to generate."
fi

rebuild_index_posts
echo "Index rebuilt in reverse date order."

echo "Done."
