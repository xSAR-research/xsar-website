# xsar-website

Static HTML5 website for xSAR.

## Structure

```
xsar-website/
├── images/
├── css/
│   └── master.css
├── index.html
├── about.html
└── contact.html
```

## Contact form

`contact.html` submits to Formspree via a standard HTML `POST` form:

- Endpoint: `https://formspree.io/f/xojzwdge`
- Fields: `name`, `email`, `message`

## Git

All commits are SSH-signed with a YubiKey (`sk-ssh-ed25519`). Per-repo `user.email` and `user.signingkey` select the AccessIT or xSAR-research identity; a YubiKey touch is required at commit time.

Verify the latest commit signature:

```bash
git log --show-signature -1
```

## GitHub remote

Repository: [github.com/xSAR-research/xsar-website](https://github.com/xSAR-research/xsar-website)

```bash
git remote add origin git@github-xsar:xSAR-research/xsar-website.git
git push -u origin main
```

The `github-xsar` host alias in `~/.ssh/config` routes auth through the xSAR-research YubiKey keys.

Register your YubiKey SSH public key in GitHub under **Settings → SSH and GPG keys**:

- **Authentication key** — required for `git push` / `git pull`
- **Signing key** — required for commits to show as Verified

On GitHub, verified commits display a **Verified** badge next to the commit message.

Each GitHub account has primary and secondary YubiKey credentials for signing and authentication.

## Articles pipeline (Markdown → HTML5)

Articles are written in Markdown in `src/articles/<slug>.md` and built on beast into plain HTML5 under `articles/`, which GitHub Pages serves as-is. Maths becomes MathML at build time (no JavaScript, no CDN), and every formula is also rendered to PNG for X Articles. The build is offline and deterministic: the same inputs and tool versions give byte-identical output.

`articles/` is **regenerated from scratch on every build**, so don't hand-edit it. The hand-written pages are never touched. `sitemap.xml` changes only with `--update-sitemap`, and only between its `articles:begin/end` markers.

### Install (Arch)

```bash
sudo pacman -S --needed pandoc-cli texlive-basic texlive-latex texlive-latexextra dvisvgm resvg oxipng
```

- `standalone.cls` lives in **`texlive-latexextra`** (it also pulls in `texlive-latexrecommended`). `amsmath` is in `texlive-latex`, and `amssymb` and the Computer Modern fonts are in `texlive-basic`. `texlive-bin` (which provides `latex`) comes in as a dependency.
- Expected versions are listed in `tools.versions`. To freeze them, add `pandoc-cli dvisvgm resvg oxipng` to `IgnorePkg` in `/etc/pacman.conf`. After a deliberate upgrade, run `./build.sh --record-versions`, rebuild, and commit.

### Writing an article

1. Create `src/articles/<slug>.md`. The slug is lowercase `a-z0-9-` and must match the file name:

   ```markdown
   ---
   title: "Google AX: Turn Promising AI Agents into Practical Automation"
   date: 2026-10-17          # YYYY-MM-DD
   slug: google-ax
   summary: "One or two sentences for the index and the meta description."
   x_url: https://x.com/xSAR_Research/status/...   # optional, adds a "Read on X" link
   updated: 2026-10-20       # optional, used as the sitemap lastmod
   ---
   ```
2. Paste the X article's Markdown under the front matter.
   - Headers `#`…`####`, `---`, `**bold**`, `*italics*`, `[underlined]{.underline}`, links, pipe tables and `![alt](../images/file.png)` all work.
   - Image paths are relative to `articles/`, so site images are `../images/...`.
   - Inline maths is `$...$` and display maths is `$$...$$`.
3. Build with `./build.sh`, or `./build.sh --update-sitemap` to also refresh the article entries in `sitemap.xml`. `make verify` builds twice and checks the output is byte-identical.
4. Preview with `python -m http.server 8000`, then open <http://localhost:8000/articles/>.
5. For X, open `articles/formulas/<slug>.txt`. It lists every formula in order, with the PNG to upload for each (`articles/formulas/<sha256>.png`).
6. Commit and push:

   ```bash
   git add src/articles articles sitemap.xml
   git commit -m "Add article: <title>"
   git push
   ```

### How it works

| File | Role |
|---|---|
| `build.sh` | Checks tool versions, runs Pandoc per article, renders formulas, writes `articles/index.html` (newest first, slug breaks ties) and the optional sitemap block. Prints a fingerprint of `articles/` at the end. |
| `templates/article.html5` | Pandoc template copied from `about.html` (header, nav, footer, `../css/master.css`). Used for article pages and the index. |
| `filters/article.lua` | Validates front matter, formats dates, writes the per-article formula manifest and index rows, and queues one LaTeX job per formula. |
| `css/articles.css` | Table, image, maths and index styling for `articles/` only. |
| `tools.versions` | Expected tool versions. Mismatches print a warning, and `--strict` turns them into a failure. |
| `.nojekyll` | Stops GitHub Pages from running Jekyll. |

The page is built with `pandoc --from markdown+yaml_metadata_block+bracketed_spans --to html5 --standalone --template templates/article.html5 --math-method=mathml --lua-filter filters/article.lua`.

Each formula goes through `latex` (standalone class), then `dvisvgm --no-fonts --exact-bbox`, then `resvg --zoom 4 --background white`, then `oxipng -o 2 --strip all`. It is named by `sha256("<inline|display>\n<TeX>")`, so a repeated formula is rendered once.

The build runs with `LC_ALL=C TZ=UTC SOURCE_DATE_EPOCH=0`, and nothing it writes contains a timestamp or a machine path. The SVG glyph `<defs>` are sorted into a fixed order, because older dvisvgm versions vary that order from run to run.
