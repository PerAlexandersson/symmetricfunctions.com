# SymCat — symmetricfunctions.com

A static catalog of symmetric functions and related mathematical topics, built with a custom LaTeX → HTML pipeline. Live at [symmetricfunctions.com](https://www.symmetricfunctions.com).

## Build pipeline

```
tex-source/*.tex
  → preprocess.lua          normalize TeX before Pandoc
  → Pandoc + gather.lua     extract metadata, produce temp/*.json
  → merge_meta.lua          aggregate → site-labels.json, site-polydata.json, sitemap.xml
  → render.lua              .json + template.htm → www/*.htm
  → copy assets             www/ (deployed via rsync to ns12.inleed.net)
```

```bash
make              # full build (8 parallel jobs)
make FILE=foo.tex # single-file rebuild (uses stale metadata)
make bib          # regenerate bibliography JSON only
make deploy       # rsync www/ to server
make clean        # rm temp/ www/
make unittest     # run tests/unittest.tex through pipeline
```

## Directory structure

```
tex-source/         LaTeX source files (one .tex per topic page)
assets/             CSS, JS, icons (copied verbatim to www/)
  style.css         CSS with layers: reset, base, layout, components
  site.js           KaTeX rendering, sidebar, TOC, copy buttons, sortable table
  tex-init.js       184+ KaTeX macro definitions
temp/               Generated intermediates (gitignored)
  *.pre.tex         preprocessed TeX
  *.json            Pandoc AST + metadata
  bibliography.json CSL-JSON bibliography
  site-labels.json  842 cross-reference labels (id → href, title, page)
  site-polydata.json structured metadata per polynomial family
www/                Final HTML output (gitignored)
untracked/          Notes, drafts, assets not in git
template.htm        Shared HTML shell (header/nav/footer)
bibliography.bib    BibLaTeX references (~1200 entries)
```

## Key Lua files

| File | Role |
|------|------|
| `preprocess.lua` | Text-level TeX normalization before Pandoc sees it |
| `gather.lua` | Pandoc Lua filter: traverses AST, extracts labels/citations/polydata/todos |
| `merge_meta.lua` | Aggregates all .json → site-wide indexes |
| `render.lua` | Pure Lua renderer: .json → HTML using template |
| `bibhandler.lua` | CSL-JSON → formatted HTML bibliography entries |
| `figure_to_html.lua` | LaTeX tables (ytableau, tabular, array) → HTML/CSS Grid |
| `polydata_to_html.lua` | Renders the symmetric function family index table |
| `tex_to_svg.lua` | Standalone: TeX → PDF → SVG (TikZ figures) |
| `utils.lua` | Shared: slugify, html_escape, ascii_fold, print_color |
| `file_reading.lua` | JSON I/O abstraction (detects available library) |

## Conventions

- **Naming:** kebab-case for HTML/CSS; snake_case for Lua variables
- **Lua modules:** `M` export pattern; `(result, error)` tuples for error handling
- **LaTeX custom commands:**
  - `\metatitle{...}`, `\metadescription{...}` — page metadata
  - `\name{Person}` — wrap proper names
  - `\defin{term}` — definition markup
  - `\polydata{...}` — structured metadata block for a polynomial family
  - `\todo{...}` content is collected but excluded from output prose
  - `\section[label]{Title}` — label is used for cross-references
- **Math:** rendered client-side by KaTeX via `tex-init.js` macros
- **eprint fields:** The build converts all BibLaTeX `eprint`/`EPrint`/`EPRINT` fields to `url = {https://arxiv.org/abs/ID}` before Pandoc sees the bib file.

## Working with LaTeX source (AI prompt)

When editing `.tex` files, apply these rules:

**GLOBAL EXCLUSION:** Ignore content inside `\todo{...}` — do not check citations, grammar, or names there.

1. **Citation verification:** Replace inline `\href{...}` links to arXiv/journals with `\cite{key}` if the paper is in `bibliography.bib`. Output `[MISSING CITATION] <URL>` if not found. Do not invent BibTeX entries.

2. **Name wrapping:** Wrap plain-text proper names in `\name{...}`. Exceptions: names in `\cite{}`, names joined by hyphens (e.g. `Heilmann--Lieb`), names in theorem environment optional arguments (e.g. `\begin{theorem}[Alexandersson]`).

3. **Grammar & terminology:** Fix typos. Wrap technical terms in `\defin{...}` or `\hyperref[label]{...}` where appropriate.

Output format: bulleted list, prefix each item with `[Line N]`.

## Deployment

```bash
make deploy   # rsync -avizL -e "ssh -p 2020" www/ symmetricf@ns12.inleed.net:domains/symmetricfunctions.com/public_html
```

## GitHub

[github.com/PerAlexandersson/symmetricfunctions.com](https://github.com/PerAlexandersson/symmetricfunctions.com) — contributions via pull requests welcome.
