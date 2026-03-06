# ebal.github.io

**Evaggelos Balaskas - Systems Engineer**

My Blog: [blog.balaskas.gr](https://blog.balaskas.gr)

Simple static site generator for markdown posts, which I post to [ebal.github.io](https://ebal.github.io)

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
