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
  → copy assets             www/ (deployed with make deploy)
  → pagefind                build search index (www/_pagefind/)

svg-tex/src/*.tex
  → tex_to_svg.lua          TikZ → SVG assets under assets/
```

The CSL-JSON bibliography build converts BibLaTeX `eprint` fields to arXiv
URLs; `temp/bibtex-entries.json` keeps the source entries for the inline
BibTeX copy/download controls.

```bash
make              # full build (8 parallel jobs)
make Q=1          # quiet full build: only errors and warnings
make FILE=foo.tex # single-file rebuild (uses stale metadata)
make bib          # regenerate bibliography JSON and raw BibTeX JSON
make svg          # rebuild TikZ-sourced SVG assets and copy assets
make search       # rebuild pagefind search index
make deploy       # rsync www/ to server
make ship         # clean, build, then deploy
make clean        # rm temp/ www/
make unittest     # render tests/*.tex only under temp/test-www/
make lint-html    # scan generated HTML for leaked TeX/table artifacts
make check        # run unit regressions and audit generated HTML
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
  test-www/         isolated HTML output for tests (never deployed/indexed)
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

Page, metadata, bibliography and code conventions, together with the content
editing checklist, are in [`CONVENTIONS.md`](CONVENTIONS.md).

## Deployment

`make deploy` rsyncs `www/` to the production server and requires host SSH
access; `make ship` cleans, builds and deploys. Agents follow the deployment
procedure in `AGENTS.md`.

## Related projects

[arXiv++](https://arxiv.symmetricfunctions.com) tags new arXiv papers with
SymCat keywords. Each build collects the `\defin{...}` terms, with the anchor
of an immediately following `\label{...}`, into the public feed
`www/site-keywords.json` (`{phrase, href, title}` records). After a deploy,
the **Fetch latest SymCat keywords** button on the arXiv++ admin Retag page
imports new terms from the live feed.

## GitHub

Repository:
https://github.com/PerAlexandersson/symmetricfunctions.com
