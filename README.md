# ebal.github.io

Evaggelos Balaskas

Simple static site generator for markdown posts.

## Usage

```bash
./generate_site.sh
```

The script:
- reads markdown files from `markdown/`
- generates HTML pages in `docs/`
- adds new pages to `docs/index.html`
- rewrites local image paths (for `img/`) to raw GitHub URLs

## Project layout

- `markdown/`: source markdown files
- `docs/`: generated site output
- `img/`: image assets
- `generate_site.sh`: generator script
