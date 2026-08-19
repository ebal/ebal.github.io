# ebal.github.io

**Evaggelos Balaskas - Systems Engineer**

My Blog: [blog.balaskas.gr](https://blog.balaskas.gr)

Simple static site generator for markdown posts, which I post to [ebal.github.io](https://ebal.github.io)

## Usage

```bash
./generator-v2.sh
```

Requires `pandoc` on PATH. The script:
- reads markdown files from `markdown/`
- generates HTML pages in `docs/`
- adds new pages to `docs/index.html`
- rewrites local image paths (for `img/`) to raw GitHub URLs

Two other variants also live in the repo root: `generator.sh` (the original script, kept for
reference — has a known date/sort bug on fresh clones) and `generator-v3.sh` (experimental, styles
posts with Tailwind CSS instead of hand-rolled CSS, requires the `tailwindcss` CLI too). See
`CLAUDE.md` for the differences.

## Project layout

- `markdown/`: source markdown files
- `docs/`: generated site output
- `img/`: image assets
- `generator.sh`, `generator-v2.sh`, `generator-v3.sh`: generator script variants
- `tailwind/input.css`: Tailwind v4 source used by `generator-v3.sh`
