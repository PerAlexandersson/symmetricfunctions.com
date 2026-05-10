# CLAUDE.md

## Project overview

This is the source for [symmetricfunctions.com](https://symmetricfunctions.com), a reference site for algebraic combinatorics covering symmetric functions, tableaux, polytopes, crystals, and related topics.

Each page is a `.tex` file in `tex-source/` that gets compiled through a custom Lua+Pandoc pipeline into static HTML.

## Build commands

```bash
make                  # full build (preprocess → gather → meta → render → assets → search)
make Q=1              # quiet build: only errors and warnings printed
make FILE=foo.tex     # single-file rebuild (uses stale metadata)
make clean && make    # full rebuild from scratch
make deploy           # rsync www/ to production server
make ship             # clean → build → deploy
make unittest         # run test pipeline on tests/unittest.tex
```

## Project structure

```
tex-source/           .tex source files (one per page, ~70 files)
bibliography.bib      BibLaTeX entries (~1400 references)
template.htm          Shared HTML shell (nav, header, footer)
assets/               Static files: CSS, JS, icons, SVG images
  icons/              FontAwesome SVG icons
  nav-images/         Topic card images (card-{label}.svg)
  svg-images/         TikZ figure outputs
svg-tex/src/          TikZ source for icons and card images
temp/                 Build intermediates (gitignored)
www/                  HTML output (gitignored)
*.lua                 Build pipeline scripts
config.mk             Build configuration
```

## TeX file conventions

Every `.tex` file starts with:
```tex
\metatitle{Page Title}
\metadescription{Brief description for SEO}
```

### Sections and labels

All sections must have a label in brackets: `\section[labelId]{Display Title}`.
Labels use **camelCase** (e.g., `stanleyMonotonicity`, `ehrhartMacdonaldReciprocity`).
Kebab-case labels exist in some older files (e.g., `parking-functions`) but camelCase is preferred.

### Key macros

| Macro | Purpose |
|-------|---------|
| `\defin{term}` | Mark a term being defined (renders styled) |
| `\name{Full Name}` | Mathematician name (auto-links to Google Scholar) |
| `\cite{Key}` | Bibliography citation (looks up in bibliography.bib) |
| `\hyperref[label]{text}` | Cross-page link (resolves via site-labels.json) |
| `\todo{message}` | Note for future work (excluded from HTML output, printed to stderr during build) |
| `\icon{name}` | Inline SVG icon |
| `\svgimg[width=0.8]{path}{alt}` | Scaled SVG image |

### Environments

Standard theorem-like environments: `definition`, `theorem`, `proposition`, `lemma`, `conjecture`, `remark`, `example`, `proof`, `proof*` (unnumbered).

### Polynomial family metadata

```tex
\begin{polydata}{id}
  Name    & Display name \\
  Symbol  & $\schurS_\lambda$ \\
  Year    & 1900 \\
  PositiveIn  & schur | SomeBibKey \\
  Contains    & otherFamily \\
  Generalizes & schur \\
  Generalizes & hallLittlewoodP | SomeBibKey \\
  ...
\end{polydata}
```

Relation targets are other `polydata` ids. References are optional bibliography keys, written after `|` or in trailing brackets. Multiple relation rows with the same key are allowed, and multiple targets can also be separated by semicolons.

## Bibliography

References go in `bibliography.bib` in BibLaTeX format. The build converts `eprint` fields to arXiv URLs automatically. Use `\cite{Key}` or `\cite[Thm.~3.1]{Key}` in .tex files.

## Build pipeline (7 stages)

1. **Preprocess** (`preprocess.lua`): Rewrites section labels, annotates todos with file:line, normalizes macros
2. **Bibliography**: Converts `.bib` → CSL-JSON via Pandoc
3. **Gather** (`gather.lua`): Pandoc filter extracting metadata, citations, labels, todos into JSON
4. **Metadata** (`merge_meta.lua`): Aggregates all labels into `site-labels.json`, validates polydata, generates sitemap
5. **Render** (`render.lua`): JSON → HTML using template.htm, resolves cross-references
6. **Assets**: Copies static files to www/
7. **Search**: Pagefind builds full-text search index

## Error handling

- `make Q=1` suppresses all progress/info/todo messages; only `[ERROR]` and `[WARN]` print
- Normal `make` shows progress, todos, and warnings in color
- Pandoc runs with `--fail-if-warnings` — any warning stops the build
- Missing cross-reference labels print `[ERROR] hyperref to unknown label`
- Missing citations print `[ERROR] Citation not found`

## Common tasks

**Adding a new page**: Create `tex-source/newpage.tex` with `\metatitle` and `\metadescription`. Add a `\topiccard{newpage}{Title}{Description}` to `tex-source/index.tex`. Create a matching card SVG in `assets/nav-images/card-newpage.svg`.

**Adding a reference**: Add a BibLaTeX entry to `bibliography.bib`, then use `\cite{Key}` in .tex files.

**Cross-linking**: Use `\hyperref[label]{link text}` where `label` is any section label on any page. The build resolves these across all pages.

**Renaming a label**: Grep for the old label across all .tex files to update any `\hyperref` references.
