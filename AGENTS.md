# ebal.github.io — Agent Guide

Personal blog of Evaggelos Balaskas, hosted via GitHub Pages.

## Build

```bash
./generator.sh
```

Requires `pandoc` in PATH. No other dependencies.

## Flow

1. Write a markdown post in `markdown/`
2. Run `./generator.sh` — generates HTML in `docs/` and rebuilds the index
3. Commit and push both `markdown/` (source) and `docs/` (output)

## Gotchas

- **Script name**: the shell script is `generator.sh`, not `generate_site.sh` (README errata).
- **Only new posts**: `generator.sh` skips any markdown file whose HTML output already exists in `docs/`. To regenerate an existing post, delete the HTML first.
- **`markdown/index.md` excluded**: its HTML would conflict with the site index, so it is skipped by the generator.
- **Image URLs**: local `src="img/..."` paths in markdown are rewritten to raw GitHub URLs (`https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/...`).
- **Random palette**: each generated post page gets a 5-color random CSS palette; style is in `docs/post.css`.
- **Post order**: the index sorts posts by file modification time, newest first (uses GNU `date -r` / Linux `stat -c %Y`).
- **GitHub Pages**: serves from the `docs/` directory at root — the generated output is committed and pushed.
- **No tests, linters, CI, or package managers** in this repo.
