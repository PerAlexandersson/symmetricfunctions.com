# SymCat — symmetricfunctions.com

A static catalog of symmetric functions and related mathematical topics, built
with a custom LaTeX → HTML pipeline. Live at
[symmetricfunctions.com](https://www.symmetricfunctions.com).

## Build pipeline

```
bibliography.bib
  → Pandoc + bib_math_filter.lua → temp/bibliography.json
  → bibtex_extract.lua           → temp/bibtex-entries.json

tex-source/*.tex
  → preprocess.lua          normalize TeX before Pandoc
  → Pandoc + gather.lua     extract metadata, produce temp/*.json
  → merge_meta.lua          aggregate labels, todos, polydata, sitemap,
                             relation graph
  → render.lua              .json + template.htm → www/*.htm
  → copy assets             www/ (deployed via rsync to ns12.inleed.net)
  → pagefind                build search index (www/_pagefind/)

svg-tex/src/*.tex
  → tex_to_svg.lua          TikZ → SVG assets under assets/
```

```bash
make              # full build (8 parallel jobs)
make Q=1          # quiet full build
make FILE=foo.tex # single-file rebuild (uses stale metadata)
make bib          # regenerate bibliography JSON and raw BibTeX JSON
make svg          # rebuild TikZ-sourced SVG assets
make search       # rebuild pagefind search index
make deploy       # rsync www/ to server
make ship         # clean, build, then deploy
make clean        # rm temp/ www/
make unittest     # run tests/*.tex through the test pipeline
```

## Directory structure

```
tex-source/         LaTeX source files (one .tex per topic page)
assets/             CSS, JS, icons (copied verbatim to www/)
  style.css         CSS with layers: reset, base, layout, components
  site.js           KaTeX, sidebar, TOC, copy buttons, BibTeX controls, tables
  tex-init.js       184+ KaTeX macro definitions
  nav-images/       Topic-card SVGs
  svg-images/       Inline figure SVGs
svg-tex/            TikZ sources and shared local definitions for SVG assets
temp/               Generated intermediates (gitignored)
  *.pre.tex         preprocessed TeX
  *.json            Pandoc AST + metadata
  bibliography.json CSL-JSON bibliography
  bibtex-entries.json raw BibTeX entries for reference copy/download controls
  site-labels.json  cross-reference labels (id → href, title, page)
  site-polydata.json structured metadata per polynomial family
  site-todo.json    extracted \todo{...} items
www/                Final HTML output (gitignored)
untracked/          Notes, drafts, assets not in git
template.htm        Shared HTML shell (header/nav/footer)
docs/               CHANGELOG, LICENCE, CONTRIBUTING
bibliography.bib    BibLaTeX references (2,300+ entries)
```

## Prerequisites

`lua`, `pandoc`, `jq`, `npx pagefind`, `rsync` (for deploy).

## Key Lua files

| File | Role |
|------|------|
| `preprocess.lua` | Text-level TeX normalization before Pandoc sees it |
| `gather.lua` | Pandoc Lua filter: traverses AST, extracts labels/citations/polydata/todos |
| `merge_meta.lua` | Aggregates all .json → site-wide indexes |
| `render.lua` | Pure Lua renderer: .json → HTML using template |
| `bibtex_extract.lua` | Extracts source BibTeX entries to JSON for copy/download controls |
| `bibhandler.lua` | CSL-JSON + raw BibTeX → formatted HTML bibliography entries |
| `figure_to_html.lua` | LaTeX tables (ytableau, tabular, array) → HTML/CSS Grid |
| `polydata_to_html.lua` | Renders the symmetric function family index table |
| `relation_graph.lua` | Builds relation graph data and HTML from `polydata` |
| `relation_registry.lua` | Defines supported relation metadata and directions |
| `tex_to_svg.lua` | Standalone: TeX → PDF → SVG (TikZ figures) |
| `utils.lua` | Shared: slugify, html_escape, ascii_fold, print_color |
| `file_reading.lua` | JSON I/O abstraction (detects available library) |
| `bib_math_filter.lua` | Pandoc filter: preserves math in bibliography entries |

## Conventions

- **Naming:** kebab-case for HTML/CSS; snake_case for Lua variables
- **Lua modules:** `M` export pattern; `(result, error)` tuples for error handling
- **LaTeX custom commands:**
  - `\metatitle{...}`, `\metadescription{...}` — page metadata
  - `\name{Person}` — wrap proper names
  - `\defin{term}` — definition markup
  - `\polydata{...}` — structured metadata block for a polynomial family
    - Relation rows inside `polydata` use targets that are other `polydata`
      ids. Preferred form:
      `RelationKey & target | BibKey[,BibKey...] | attr=value; attr=value \\`.
      Existing short forms `target | BibKey` and `target [BibKey]` are still
      supported.
  - `\todo{...}` content is collected but excluded from output prose
  - `\section[label]{Title}` — label is used for cross-references
- **Math:** rendered client-side by KaTeX via `tex-init.js` macros
- **Bibliography:** `temp/bibliography.json` drives displayed references,
  while `temp/bibtex-entries.json` preserves source entries for the inline
  BibTeX copy/download controls.
- **eprint fields:** The CSL-JSON bibliography build converts all BibLaTeX
  `eprint`/`EPrint`/`EPRINT` fields to
  `url = {https://arxiv.org/abs/ID}` before Pandoc sees the bib file. The raw
  BibTeX controls use the source entry from `bibliography.bib`.
- **SVG assets:** Add or edit card and figure images through
  `svg-tex/src/*.tex`, then run `make svg`. Do not hand-edit generated SVGs
  unless there is a deliberate one-off fix.

## Content editing checklist

- Ignore content inside `\todo{...}` during prose, citation, and name cleanup.
- Replace raw arXiv or journal `\href{...}` links with `\cite{key}` when the
  source is already in `bibliography.bib`. Do not invent citation keys.
- Wrap plain-text mathematician names in `\name{...}` outside citations and
  theorem labels.
- Use `\defin{...}` or `\hyperref[label]{...}` for important technical terms
  when it improves navigation or clarity.

Run `make all` after broad page edits and `make unittest` after Lua or
pipeline changes.

## Deployment

`make deploy` rsyncs `www/` to the production server. Do not deploy unless the
deployment is intentional.

## GitHub

Repository:
https://github.com/PerAlexandersson/symmetricfunctions.com
